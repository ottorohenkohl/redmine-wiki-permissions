RedmineApp::Application.routes.draw do
  resources :projects do
    member do
      get 'wiki/:id/permissions', to: 'wiki#permissions', as: :wiki_permissions
      post 'wiki/:id/permissions', to: 'wiki#create_wiki_page_user_permissions'
      patch 'wiki/:id/permissions', to: 'wiki#update_wiki_page_user_permissions'
      delete 'wiki/:id/permissions/:permission_id', to: 'wiki#destroy_wiki_page_user_permissions', as: :wiki_permission
    end
  end
end
