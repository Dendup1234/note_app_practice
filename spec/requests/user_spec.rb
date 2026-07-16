# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Signup and User API", type: :request do
  before do
    mail = instance_double(ActionMailer::MessageDelivery, deliver_now: true)
    allow(UserMailer).to receive(:signup_otp).and_return(mail)
  end

  path "/users" do
    post "Starts signup and sends an OTP" do
      tags "Signup"
      consumes "application/json"
      produces "application/json"

      parameter name: :signup, in: :body, schema: {
        type: :object,
        properties: {
          username: { type: :string, example: "dendup" },
          email: { type: :string, format: :email, example: "dendup@example.com" },
          password: { type: :string, format: :password, example: "password123" },
          password_confirmation: { type: :string, format: :password, example: "password123" }
        },
        required: [ "username", "email", "password", "password_confirmation" ]
      }

      response "201", "OTP sent to email" do
        schema "$ref" => "#/components/schemas/message"

        let(:signup) do
          {
            username: "dendup",
            email: "dendup@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        end

        run_test!
      end

      response "422", "email already registered" do
        schema "$ref" => "#/components/schemas/error"

        before do
          User.create!(
            username: "existing",
            email: "existing@example.com",
            password: "password123",
            password_confirmation: "password123"
          )
        end

        let(:signup) do
          {
            username: "existing2",
            email: "existing@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        end

        run_test!
      end
    end
  end

  path "/signup/verify" do
    post "Verifies signup OTP and creates the real user" do
      tags "Signup"
      consumes "application/json"
      produces "application/json"

      parameter name: :verification, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, format: :email, example: "dendup@example.com" },
          otp: { type: :string, example: "123456" }
        },
        required: [ "email", "otp" ]
      }

      response "201", "signup completed" do
        schema type: :object,
          properties: {
            user: { "$ref" => "#/components/schemas/user" },
            token: { type: :string },
            message: { type: :string }
          }

        let!(:pending_signup) do
          PendingSignup.create!(
            username: "dendup",
            email: "verify@example.com",
            password: "password123",
            password_confirmation: "password123"
          )
        end

        let(:verification) do
          {
            email: pending_signup.email,
            otp: pending_signup.otp
          }
        end

        run_test!
      end

      response "422", "invalid or expired OTP" do
        schema "$ref" => "#/components/schemas/error"

        let(:verification) do
          {
            email: "missing@example.com",
            otp: "000000"
          }
        end

        run_test!
      end
    end
  end

  path "/signup/resend-otp" do
    post "Resends signup OTP" do
      tags "Signup"
      consumes "application/json"
      produces "application/json"

      parameter name: :resend_otp, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, format: :email, example: "dendup@example.com" }
        },
        required: [ "email" ]
      }

      response "200", "OTP sent again" do
        schema "$ref" => "#/components/schemas/message"

        let!(:pending_signup) do
          PendingSignup.create!(
            username: "resend",
            email: "resend@example.com",
            password: "password123",
            password_confirmation: "password123"
          )
        end

        let(:resend_otp) { { email: pending_signup.email } }

        run_test!
      end

      response "404", "pending signup not found" do
        schema "$ref" => "#/components/schemas/error"

        let(:resend_otp) { { email: "missing@example.com" } }

        run_test!
      end
    end
  end

  path "/me" do
    get "Returns the current authenticated user" do
      tags "User"
      produces "application/json"
      security [ bearer_auth: [] ]

      response "200", "current user" do
        schema "$ref" => "#/components/schemas/user"

        let(:user) do
          User.create!(
            username: "me",
            email: "me@example.com",
            password: "password123",
            password_confirmation: "password123"
          )
        end
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: user.id)}" }

        run_test!
      end

      response "401", "unauthorized" do
        schema "$ref" => "#/components/schemas/error"

        let(:Authorization) { nil }

        run_test!
      end
    end
  end
end
