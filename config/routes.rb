Rails.application.routes.draw do
  root 'base#index'
  get 'search' => 'base#search'
  post 'refresh_locations' => 'base#refresh_locations'
  get 'privacy' => 'base#privacy'

  # line bot
  post 'callback' => 'line#callback'
  # facebook bot
  get 'webhook' => 'facebook#webhook'
  post 'webhook' => 'facebook#webhook'
end
