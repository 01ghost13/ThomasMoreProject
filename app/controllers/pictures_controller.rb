class PicturesController < ApplicationController
  before_action :check_log_in
  before_action :check_super_admin

  #Page of list of pictures
  def index
    @pictures = Picture.order(:created_at).reverse_order.page(params[:page]).per(5)
  end

  #Create picture page
  def new
    @picture = Picture.new
    picture_interests = [PictureInterest.new]
    @picture.picture_interests << picture_interests
    @interests = Interest.interests_list
  end

  #Action for create
  def create
    @picture = Picture.new(picture_params)
    @interests = Interest.interests_list
    if @picture.save
      flash[:success] = 'Picture created!'
      redirect_to pictures_path
    else
      @user = @picture
      render :new
    end
  end

  #Page for edit picture
  def edit
    @picture = Picture.find(params[:id])
    @interests = Interest.interests_list
  end

  #Action for edit
  def update
    @picture = Picture.find(params[:id])
    if @picture.update(picture_params)
      flash[:success] = 'Picture updated!'
      redirect_to pictures_path
    else
      @user = @picture
      @interests = Interest.interests_list
      render :edit
    end
  end

  #Action for deleting Picture
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
  ##########################################################
  #Private methods
  private
  #Attributes for forms
  def picture_params
    params.require(:picture).permit(
        :description, :image, picture_interests_attributes: [
        :interest_id, :earned_points, :_destroy, :id])
  end
end
