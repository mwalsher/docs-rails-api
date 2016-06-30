Rails.application.routes.draw do
  resources :documents, only: [:index, :show]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope module: :api, path: :api do
    # Default the latest version and encourage the version be specified in the Accept header.
    # e.g. Accept: application/vnd.postoffice.v1+json
    # The version can also be passed via a `version` parameter with the request.
    scope module: :v0, constraints: Constraints::ApiVersion.new(version: 0) do
      # resources :emails
    end

    scope module: :v1, constraints: Constraints::ApiVersion.new(version: 1, default: true) do
      # resources :emails
    end
  end

end
