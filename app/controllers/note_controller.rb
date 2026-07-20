class NoteController < ApplicationController
  # Adding the Url helper
  include Rails.application.routes.url_helpers

  # Showing all the current user notes
  def index
    notes = @current_user.notes
    render json: notes.map { |note| note_response(note) }, status: :ok
  end
  # Showing only the current user note by id
  def show
    note = @current_user.notes.find(params[:id])
    render json: note_response(note), status: :ok
  end
  # Creating a new note
  def create
    note = @current_user.notes.new(note_params)
    if note.save
      render json: note_response(note), status: :created
    else
      render json: { error: note.errors.full_messages }, status: :unprocessable_entity
    end
  end
  # Updating the note
  def update
    note = @current_user.notes.find(params[:id])
    if note.update(note_params)
      render json: note_response(note), status: :ok
    else
      render json: { error: note.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Deleting the note
  def destroy
    note = @current_user.notes.find(params[:id])
    if note.destroy
      render json: note, status: :ok
    else
      render json: { error: note.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private
  def note_params
    params.permit(:title, :note, :notes)
  end
  # Shaping up the response
  def note_response(note)
    {
      id: note.id,
      title: note.title,
      note: note.note,
      user_id: note.user_id,
      created_at: note.created_at,
      updated_at: note.updated_at,
      attachment: note.notes.attached? ? rails_blob_url(note.notes, host: request.base_url) : nil
    }
  end
end
