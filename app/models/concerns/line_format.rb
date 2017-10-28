module LineFormat

  def text_format return_msg
    { type: 'text',
      text: return_msg }
  end

  def carousel_format columns
    { type: "template",
      altText: I18n.t('carousel.text'),
      template: {
        type: "carousel",
        columns: columns }}
  end

  def button_format text, link
    { type: "uri",
      label: text,
      uri: link }
  end

  def carousel_options results
    columns = []

    results.each do |result|
      r = facebook_response(result)
      r.text = set_text(r, 'line')

      actions = []
      actions << button_format(I18n.t('button.official'), safe_url(r.link_url))
      actions << button_format(I18n.t('button.location'), safe_url(google.get_map_link(r.lat, r.lng, r.name, r.street)))
      actions << button_format(I18n.t('button.related_comment'), safe_url(google.get_google_search(r.name)))

      columns << {
        thumbnailImageUrl: r.image_url,
        title: r.name,
        text: r.text,
        actions: actions }
    end

    return columns
  end
end
