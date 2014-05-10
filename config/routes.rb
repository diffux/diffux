require 'sidekiq/web'

Diffux::Application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  scope '(:locale)', locale: /en|es/,
                     defaults: { locale: I18n.default_locale } do
    get 'static_pages/about'

    resources :projects do
      resources :sweeps, only: %i[index show new create] do
        collection do
          post :trigger
        end
      end
    end
    resources :urls,      only: %i[destroy show]
    resources :viewports, only: %i[edit update]

    resources :snapshots, only: %i[show create destroy] do
      member do
        post :accept
        post :reject
        post :take_snapshot
        post :compare_snapshot
        get  :view_log
      end
    end

    resources :refresh, only: :create

    root to: 'projects#index'
  end
end
