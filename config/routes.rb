Rails.application.routes.draw do
  resources :custom_message_settings, only: [] do
    get :edit, on: :collection
    patch :update, on: :collection
  end
end