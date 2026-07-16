class NoteController < ApplicationController
  # Showing all the current user notes
  def index
    notes = @current_user.notes
    render json: notes, status: :ok
  end
  # Showing only the current user note by id
  def show
    note = @current_user.notes.find(params[:id])
    render json: note, status: :ok
  end
  # Creating a new note
  def create
    note = @current_user.notes.new(note_params)
    if note.save
      render json: note, status: :created
    else
      render json:{error:note.errors.full_messages},status: :unprocessable_entity
    end
  end
  # Updating the note
  def update
    note = @current_user.notes.find(params[:id])
    if note.update(note_params)
      render json: note, status: :ok
    else
      render json: {error: note.errors.full_messages},status: :unprocessable_entity
    end
  end

  # Deleting the note
  def destroy
    note = @current_user.notes.find(params[:id])
    if note.destroy
      render json: note, status: :ok
    else
      render json: {error: note.errors.full_messages},status: :unprocessable_entity
    end
  end

  private
  def note_params
    params.permit(:title,:note)
  end
end
