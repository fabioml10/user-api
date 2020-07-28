Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: [:index, :show, :create, :destroy] do
        collection do
          post 'login'
          patch 'change'
        end
      end
    end
  end
end
