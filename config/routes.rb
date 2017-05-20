Rails.application.routes.draw do
  root 'base#index'
  post 'callback' => 'base#callback'
end
