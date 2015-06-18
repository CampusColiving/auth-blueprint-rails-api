class FacebookAuthenticator

  def initialize(auth_code)
    @auth_code = auth_code
  end

  def authenticate
    if login.present?
      connect_login_to_fb_account
    else
      create_login_from_fb_account
    end

    login
  end

  private

    def login
      @login ||= Login.find_by(email: facebook_user[:email])
    end

    def connect_login_to_fb_account
      raise FacebookVerificationMissing unless facebook_user[:verified]

      login.update_attributes!(facebook_uid: facebook_user[:id])
      login.verify! unless login.verified?
    end

    def create_login_from_fb_account
      login_attributes = {
        email:        facebook_user[:email],
        facebook_uid: facebook_user[:id]
      }

      @login = Login.create!(login_attributes)

      @login.verify! if facebook_user[:verified]
    end

    def facebook_user
      @facebook_user ||= begin
        access_token = facebook_request(fb_token_url).parsed_response['access_token']
        facebook_request(fb_user_url(access_token)).parsed_response.symbolize_keys
      end
    end

    def facebook_request(url)
      response = HTTParty.get(url)
      raise FacebookApiError.new if response.code != 200
      response
    end

    # rubocop:disable Metrics/AbcSize
    def fb_token_url
      format('%{graph_url}/oauth/access_token?client_id=%{client_id}&redirect_uri=%{redirect_uri}&client_secret=%{client_secret}&code=%{code}', {
        graph_url:     Rails.application.config.x.facebook.graph_url,
        client_id:     Rails.application.config.x.facebook.app_id,
        redirect_uri:  Rails.application.config.x.facebook.redirect_uri,
        client_secret: Rails.application.config.x.facebook.app_secret,
        code:          @auth_code
      })
    end
    # rubocop:enable Metrics/AbcSize

    def fb_user_url(access_token)
      "#{Rails.application.config.x.facebook.graph_url}/me?access_token=#{access_token}"
    end

end
