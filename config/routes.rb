Rails.application.routes.draw do
  # root 'base#index'
  post 'callback' => 'base#callback'
  post 'facebook_callback' => 'base#facebook_callback'
end
