Rails.application.routes.draw do
  post 'token', to: 'oauth2#create'
  post 'revoke', to: 'oauth2#destroy'

  post 'zuora-signatures', to: 'zuora#create_hmac_signature'
  jsonapi_resources :payments, only: [:index, :show]
end
