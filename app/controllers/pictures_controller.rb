class PicturesController < ApplicationController
  def index
    @pictures = Picture.all.page(params[:page_id]).per(5)

  end

  def new
  end

  def edit
  end

  def destroy

  end

  def show

  end
end
