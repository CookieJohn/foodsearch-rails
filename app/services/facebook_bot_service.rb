require 'httparty'

class FacebookBotService

  REJECT_CATEGORY ||= I18n.t('settings.facebook.reject_category')

  attr_accessor :graph, :google, :common
	def initialize
    self.graph  ||= GraphApiService.new
    self.google ||= GoogleMapService.new
    self.common ||= CommonService.new
  end

  def reply_msg request
    body = JSON.parse(request.body.read)
    entries = body['entry']

    token = Settings.facebook.page_access_token
    uri = "https://graph.facebook.com/v2.6/me/messages?access_token=#{token}"

    user = nil

    if body.dig('object') == 'page'
      entries.each do |entry|
        entry['messaging'].each do |message|
          reveive_message = message.dig('message','text').to_s
          senderID = message.dig('sender','id')
          lat = ''
          lng = ''
          message['message']['attachments'].try(:each) do |location|
            lat = location.dig('payload','coordinates','lat')
            lng = location.dig('payload','coordinates','long')
          end
          if lat.present? && lng.present?
            fb_results = graph.search_places(lat, lng, user)
            google_results = ''

            keywords = fb_results.map {|f| f['name']}
            google_results = google.search_places(lat, lng, user, keywords)

            messageData = self.generic_elements(senderID, fb_results, google_results)
            res = HTTParty.post(uri, body: messageData)
            Rails.logger.info "res: #{JSON.parse(res.body)}"
          elsif reveive_message.present?
            messageData = self.text_format(senderID, reveive_message)
            res = HTTParty.post(uri, body: messageData)
          end
        end
      end
    end
  end

  def text_format id, text
    {
      recipient: {
        id: id
      },
      message: {
        text: text
      }
    }
  end

  def button title, url
    {
      type: 'web_url',
      url: url,
      title: title
    }
  end

  def generic_elements sender_id, results=nil, google_results=nil

    columns = []

    # results.first(2).each do |result|
    result = results.first
      id = result['id']
      name = result['name'][0, 80]
      lat = result['location']['latitude']
      lng = result['location']['longitude']
      street = result['location']['street'] || ""
      rating = result['overall_star_rating']
      rating_count = result['rating_count']
      # phone = result.dig('phone').present? ? result['phone'].gsub('+886','0') : "00000000"
      link_url = result['link'] || result['website']
      category = result['category']
      category_list = result['category_list']
      hours = result['hours']

      description = category
      category_list.sample(2).each do |c|
        description += ", #{c['name']}" if c['name'] != category && !REJECT_CATEGORY.any? {|r| c['name'].include?(r) }
        new_category = Category.create!(facebook_id: c['id'], facebook_name: c['name']) if !Category.exists?(facebook_id: c['id'])
      end
      image_url = graph.get_photo(id)

      actions = []
      actions << self.button(I18n.t('button.official'), common.safe_url(link_url))
      actions << self.button(I18n.t('button.location'), common.safe_url(google.get_map_link(lat, lng, name, street)))
      actions << self.button(I18n.t('button.related_comment'), common.safe_url(google.get_google_search(name)))

      today_open_time = hours.present? ? graph.get_current_open_time(hours) : I18n.t('empty.no_hours')
      g_match = {'score' => 0.0, 'match_score' => 0.0}
      if google_results.present?
        google_results.each do |r|
          match_score = common.fuzzy_match(r['name'],name)
          if match_score >= I18n.t('google.match_score') && match_score > g_match['match_score']
            g_match['score'] = r['rating']
            g_match['match_score'] = match_score
          end
        end
      end

      text = "#{I18n.t('facebook.score')}：#{rating}#{I18n.t('common.score')}/#{rating_count}#{I18n.t('common.people')}" if rating.present?
      text += ", #{I18n.t('google.score')}：#{g_match['score'].to_f.round(2)}#{I18n.t('common.score')}" if g_match['score'].to_f > 2.0
      text += "\n#{description}"
      text += "\n#{today_open_time}"
      # text += "\n#{phone}"

      text = text[0, 80]

      columns << {
        title: name,
        subtitle: text,
        image_url: image_url,
        buttons: actions
      }
    # end

    generic_format = {
      recipient: {
        id: sender_id
      },
      message: {
        attachment: {
          type: 'template',
          payload: {
            template_type: 'generic',
            elements: columns
          }
        }
      }
    }
    Rails.logger.info "generic_format: #{columns.size}"
    return generic_format
  end
end