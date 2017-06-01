class CommonService

	def safe_url link
		uri = URI.encode(link)
    uri = URI.parse(uri)
	end
end