Diffux::Application.routes.draw do
  get 'static_pages/about'

  resources :urls

  resources :snapshots, only: %i[show create destroy] do
    member do
      post :accept
      post :reject
    end
  end

  root to: 'urls#index'
end
