Rails.application.routes.draw do
  resources :users, only: [:index, :show, :create, :destroy] do
    collection do
      post 'login'
      patch 'change'
    end
  end
end
