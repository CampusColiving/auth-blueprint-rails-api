require 'rails_helper'

describe 'OAuth 2.0 routes' do
  it 'routes to the OAuth 2.0 token route' do
    expect(post: '/token').to route_to(
      controller: 'oauth2', action: 'create'
    )
  end

  it 'routes to the OAuth 2.0 revocation route' do
    expect(post: '/revoke').to route_to(
      controller: 'oauth2', action: 'destroy'
    )
  end
end
