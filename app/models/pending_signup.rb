class PendingSignup < ApplicationRecord
  has_secure_password

  validates :username, presence: true
  validates :email, presence: true

  before_create :set_otp
  before_create :set_expiry

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  def verify_otp?(submitted_otp)
    otp.to_s == submitted_otp.to_s && !expired?
  end

  def resend_otp!
    update!(
      otp: rand(100000..999999).to_s,
      otp_sent_at: Time.current,
      expires_at: 10.minutes.from_now
    )
  end

  private

  def set_otp
    self.otp = rand(100000..999999).to_s
    self.otp_sent_at = Time.current
  end

  def set_expiry
    self.expires_at = 10.minutes.from_now
  end
end
