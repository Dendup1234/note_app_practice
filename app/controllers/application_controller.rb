class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  before_action :authenticate_user

  private
  # Checking the authenticated user's token
  def authenticate_user
    header  = request.headers["Authorization"]
    token   = header&.split(" ")&.last
    payload = JsonWebToken.decode(token)

    @current_user = User.find_by(id: payload["user_id"]) if payload
    render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
  end
  # Checking the reset token user
  def authenticate_password_reset_token
    token = request.headers["X-Reset-Token"]
    payload = JsonWebToken.decode(token)
    unless payload && payload["purpose"] == "password_reset"
      return render json: { error: "Invalid reset token" }, status: :unauthorized
    end
    @reset_user = User.find_by(id: payload["user_id"])
    unless @reset_user
      render json: { error: "Invalid reset token" }, status: :unauthorized
    end
  end
end
