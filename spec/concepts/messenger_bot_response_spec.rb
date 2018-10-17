# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessengerBotResponse do
  let (:subject) { MessengerBotResponse }
  let (:sender_id) { '1' }
  let (:default_reply_response) do
    {
      recipient: { id: sender_id },
      message:   { text: '', quick_replies: [] }
    }
  end
  let (:choose_search_reply) { { content_type: 'text', title: I18n.t('messenger.re-select'), payload: 'choose_search_type' } }
  let (:last_location_reply) { { content_type: 'text', title: I18n.t('messenger.last-location'), payload: 'last_location' } }
  let (:back_reply)          { { content_type: 'text', title: I18n.t('messenger.menu'), payload: 'back' } }
  let (:customized_reply)    { { content_type: 'text', title: I18n.t('messenger.enter-keyword'), payload: 'customized_keyword' } }
  let (:messenger_all)       { { content_type: 'text', title: I18n.t('messenger.all'), payload: 'direct_search' } }
  let (:send_location)       { { content_type: 'location' } }

  before do
    Object.any_instance.stub(:get_redis_data).and_return(true)
  end

  it 'default response' do
    default_response = {
      recipient: { id: sender_id },
      message:   {
        attachment: {
          type: 'template',
          payload: {
            template_type: 'button',
            text: I18n.t('messenger.menu-title'),
            buttons: [
              { type: 'postback', title: I18n.t('messenger.buttons.choose_search_type'), payload: 'choose_search_type' },
              { type: 'postback', title: I18n.t('messenger.buttons.keyword_search_type'), payload: 'customized_keyword' }
            ]
          }
        }
      }
    }
    response = subject.for(sender_id)

    expect(response).to eq(default_response)
  end

  it 'direct search response' do
    response = subject.for(sender_id, 'choose_search_type')
    text     = I18n.t('messenger.please-enter-keyword')
    quick_replies = []
    quick_replies << customized_reply
    I18n.t('settings.facebook.search_texts').each_with_index do |search_text, _index|
      quick_replies << { content_type: 'text', title: search_text, payload: 'search_specific_item' }
    end
    quick_replies << messenger_all
    quick_replies << back_reply

    expect_response                           = default_reply_response
    expect_response[:message][:text]          = text
    expect_response[:message][:quick_replies] = quick_replies

    expect(response).to eq(expect_response)
  end

  it 'search specific item response' do
    msg           = 'msg'
    response      = subject.for(sender_id, 'search_specific_item')
    text          = I18n.translate('messenger.search_specity', msg: msg)
    quick_replies = [last_location_reply, send_location, choose_search_reply, back_reply]

    expect_response                           = default_reply_response
    expect_response[:message][:text]          = text
    expect_response[:message][:quick_replies] = quick_replies

    expect(response).to eq(expect_response)
  end

  it 'customized keyword response' do
    response      = subject.for(sender_id, 'customized_keyword')
    text          = I18n.t('messenger.your-keyword')
    quick_replies = [choose_search_reply, back_reply]

    expect_response                           = default_reply_response
    expect_response[:message][:text]          = text
    expect_response[:message][:quick_replies] = quick_replies

    expect(response).to eq(expect_response)
  end

  it 'no result response' do
    keyword       = true
    response      = subject.for(sender_id, 'no_result', keyword)
    text          = I18n.translate('messenger.no-results', keyword: keyword)
    quick_replies = [customized_reply, choose_search_reply, back_reply]

    expect_response                           = default_reply_response
    expect_response[:message][:text]          = text
    expect_response[:message][:quick_replies] = quick_replies

    expect(response).to eq(expect_response)
  end

  it 'direct search response' do
    response      = subject.for(sender_id, 'direct_search')
    text          = I18n.t('messenger.your-location')
    quick_replies = [last_location_reply, send_location]

    expect_response                           = default_reply_response
    expect_response[:message][:text]          = text
    expect_response[:message][:quick_replies] = quick_replies

    expect(response).to eq(expect_response)
  end

  it 'no last location response' do
    response      = subject.for(sender_id, 'no_last_location')
    text          = I18n.t('messenger.never-search')
    quick_replies = [{ content_type: 'location' }, choose_search_reply, back_reply]

    expect_response                           = default_reply_response
    expect_response[:message][:text]          = text
    expect_response[:message][:quick_replies] = quick_replies

    expect(response).to eq(expect_response)
  end

  it 'search done response' do
    response      = subject.for(sender_id, 'done')
    text          = I18n.t('messenger.like-results')
    quick_replies = [customized_reply, choose_search_reply, back_reply]

    expect_response                           = default_reply_response
    expect_response[:message][:text]          = text
    expect_response[:message][:quick_replies] = quick_replies

    expect(response).to eq(expect_response)
  end
end
