Rails.application.routes.draw do
  resources :custom_message_settings, only: [] do
    get :edit, on: :collection
    post :update, on: :collection
  end
end