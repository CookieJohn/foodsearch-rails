Rails.application.routes.draw do
  root 'base#index'
  post 'callback' => 'base#callback'
  get 'webhook' => 'base#webhook'
  post 'webhook' => 'base#facebook_callback'
end
