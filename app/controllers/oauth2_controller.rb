class Oauth2Controller < ApplicationController

  class LoginNotFound

    def authenticate(_)
      false
    end

    def refresh_oauth2_token!; end

  end

  class FacebookApiError < StandardError; end

  def create
    case params[:grant_type]
    when 'password'
      authenticate_with_credentials(params[:username], params[:password])
    when 'facebook_auth_code'
      authenticate_with_facebook(params[:auth_code])
    else
      oauth2_error('unsupported_grant_type')
    end
  end

  def destroy
    oauth2_error('unsupported_token_type') && return unless params[:token_type_hint] == 'access_token'

    login = Login.find_by(oauth2_token: params[:token]) || LoginNotFound.new
    login.refresh_oauth2_token!

    head 200
  end

  private

    def authenticate(login)
      if login.verified?
        render json: { access_token: login.oauth2_token }
      else
        oauth2_error('verification_missing')
      end
    end

    def authenticate_with_credentials(email, password)
      login = find_login_by_email(email) || LoginNotFound.new
      if login.authenticate(password)
        authenticate(login)
      else
        oauth2_error('invalid_grant')
      end
    end

    def authenticate_with_facebook(auth_code)
      oauth2_error('no_authorization_code') && return unless auth_code.present?

      facebook_user = facebook_user(auth_code)
      login         = find_login_by_email(facebook_user[:email])

      if login
        connect_login_to_facebook_account(login, facebook_user)
      else
        create_login_from_facebook_account(facebook_user)
      end
    rescue FacebookApiError
      render nothing: true, status: 500
    end

    def connect_login_to_facebook_account(login, facebook_user)
      login.update_attributes!(facebook_uid: facebook_user[:id])
      if facebook_user[:verified]
        login.verify! unless login.verified?
        authenticate(login)
      else
        error = login.verified? ? 'facebook_verification_missing' : 'verification_missing'
        oauth2_error(error)
      end
    end

    def create_login_from_facebook_account(facebook_user)
      login = Login.create!(email: facebook_user[:email], facebook_uid: facebook_user[:id])
      login.verify!
      if facebook_user[:verified]
        authenticate(login)
      else
        oauth2_error('facebook_verification_missing')
      end
    end

    def find_login_by_email(email)
      Login.find_by(email: email)
    end

    def oauth2_error(error)
      render json: { error: error }, status: 400
    end

    def facebook_request(url)
      response = HTTParty.get(url)
      raise FacebookApiError.new if response.code != 200
      response
    end

    def facebook_user(auth_code)
      token_response = facebook_request("https://graph.facebook.com/v2.3/oauth/access_token?client_id=#{Rails.configuration.x.facebook.app_id}&redirect_uri=http%3A%2F%2Flocalhost%3A4200%2Flogin&client_secret=#{Rails.configuration.x.facebook.app_secret}&code=#{auth_code}")
      access_token   = token_response.parsed_response['access_token']
      user_response  = facebook_request("https://graph.facebook.com/v2.3/me?access_token=#{access_token}")
      user_response.parsed_response.symbolize_keys
    end

end
