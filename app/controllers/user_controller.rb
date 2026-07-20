class UserController < ApplicationController
  skip_before_action :authenticate_user, only: [ :create, :verify_signup, :resend_otp ]

  def create
    # Destroying the existing email after sendotp fails
    PendingSignup.where(email: signup_params[:email]).destroy_all
    pending_signup = PendingSignup.new(signup_params)
    if User.exists?(email: pending_signup.email)
    return render json: { error: "Email already registered" }, status: :unprocessable_entity
    end
    if pending_signup.save
    # send OTP email
    UserMailer.signup_otp(pending_signup).deliver_now
    render json: { message: "OTP sent to email" }, status: :created
    else
    render json: { errors: pending_signup.errors.full_messages }, status: :unprocessable_entity
    end
  end
  def me
    render json: @current_user, serializer: UserSerializer
  end

  # Verifying the email of the user via pin
  def verify_signup
  pending_signup = PendingSignup.find_by(email: params[:email])
  unless pending_signup&.verify_otp?(params[:otp])
    return render json: { error: "Invalid or expired OTP"
    }, status: :unprocessable_entity
  end

  user = User.create!(
    username: pending_signup.username,
    email: pending_signup.email,
    password_digest: pending_signup.password_digest
  )

  pending_signup.destroy

  token = JsonWebToken.encode(user_id: user.id)

  # Creates a cookie
  cookies.signed[:auth_token] = {
      value: token,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax,
      expires: 24.hours.from_now
    }


  render json: {
    user: UserSerializer.new(user),
    token: token,
    message: "Signup completed"
  }, status: :created
  end

  # Resending the otp
  def resend_otp
    # Finding existing email on the pendingsignup
    pending_signup = PendingSignup.find_by(email: params[:email])

    unless pending_signup
      return render json: { error: "Pending signup not found" }, status: :not_found
    end

    pending_signup.resend_otp!
    UserMailer.signup_otp(pending_signup).deliver_now
    render json: { message: "OTP sent again" }, status: :ok
  end
  # Forget password

  private
  # User parameter for the user creation
  def signup_params
    params.permit(:username, :email, :password, :password_confirmation)
  end
end
