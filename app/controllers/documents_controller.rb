class DocumentsController < ApplicationController

  def index
    create
  end

  def show
    @document = Document.find params[:id]
    render json: @document
  end

  def create
    @document = Document.create(url: Document.generate_url)
    render json: {@document.id => @document.url}
  end

end
# render json: {"Yeeee" => "Bitches"}
