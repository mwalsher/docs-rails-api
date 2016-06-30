class DocumentsController < ApplicationController

  def index
    create
  end

  def show
    @document = Document.find params[:id]
    render json: @document
  end

  def create
    @document = Document.create
    render json: @document.id
  end

end
# render json: {"Yeeee" => "Bitches"}
