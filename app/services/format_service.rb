class FormatService < BaseService
  include Conversion

  def initialize
    @google ||= GoogleMapService.new
  end

  def web_format results=nil, google_results=nil
    columns = []

    results.each do |result|
      r = facebook_response(result)
      r.text = set_text(r)

      # g_match = {'score' => 0.0, 'match_score' => 0.0}
      # if google_results.present?
      #   google_results.each do |r|
      #     match_score = fuzzy_match(r['name'],name)
      #     if match_score >= I18n.t('google.match_score') && match_score > g_match['match_score']
      #       g_match['score'] = r['rating']
      #       g_match['match_score'] = match_score
      #     end
      #   end
      # end

      # google_score = (g_match['score'].to_f > 0.1) ? " #{g_match['score'].to_f.round(2)}分" : ' 無'

      columns << {
        image_url: r.image_url,
        title: r.name,
        open_time: r.today_open_time,
        phone: r.phone,
        street: r.street,
        text: r.text,
        types: r.category_list_web,
        facebook_score: r.rating,
        facebook_score_count: r.rating_count,
        # google_score: google_score,
        official: r.link_url,
        location: @google.get_map_link(r.lat, r.lng, r.name, r.street),
        related_comment: @google.get_google_search(r.name),
        distance: r.distance
      }
    end
    return columns
  end
end
