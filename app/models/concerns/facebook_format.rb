# frozen_string_literal: true

module FacebookFormat
  def text_format(text)
    {
      recipient: { id: @sender_id },
      message: { text: text }
    }
  end

  def button(url, title)
    {
      type: 'web_url',
      url: url,
      title: title,
      webview_height_ratio: 'tall'
    }
  end

  def quick_replies_format(title_text = nil, quick_reply_options = nil)
    {
      recipient: { id: @sender_id },
      message: {
        text: title_text,
        quick_replies: quick_reply_options
      }
    }
  end

  def button_format(title_text = nil, button_options = nil)
    {
      recipient: { id: @sender_id },
      message: {
        attachment: {
          type: 'template',
          payload: {
            template_type: 'button',
            text: title_text,
            buttons: button_options
          }
        }
      }
    }
  end

  def button_option(type, title, payload)
    {
      type: type,
      title: title,
      payload: payload
    }
  end

  def phone_option(title, phone)
    {
      type: 'phone_number',
      title: title,
      payload: phone
    }
  end

  def button_link_option(url, title, webview_height = 'tall', share_button = 'hide')
    {
      type: 'web_url',
      url: url,
      title: title,
      webview_height_ratio: webview_height,
      webview_share_button: share_button
    }
  end

  def quick_replies_option(title, payload)
    {
      content_type: 'text',
      title: title,
      payload: payload
    }
  end

  def send_location
    { content_type: 'location' }
  end

  def generic_elements(results = nil)
    columns = []

    results.each do |result|
      r = reorganization(result, 'facebook')

      actions = []
      actions << button(safe_url(r.link_url), I18n.t('button.fanpage'))
      actions << button(safe_url(@google.get_map_link(r.lat, r.lng, r.name, r.street)), I18n.t('button.location'))
      actions << button(safe_url(@google.get_google_search(r.name)), I18n.t('button.related_comment'))

      columns << {
        title: r.name,
        subtitle: r.description,
        image_url: r.image_url,
        buttons: actions
      }
    end

    {
      recipient: { id: @sender_id },
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
  end
end
