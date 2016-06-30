class DocumentsController < ApplicationController
  before_action :set_note, only: [:show, :update, :destroy]

  # GET /notes
  # def index
  #   sleep 1
  #   @notes = Note.all
  #
  #   render json: @notes
  # end
  #
  # # GET /notes/1
  # def show
  #   render json: @note
  # end
  #
  # # POST /notes
  # def create
  #   @note = Note.new(note_params)
  #   sleep 2
  #   render(json: { error: true, message: "Error from API" }, status: 500) and return if rand(0..100) % 3 == 0
  #   if @note.save
  #     render json: @note, status: :created, location: @note
  #   else
  #     render json: @note.errors, status: :unprocessable_entity
  #   end
  # end
  #
  # # PATCH/PUT /notes/1
  # def update
  #   sleep 1
  #   render(json: { error: true, message: "Error from API" }, status: 500) and return if rand(0..100) % 3 == 0
  #   if @note.update(note_params)
  #     render json: @note
  #   else
  #     render json: @note.errors, status: :unprocessable_entity
  #   end
  # end
  #
  # # DELETE /notes/1
  # def destroy
  #   @note.destroy
  # end
  #
  # private
  #   # Use callbacks to share common setup or constraints between actions.
  #   def set_note
  #     @note = Note.find(params[:id])
  #   end
  #
  #   # Only allow a trusted parameter "white list" through.
  #   def note_params
  #     params.permit(:text)
  #   end
end
