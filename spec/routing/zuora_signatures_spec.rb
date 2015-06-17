require 'rails_helper'

describe 'Zuora routes' do
  it 'routes to the Zuora CORS signature route' do
    expect(post: '/zuora-signatures').to route_to(
      controller: 'zuora', action: 'create_hmac_signature'
    )
  end
end
