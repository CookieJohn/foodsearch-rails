require 'fuzzystringmatch'

class CommonService

	attr_accessor :jarow
	def initialize
    self.jarow ||= FuzzyStringMatch::JaroWinkler.create(:native)
  end

	def safe_url link
		uri = URI.encode(link)
    uri = URI.parse(uri)
	end

	def fuzzy_match compare_a, compare_b
		jarow.getDistance(compare_a,compare_b).to_f
	end
end