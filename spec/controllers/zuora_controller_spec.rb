require 'rails_helper'

describe ZuoraController do
  describe 'POST #create_hmac_signature' do
    before do
      stub_request(:post, %r{#{Rails.configuration.x.zuora.api_url}/rest/v1/connections}).to_return(headers: { 'set-cookie' => 'ZSession=cookie;' })
      stub_request(:post, %r{#{Rails.configuration.x.zuora.api_url}/rest/v1/hmac-signatures}).to_return(
        body: JSON.generate(
          { signature: 'signature', token: 'token', success: true }
        ),
        headers: { 'Content-Type' => 'application/json' }
      )
    end

    subject do
      post :create_hmac_signature, {
        uri: 'https://apisandbox.zuora.com/rest/v1/payment-methods/credit-cards',
        method: 'POST',
        params: { some: 'value' }
      }
    end

    it 'succeeds' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'responds with an access token' do
      subject

      expect(JSON.parse(response.body).symbolize_keys).to eql({ signature: 'signature', token: 'token', cookie: 'ZSession=cookie' })
    end

    context 'when authentication against Zuora fails' do
      before do
        stub_request(:post, %r{#{Rails.configuration.x.zuora.api_url}/rest/v1/connections}).to_return(status: 401)
      end

      it 'responds with status 502' do
        subject

        expect(response).to have_http_status(502)
      end
    end

    context 'when requesting the signature fails' do
      before do
        stub_request(:post, %r{#{Rails.configuration.x.zuora.api_url}/rest/v1/hmac-signatures}).to_return(
          body: JSON.generate(
            { reasons: [{ message: 'message', code: 12345 }], success: false }
          ),
          headers: { 'Content-Type' => 'application/json' }
        )
      end

      it 'responds with status 422' do
        subject

        expect(response).to have_http_status(422)
      end

      it 'responds with the Zuora errors' do
        subject

        expect(JSON.parse(response.body).deep_symbolize_keys).to eql({ reasons: [{ message: 'message', code: 12345 }] })
      end
    end
  end
end
