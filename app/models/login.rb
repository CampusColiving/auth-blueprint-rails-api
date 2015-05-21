class Login < ActiveRecord::Base

  class AlreadyVerifiedError < StandardError; end

  has_secure_password validations: false

  validates :email, presence: true, email: true
  validates :oauth2_token, presence: true
  validates :password, length: { maximum: ActiveModel::SecurePassword::MAX_PASSWORD_LENGTH_ALLOWED }, confirmation: true
  validate :password_or_facebook_uid_present

  before_validation :ensure_oauth2_token

  def refresh_oauth2_token!
    ensure_oauth2_token(true)
    save!
  end

  def verified?
    verified_at.present? && verified_at <= Time.zone.now
  end

  def verify!
    raise AlreadyVerifiedError.new if verified_at.present?

    self.verified_at = Time.zone.now
    save!
  end

  private

    def password_or_facebook_uid_present
      if password_digest.blank? && facebook_uid.blank?
        errors.add :base, 'either password_digest or facebook_uid must be present'
      end
    end

    def ensure_oauth2_token(force = false)
      set_token = oauth2_token.blank? || force
      self.oauth2_token = SecureRandom.hex(125) if set_token
    end

end
