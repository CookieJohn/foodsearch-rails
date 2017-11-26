Rails.application.routes.draw do
  root 'base#index'
  # get 'search' => 'base#search'
  # post 'refresh_locations' => 'base#refresh_locations'
  get 'privacy' => 'base#privacy'

  get 'location' => 'base#location'
  get 'selection' => 'base#selection'
  get 'results' => 'base#results'

  post 'set_locale' => 'base#set_locale'

  # line bot
  post 'callback' => 'line#callback'
  # facebook bot
  get 'webhook' => 'facebook#webhook'
  post 'webhook' => 'facebook#post_webhook'
  # telegram bot
  # post 'update' => 'telegram#update'

  resources :users, only: [:show, :edit, :update]
end
