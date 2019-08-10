Rails.application.routes.draw do
  devise_for :users,
  controllers: {
    sessions: 'users/sessions',
    registrations: "users/registrations",
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  root 'products#index'
  resources :users, only: [:show, :new] do
    collection do
      get 'signout'
      get 'select_sign_up'
      get 'sign_up_second'
      get 'sign_up_third'
      get 'sign_up_forth'
      get 'sign_up_fifth'
      get 'detail'
      get 'profile'
      get 'credit'
      get 'item_state'
    end
  end
  resources :products, only: [:index, :new, :show, :create, :edit, :update] do
    collection do
      get 'buy/:id' => 'products#buy', as: 'buy'
      get 'pay/:id' => 'products#pay', as: 'pay'
    end
  end

  resources :credits, only: [:new, :create, :index, :destroy]
end
