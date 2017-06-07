Rails.application.routes.draw do
  # root 'base#index'
  get 'webhook' => 'base#webhook'
  post 'callback' => 'base#callback'
  post 'facebook_callback' => 'base#facebook_callback'
end
