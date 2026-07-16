# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Authentication API", type: :request do
  before do
    mail = instance_double(ActionMailer::MessageDelivery, deliver_now: true)
    allow(UserMailer).to receive(:password_reset_otp).and_return(mail)
  end

  path "/login" do
    post "Logs in a user and returns a JWT" do
      tags "Authentication"
      consumes "application/json"
      produces "application/json"

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, format: :email, example: "dendup@example.com" },
          password: { type: :string, format: :password, example: "password123" }
        },
        required: [ "email", "password" ]
      }

      response "200", "logged in" do
        schema type: :object,
          properties: {
            user: { "$ref" => "#/components/schemas/user" },
            token: { type: :string }
          }

        before do
          User.create!(
            username: "login",
            email: "login@example.com",
            password: "password123",
            password_confirmation: "password123"
          )
        end

        let(:credentials) { { email: "login@example.com", password: "password123" } }

        run_test!
      end

      response "401", "invalid email or password" do
        schema "$ref" => "#/components/schemas/error"

        let(:credentials) { { email: "missing@example.com", password: "wrong" } }

        run_test!
      end
    end
  end

  path "/password/forgot" do
    post "Sends a password reset OTP" do
      tags "Password Reset"
      consumes "application/json"
      produces "application/json"

      parameter name: :forgot_password, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, format: :email, example: "dendup@example.com" }
        },
        required: [ "email" ]
      }

      response "200", "reset OTP sent if the email exists" do
        schema "$ref" => "#/components/schemas/message"

        before do
          User.create!(
            username: "forgot",
            email: "forgot@example.com",
            password: "password123",
            password_confirmation: "password123"
          )
        end

        let(:forgot_password) { { email: "forgot@example.com" } }

        run_test!
      end
    end
  end

  path "/password/verify-otp" do
    post "Verifies reset OTP and returns a reset token" do
      tags "Password Reset"
      consumes "application/json"
      produces "application/json"

      parameter name: :password_reset_otp, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, format: :email, example: "dendup@example.com" },
          otp: { type: :string, example: "123456" }
        },
        required: [ "email", "otp" ]
      }

      response "200", "OTP verified" do
        schema type: :object,
          properties: {
            message: { type: :string },
            reset_token: { type: :string }
          }

        before do
          User.create!(
            username: "resetotp",
            email: "resetotp@example.com",
            password: "password123",
            password_confirmation: "password123",
            reset_otp: "123456",
            reset_otp_sent_at: Time.current
          )
        end

        let(:password_reset_otp) { { email: "resetotp@example.com", otp: "123456" } }

        run_test!
      end

      response "422", "invalid or expired OTP" do
        schema "$ref" => "#/components/schemas/error"

        let(:password_reset_otp) { { email: "missing@example.com", otp: "000000" } }

        run_test!
      end
    end
  end

  path "/password/reset" do
    post "Resets password using reset token header" do
      tags "Password Reset"
      consumes "application/json"
      produces "application/json"
      security [ reset_token: [] ]

      parameter name: "X-Reset-Token", in: :header, type: :string, required: true,
        description: "Short-lived JWT returned by /password/verify-otp"
      parameter name: :new_password, in: :body, schema: {
        type: :object,
        properties: {
          password: { type: :string, format: :password, example: "newpassword123" },
          password_confirmation: { type: :string, format: :password, example: "newpassword123" }
        },
        required: [ "password", "password_confirmation" ]
      }

      response "200", "password reset successful" do
        schema "$ref" => "#/components/schemas/message"

        let(:user) do
          User.create!(
            username: "newpass",
            email: "newpass@example.com",
            password: "password123",
            password_confirmation: "password123"
          )
        end
        let(:"X-Reset-Token") do
          JsonWebToken.encode({ user_id: user.id, purpose: "password_reset" }, 15.minutes.from_now)
        end
        let(:new_password) do
          {
            password: "newpassword123",
            password_confirmation: "newpassword123"
          }
        end

        run_test!
      end

      response "401", "invalid reset token" do
        schema "$ref" => "#/components/schemas/error"

        let(:"X-Reset-Token") { "invalid-token" }
        let(:new_password) do
          {
            password: "newpassword123",
            password_confirmation: "newpassword123"
          }
        end

        run_test!
      end
    end
  end
end
