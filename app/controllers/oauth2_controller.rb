require 'login_not_found'

class Oauth2Controller < ApplicationController

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

    def authenticate_with_credentials(email, password)
      login = Login.find_by(email: email) || LoginNotFound.new

      if login.authenticate(password)
        render json: { access_token: login.oauth2_token }
      else
        oauth2_error('invalid_grant')
      end
    end

    def authenticate_with_facebook(auth_code)
      oauth2_error('no_authorization_code') && return unless auth_code.present?

      login = FacebookAuthenticator.new(auth_code).authenticate

      render json: { access_token: login.oauth2_token }

    rescue FacebookVerificationMissing
      oauth2_error('facebook_verification_missing')
    rescue FacebookApiError
      render nothing: true, status: 500
    end

    def oauth2_error(error)
      render json: { error: error }, status: 400
    end

end
