class DocumentsController < ApplicationController

  def index
    params[:doc].present? ? show : create
  end

  def show
    @document = Document.find_by(url: params[:doc])
    render json: @document
  end

  def create
    @document = Document.create(url: Document.generate_url)
    render json: {@document.id => @document.url_share}
  end

end
# render json: {"Yeeee" => "Bitches"}
