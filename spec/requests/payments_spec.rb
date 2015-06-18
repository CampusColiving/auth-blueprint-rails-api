require 'rails_helper'

describe 'Payments API' do
  let(:headers) do
    {
      'Accept':        'application/vnd.api+json',
      'Content-type':  'application/vnd.api+json',
      'Authorization': "Bearer #{token}"
    }
  end
  let!(:me)     { create(:user, :logged_in) }
  let(:token)   { me.login.oauth2_token }

  describe 'GET /payments' do

    subject { get '/payments', {}, headers }

    it 'success', vcr: { cassette_name: 'zuora/payments' } do
      VCR.use_cassette('zuora/payments') do
        subject

        expect(response.status).to eq 200
      end
    end

    it 'collection of payments resources' do
      VCR.use_cassette('zuora/payments') do
        subject

        expected = {
          data: [
            {
              id: '2c92c0f94db928fc014dc50fee172486',
              attributes: {
                amount:            '2919.36',
                currency:          'USD',
                date:              '2015-06-05T11:51:05.000-08:00'
              },
              type: 'payments',
              links: {
                self: 'http://www.example.com/payments/2c92c0f94db928fc014dc50fee172486'
              }
            }
          ]
        }.to_json

        expect(response.body).to be_json_eql(expected)
      end
    end
  end

  describe 'GET /payments/:id' do

    subject { get '/payments/2c92c0f94db928fc014dc50fee172486', {}, headers }

    it 'success' do
      VCR.use_cassette('zuora/payments/id') do
        subject

        expect(response.status).to eq 200
      end
    end

    it 'payment resource' do
      VCR.use_cassette('zuora/payments/id') do
        subject

        expected = {
          data: {
            id: '2c92c0f94db928fc014dc50fee172486',
            attributes: {
              amount:            '2919.36',
              currency:          'USD',
              date:              '2015-06-05T11:51:05.000-08:00'
            },
            type: 'payments',
            links: {
              self: 'http://www.example.com/payments/2c92c0f94db928fc014dc50fee172486'
            }
          }
        }.to_json

        expect(response.body).to be_json_eql(expected)
      end
    end
  end
end
