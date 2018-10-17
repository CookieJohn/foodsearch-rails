# frozen_string_literal: true

module LineFormat
  def text_format(return_msg)
    {
      type: 'text',
      text: return_msg
    }
  end

  def carousel_format(columns)
    {
      type:    'template',
      altText: I18n.t('carousel.text'),
      template: {
        type:    'carousel',
        columns: columns
      }
    }
  end

  def button_format(text, link)
    {
      type:  'uri',
      label: text,
      uri:   link
    }
  end

  def postback_button_format(text, data)
    {
      type:  'postback',
      label: text,
      data:  data
    }
  end

  def button_format(name, link)
    {
      type:  'uri',
      label: name,
      uri:   link
    }
  end

  def location_format(text, address, lat, lng)
    {
      type:      'location',
      title:     text,
      address:   address,
      latitude:  lat,
      longitude: lng
    }
  end

  def carousel_options(results)
    columns = []

    results.each do |result|
      r = reorganization(result, 'line')

      actions = []
      actions << button_format(I18n.t('button.fanpage'), safe_url(r.link_url))
      # actions << button_format(
      #   I18n.t('button.location'),
      #   safe_url(@google.get_map_link(r.lat, r.lng, r.name, r.street))
      # )
      actions << postback_button_format(
        I18n.t('button.location'),
        "name=#{r.name}&address=#{r.street}&lat=#{r.lat}&lng=#{r.lng}"
      )
      actions << button_format(
        I18n.t('button.related_comment'),
        safe_url(@google.get_google_search(r.name))
      )

      columns << {
        thumbnailImageUrl: r.image_url,
        title:             r.name,
        text:              r.description,
        actions:           actions
      }
    end

    columns
  end

  def quick_reply(msg = I18n.t('quick_reply.text'))
    {
      type: 'text',
      text: msg,
      quickReply: {
        items: [
          {
            type: 'action',
            action: {
              type:  'location',
              label: I18n.t('quick_reply.send_location')
            }
          }
        ]
      }
    }
  end
end
