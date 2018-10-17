# frozen_string_literal: true

class FormatService < BaseService
  include Conversion

  def initialize
    @google ||= GoogleMapService.new
  end

  def web_format(results = nil, _google_results = nil)
    columns = []

    results.each_with_index do |r, index|
      result = reorganization(r, nil, index + 1)

      result.location = @google.get_map_link(result.lat, result.lng, result.name, result.street)
      result.related_comment = @google.get_google_search(result.name)

      columns << result
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
    end
    columns
  end
end
