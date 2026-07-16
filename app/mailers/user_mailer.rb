class UserMailer < ApplicationMailer
  def signup_otp(pending_signup)
  @pending_signup = pending_signup
  mail(to: @pending_signup.email, subject: "Your signup OTP")
  end

  def password_reset_otp(user)
  @user = user
  mail(to: @user.email, subject: "Password Reset OTP")
  end
end
