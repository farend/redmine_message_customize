Rails.application.routes.draw do
  resources :custom_message_settings, only: [] do
    get :edit, on: :collection
    get :yaml_edit, on: :collection
    post :update, on: :collection
    post :toggle_enabled, on: :collection
  end
end