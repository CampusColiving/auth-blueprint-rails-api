require 'rails_helper'

describe Oauth2Controller do
  describe 'POST #create' do
    let(:login_password) { Faker::Lorem.word }
    let(:login)          { create(:login, :verified, password: login_password) }
    let(:params)         { { grant_type: 'password', username: login.email, password: login_password } }

    subject { post :create, params }

    context 'for grant_type "password"' do
      context 'with valid user credentials' do
        context 'for a verified login' do
          it 'succeeds' do
            subject

            expect(response).to have_http_status(200)
          end

          it 'responds with an access token' do
            subject

            expect(JSON.parse(response.body).symbolize_keys).to eql({ access_token: login.oauth2_token })
          end
        end
      end

      context 'for an unverified login' do
        let(:login) { create(:login, password: login_password) }

        it 'responds with status 400' do
          subject

          expect(response).to have_http_status(400)
        end

        it 'responds with a verification missing error' do
          subject

          expect(JSON.parse(response.body).symbolize_keys).to eql({ error: 'verification_missing' })
        end
      end

      context 'with invalid user credentials' do
        let(:params) { { grant_type: 'password', username: 'bad@email.com', password: 'badpassword' } }

        subject { post :create, params }

        it 'responds with status 400' do
          subject

          expect(response).to have_http_status(400)
        end

        it 'responds with an invalid grant error' do
          subject

          expect(JSON.parse(response.body).symbolize_keys).to eql({ error: 'invalid_grant' })
        end
      end
    end

    context 'for grant_type "facebook_auth_code"' do
      let(:secret)                { described_class::FB_APP_SECRET }
      let(:params)                { { grant_type: 'facebook_auth_code', auth_code: 'fb auth code' } }
      let(:facebook_verification) { true }
      let(:facebook_email)        { login.email }
      let(:facebook_attributes)   { { id: '1238190321', email: facebook_email, verified: facebook_verification } }

      before do
        stub_request(:get, %r{https://graph.facebook.com/v2.3/oauth/access_token}).to_return(body: '{ "access_token": "access_token" }')
        stub_request(:get, %r{https://graph.facebook.com/v2.3/me}).to_return(body: JSON.generate(facebook_attributes), headers: { 'Content-Type' => 'application/json' })
      end

      context 'when a login for the Facebook email exists' do
        context 'for an unverified login' do
          let(:login) { create(:login, :password) }

          context 'for a verified Facebook account' do
            let(:facebook_verification) { true }

            it 'verifies the login' do
              allow(Login).to receive(:find_by).with(email: facebook_attributes[:email]).and_return login

              expect(login).to receive(:verify!).once

              subject
            end

            it 'connects the login to the Facebook account' do
              subject

              expect(login.reload.facebook_uid).to eq(facebook_attributes[:id])
            end

            it 'succeeds' do
              subject

              expect(response).to have_http_status(200)
            end

            it 'responds with an oauth2 token' do
              subject

              expect(JSON.parse(response.body).symbolize_keys).to eql({ access_token: login.oauth2_token })
            end
          end

          context 'for an unverified Facebook account' do
            let(:facebook_verification) { false }

            it 'connects the login to the Facebook account' do
              subject

              expect(login.reload.facebook_uid).to eq(facebook_attributes[:id])
            end

            it 'responds with a verification missing error' do
              subject

              expect(JSON.parse(response.body).symbolize_keys).to eql({ error: 'verification_missing' })
            end
          end
        end

        context 'for a verified login' do
          context 'for a verified Facebook account' do
            let(:facebook_verification) { true }

            it 'connects the login to the Facebook account' do
              subject

              expect(login.reload.facebook_uid).to eq(facebook_attributes[:id])
            end

            it 'succeeds' do
              subject

              expect(response).to have_http_status(200)
            end

            it 'responds with an oauth2 token' do
              subject

              expect(JSON.parse(response.body).symbolize_keys).to eql({ access_token: login.oauth2_token })
            end
          end

          context 'for an unverified Facebook account' do
            let(:facebook_verification) { false }

            it 'connects the login to the Facebook account' do
              subject

              expect(login.reload.facebook_uid).to eq(facebook_attributes[:id])
            end

            it 'responds with a facebook verification missing error' do
              subject

              expect(JSON.parse(response.body).symbolize_keys).to eql({ error: 'facebook_verification_missing' })
            end
          end
        end
      end

      context 'when no login for the Facebook email exists' do
        let(:facebook_email) { Faker::Internet.email }

        it 'creates a login for the Facebook email' do
          expect { subject }.to change { Login.where(email: facebook_email).count }.by(1)
        end

        context 'for a verified Facebook account' do
          let(:facebook_verification) { true }

          it 'verifies the login' do
            subject
            login = Login.find_by(email: facebook_email)

            expect(login).to be_verified
          end

          it 'succeeds' do
            subject

            expect(response).to have_http_status(200)
          end

          it 'responds with an oauth2 token' do
            subject
            login = Login.find_by(email: facebook_email)

            expect(JSON.parse(response.body).symbolize_keys).to eql({ access_token: login.oauth2_token })
          end
        end

        context 'for an unverified Facebook account' do
          let(:facebook_verification) { false }

          it 'responds with a verification missing error' do
            subject

            expect(JSON.parse(response.body).symbolize_keys).to eql({ error: 'facebook_verification_missing' })
          end
        end
      end

      context 'when no facebook code is sent' do
        let(:params) { { grant_type: 'facebook_auth_code' } }

        it 'responds with status 400' do
          subject

          expect(response).to have_http_status(400)
        end

        it 'responds with a no authorization code error' do
          subject

          expect(JSON.parse(response.body).symbolize_keys).to eql({ error: 'no_authorization_code' })
        end
      end

      context 'when Facebook responds with an error' do
        before do
          stub_request(:get, %r{https://graph.facebook.com/v2.3/oauth/access_token}).to_return(status: 422)
        end

        it 'responds with status 500' do
          subject

          expect(response).to have_http_status(500)
        end

        it 'responds with an empty response body' do
          subject

          expect(response.body).to eql('')
        end
      end
    end

    context 'for an unknown grant type' do
      let(:params) { { grant_type: 'UNKNOWN' } }

      it 'responds with status 400' do
        subject

        expect(response).to have_http_status(400)
      end

      it 'responds with an invalid grant error' do
        subject

        expect(JSON.parse(response.body).symbolize_keys).to eql({ error: 'unsupported_grant_type' })
      end
    end
  end

  describe 'POST #destroy' do
    let(:login)  { double('login') }
    let(:token)  { 'bearer token' }
    let(:params) { { token_type_hint: 'access_token', token: 'oauth2_token' } }

    subject { post :destroy, params }

    before do
      allow(Login).to receive(:find_by).with(oauth2_token: params[:token]).and_return login
      allow(login).to receive(:refresh_oauth2_token!)
    end

    context 'for a known token' do
      it 'succeeds' do
        subject

        expect(response).to have_http_status(200)
      end

      it 'resets login token' do
        expect(login).to receive(:refresh_oauth2_token!)

        subject
      end
    end
  end
end
