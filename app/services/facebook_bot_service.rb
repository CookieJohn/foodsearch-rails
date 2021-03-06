# frozen_string_literal: true

class FacebookBotService < BaseService
  include FacebookFormat
  include Conversion

  API_URL ||= "https://graph.facebook.com/v2.6/me/messages?access_token=#{ENV['facebook_page_access_token']}"
  BOT_ID  ||= '844639869021578'

  def initialize
    @graph     = GraphApiService.new
    @google    = GoogleMapService.new
    @user      = nil
    @user_id   = '1'
    @sender_id = nil
    @lat       = nil
    @lng       = nil
  end

  def reply_msg(request)
    body = JSON.parse(request.body.read)
    entries = body['entry']

    return if not_fb_message?(body)

    entries.each do |entry|
      entry['messaging'].each do |receive_message|
        next if bot?(receive_message)

        message      = receive_message.dig('message', 'text')
        message_type = case
                       when receive_message.dig('message', 'quick_reply')
                         receive_message.dig('message', 'quick_reply', 'payload')
                       when receive_message.dig('postback')
                         receive_message.dig('postback', 'payload')
                       when receive_message.dig('message', 'attachments')
                         location_setting(receive_message)
                         return search_by_location
                       when receive_message.dig('message', 'text')
                         get_redis_data(@user_id, 'customize') == true ? 'search_specific_item' : 'message'
                       end

        next if message_type.blank?

        message_data = get_response(message_type, message)
        http_post(API_URL, message_data) if message_data.present?
      end
    end
  end

  private

  def get_response(type, text = nil)
    case type
    when 'choose_search_type'
      clear_keyword
      MessengerBotResponse.for(@sender_id, 'choose_search_type')
    when 'customized_keyword'
      redis_set_user_data(@user_id, 'customize', true)
      clear_keyword
      MessengerBotResponse.for(@sender_id, 'customized_keyword')
    when 'search_specific_item'
      redis_set_user_data(@user_id, 'keyword', text)
      disable_customize
      MessengerBotResponse.for(@sender_id, 'search_specific_item', text)
    when 'direct_search'
      disable_customize
      clear_keyword
      MessengerBotResponse.for(@sender_id, 'direct_search')
    when 'last_location'
      return MessengerBotResponse.for(@sender_id, 'no_last_location') unless get_redis_data(@user_id, 'lat').present?

      disable_customize
      @lat = get_redis_data(@user_id, 'lat')
      @lng = get_redis_data(@user_id, 'lng')
      search_by_location
    else
      disable_customize
      clear_keyword
      MessengerBotResponse.for(@sender_id)
    end
  end

  def not_fb_message?(body)
    body.dig('object') != 'page'
  end

  def bot?(receive_message)
    @sender_id = receive_message.dig('sender', 'id')
    return if @sender_id == BOT_ID

    user_setting
  end

  def user_setting
    # User.create!(facebook_user_id: @sender_id) unless User.exists?(facebook_user_id: @sender_id)
    # @user = User.find_by(facebook_user_id: @sender_id)
    redis_initialize_user(@user_id) unless redis_key_exist?(@user_id)
  end

  def location_setting(receive_message)
    return if receive_message.dig('message', 'attachments').blank?

    receive_message['message']['attachments'].try(:each) do |location|
      @lat = location.dig('payload', 'coordinates', 'lat')
      @lng = location.dig('payload', 'coordinates', 'long')

      record_lat_lng(@lat, @lng)
    end
  end

  def search_by_location
    return unless @lat.present? && @lng.present?

    keyword = get_redis_data(@user_id, 'keyword')
    fb_results = @graph.search_places(@lat, @lng, user: @user, size: 10, keyword: keyword)
    if fb_results.size.positive?
      message_data = generic_elements(fb_results)
      http_post(API_URL, message_data)
      message_data = MessengerBotResponse.for(@sender_id, 'done')
      http_post(API_URL, message_data)

      clear_keyword
    else
      message_data = MessengerBotResponse.for(@sender_id, 'no_result')
      http_post(API_URL, message_data)
    end
  end
end
