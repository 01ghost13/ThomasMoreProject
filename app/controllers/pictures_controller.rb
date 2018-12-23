class PicturesController < ApplicationController
  before_action :check_log_in
  before_action :check_super_admin

  #Page of list of pictures
  def index
    @pictures = Picture.with_attached_image.includes(:picture_interests).order(:created_at).reverse_order.page(params[:page]).per(5)
  end

  #Create picture page
  def new
    @picture = Picture.new
    @interests = Interest.interests_list
  end

  #Action for create
  def create
    @picture = Picture.new(picture_params)

    respond_to do |types|
      types.json do
        if @picture.save
          flash[:success] = 'Picture created!'
          render json: { response: { type: :success, message: 'Picture created!' } }, status: :ok
        else
          render json: { response: { type: :error, errors: @picture.errors } }, status: :bad_request
        end
      end
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

    respond_to do |types|
      types.json do
        if @picture.update(picture_params)
          flash[:success] = 'Picture updated!'
          render json: { response: { type: :success } }, status: :ok
        else
          render json: { response: { type: :error, errors: @picture.errors } }, status: :bad_request
        end
      end
    end
  end

  #Action for deleting Picture
  def destroy
    picture = Picture.find(params[:id])
    if picture.destroy
      flash[:success] = 'Picture deleted!'
      redirect_to pictures_path, status: 200
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
      :description,
      :image,
      picture_interests_attributes: [
        :interest_id,
        :earned_points,
        :_destroy,
        :id
      ]
    )
  end
end
