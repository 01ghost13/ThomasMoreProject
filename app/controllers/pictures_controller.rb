class PicturesController < ApplicationController
  def index
    @pictures = Picture.order(:created_at).reverse_order.page(params[:page]).per(5)
  end

  def new
    @picture = Picture.new
    picture_interests = [PictureInterest.new]
    @picture.picture_interests << picture_interests
    @interests = Interest.interests_list
    @count = picture_interests.count
  end

  def create
    @picture = Picture.new(picture_params)
    @interests = Interest.interests_list
    if @picture.save
      flash[:success] = 'Picture created!'
      redirect_to :pictures
    else
      @user = @picture
      render :new
    end
  end

  def edit

  end

  def update

  end

  def destroy
    picture = Picture.find(params[:id])
    if picture.destroy
      flash[:success] = 'Picture deleted!'
      redirect_to pictures_path
    else
      @user = picture
      index
      render :index
    end
  end

  def show

  end

  private
    def picture_params
      p_params = params.require(:picture).permit(
          :description, :image, picture_interests_attributes: [
          :interest_id, :earned_points, :_destroy, :id])
    end
end
