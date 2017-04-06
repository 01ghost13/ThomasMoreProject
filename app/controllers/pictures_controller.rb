class PicturesController < ApplicationController
  before_action :check_log_in
  before_action :check_rights
  
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
      redirect_to pictures_path
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
  def check_log_in
    unless logged_in?
      flash[:warning] = 'Only registrated people can see this page.'
      #Redirecting to home page
      redirect_to :root
    end
  end

  #Callback for checking rights
  def check_rights
    #Only SA
    unless is_super?
      flash[:warning] = 'You have no access to this page.'
      #Redirect
      redirect_to current_user
    end
  end
end
