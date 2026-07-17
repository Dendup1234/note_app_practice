# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Notes API", type: :request do
  let(:user) do
    User.create!(
      username: "noteuser",
      email: "noteuser@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: user.id)}" }

  path "/note" do
    get "Lists notes for the authenticated user" do
      tags "Notes"
      produces "application/json"
      security [ { bearer_auth: [] }, { cookie_auth: [] } ]

      response "200", "notes found" do
        schema type: :array, items: { "$ref" => "#/components/schemas/note" }

        before do
          user.notes.create!(title: "First note", note: "This belongs to the logged-in user.")
        end

        run_test!
      end

      response "401", "unauthorized" do
        schema "$ref" => "#/components/schemas/error"

        let(:Authorization) { nil }

        run_test!
      end
    end

    post "Creates a note for the authenticated user" do
      tags "Notes"
      consumes "application/json"
      produces "application/json"
      security [ { bearer_auth: [] }, { cookie_auth: [] } ]

      parameter name: :note_params, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string, example: "Meeting notes" },
          note: { type: :string, example: "Discuss API documentation and note CRUD." }
        },
        required: [ "title", "note" ]
      }

      response "201", "note created" do
        schema "$ref" => "#/components/schemas/note"

        let(:note_params) do
          {
            title: "Meeting notes",
            note: "Discuss API documentation and note CRUD."
          }
        end

        run_test!
      end

      response "401", "unauthorized" do
        schema "$ref" => "#/components/schemas/error"

        let(:Authorization) { nil }
        let(:note_params) do
          {
            title: "Meeting notes",
            note: "Discuss API documentation and note CRUD."
          }
        end

        run_test!
      end
    end
  end

  path "/note/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "Note ID"

    get "Shows one note owned by the authenticated user" do
      tags "Notes"
      produces "application/json"
      security [ { bearer_auth: [] }, { cookie_auth: [] } ]

      response "200", "note found" do
        schema "$ref" => "#/components/schemas/note"

        let(:id) { user.notes.create!(title: "Private note", note: "Only this user can fetch it.").id }

        run_test!
      end

      response "401", "unauthorized" do
        schema "$ref" => "#/components/schemas/error"

        let(:Authorization) { nil }
        let(:id) { 1 }

        run_test!
      end
    end

    patch "Updates one note owned by the authenticated user" do
      tags "Notes"
      consumes "application/json"
      produces "application/json"
      security [ { bearer_auth: [] }, { cookie_auth: [] } ]

      parameter name: :note_params, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string, example: "Updated title" },
          note: { type: :string, example: "Updated note body." }
        }
      }

      response "200", "note updated" do
        schema "$ref" => "#/components/schemas/note"

        let(:id) { user.notes.create!(title: "Old title", note: "Old body").id }
        let(:note_params) do
          {
            title: "Updated title",
            note: "Updated note body."
          }
        end

        run_test!
      end
    end

    put "Replaces one note owned by the authenticated user" do
      tags "Notes"
      consumes "application/json"
      produces "application/json"
      security [ { bearer_auth: [] }, { cookie_auth: [] } ]

      parameter name: :note_params, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string, example: "Replacement title" },
          note: { type: :string, example: "Replacement note body." }
        },
        required: [ "title", "note" ]
      }

      response "200", "note replaced" do
        schema "$ref" => "#/components/schemas/note"

        let(:id) { user.notes.create!(title: "Old title", note: "Old body").id }
        let(:note_params) do
          {
            title: "Replacement title",
            note: "Replacement note body."
          }
        end

        run_test!
      end
    end

    delete "Deletes one note owned by the authenticated user" do
      tags "Notes"
      produces "application/json"
      security [ { bearer_auth: [] }, { cookie_auth: [] } ]

      response "200", "note deleted" do
        schema "$ref" => "#/components/schemas/note"

        let(:id) { user.notes.create!(title: "Delete me", note: "Temporary note").id }

        run_test!
      end
    end
  end
end
