class AuthController < ApplicationController
  before_action :authenticate_password_reset_token, only: [ :reset_password ]
  skip_before_action :authenticate_user
  # Forgot password send otp
  def forgot_password
  user = User.find_by(email: params[:email])

  if user
    reset_otp = rand(100000..999999).to_s

    user.update!(
      reset_otp: reset_otp,
      reset_otp_sent_at: Time.current
    )

    UserMailer.password_reset_otp(user).deliver_now
  end

  render json: {
    message: "If this email exists, a reset OTP was sent"
  }, status: :ok
end

# Reset password verify with otp and set new password
def verify_password_reset_otp
  user = User.find_by(email: params[:email])

  unless user
    return render json: { error: "Invalid email or OTP" }, status: :unprocessable_entity
  end

  otp_expired =
    user.reset_otp_sent_at.blank? ||
    user.reset_otp_sent_at < 10.minutes.ago

  unless user.reset_otp.to_s == params[:otp].to_s && !otp_expired
    return render json: { error: "Invalid or expired OTP" }, status: :unprocessable_entity
  end

  reset_token = JsonWebToken.encode(
    {
      user_id: user.id,
      purpose: "password_reset"
    },
    15.minutes.from_now
  )

  user.update!(
    reset_otp: nil,
    reset_otp_sent_at: nil
  )

  render json: {
    message: "OTP verified",
    reset_token: reset_token
  }, status: :ok
end

# Reset password
def reset_password
  if @reset_user.update(
    password: params[:password],
    password_confirmation: params[:password_confirmation]
  )
    render json: { message: "Password reset successful" }, status: :ok
  else
    render json: { errors: @reset_user.errors.full_messages }, status: :unprocessable_entity
  end
end


  def login
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
    token = JsonWebToken.encode(user_id: user.id)

    render json: {
      user: UserSerializer.new(user),
      token: token
    }, status: :ok
    else
    render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end
end
