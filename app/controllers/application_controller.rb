require "browser/aliases"
Browser::Base.include(Browser::Aliases)

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include MetaHelper

  before_action :default_set_locale

  private

  def default_set_locale
    I18n.locale = session[:locale] || I18n.default_locale
  end

  def set_zoom
    @zoom = if browser.mobile?
              15
            else
              16
            end
  end
end
