require 'httparty'

class FacebookBotService

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

    user_id = event['source']['userId']
    User.create!(line_user_id: user_id) if !User.exists?(line_user_id: user_id)
    user = User.find_by(line_user_id: user_id)

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
            if user.get_google_result
              keywords = fb_results.map {|f| f['name']}
              google_results = google.search_places(lat, lng, user, keywords)
            end
            messageData = self.text_format(senderID, "#{lat},#{lng}")
            res = HTTParty.post(uri, body: messageData)
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
end