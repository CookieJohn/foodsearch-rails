Rails.application.routes.draw do
  root 'base#index'
  get 'search' => 'base#search'
  post 'refresh_locations' => 'base#refresh_locations'
  post 'callback' => 'base#callback'
  get 'webhook' => 'base#webhook'
  post 'webhook' => 'base#facebook_callback'
  get 'privacy' => 'base#privacy'
end
