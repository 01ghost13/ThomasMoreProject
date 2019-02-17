class PicturesController < ApplicationController
  before_action :check_log_in
  before_action :check_super_admin

  #Page of list of pictures
  def index
    picture_query = Picture.with_attached_image.includes(:picture_interests).order(:created_at).reverse_order
    @q = picture_query.ransack(params[:q])
    @pictures = params[:q] && params[:q][:s] ? @q.result.order(params[:q][:s]) : @q.result
    @pictures = @pictures.page(params[:page]).per(5)
  end

  #Create picture page
  def new
    @picture = Picture.new
    @interests = Interest.interests_list
  end

  #Action for create
  def create
    @picture = Picture.new(picture_params)

    @picture.image.attach(io: image_io, filename: image_name) if params[:picture][:image].is_a?(String)

    respond_to do |types|
      types.json do
        if @picture.save
          flash[:success] = 'Picture created!'
          render json: { response: { type: :success, message: 'Picture created!' } }, status: :ok
        else
          render json: {
              response: {
                  type: :error,
                  fields: @picture.errors.messages,
                  full_messages: @picture.errors.full_messages
              }
          }, status: :unprocessable_entity
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

    @picture.image.attach(io: image_io, filename: image_name) if params[:picture][:image].is_a?(String)

    respond_to do |types|
      types.json do
        if @picture.update(picture_params)
          flash[:success] = 'Picture updated!'
          render json: { response: { type: :success } }, status: :ok
        else
          render json: {
              response: {
                  type: :error,
                  errors: @picture.errors.messages,
                  full_messages: @picture.errors.full_messages
              }
          }, status: :unprocessable_entity
        end
      end
    end
  end

  #Action for deleting Picture
  def destroy
    picture = Picture.find(params[:id])
    if picture.destroy
      flash[:success] = 'Picture deleted!'
    else
      @user = picture
    end
    index
    render :index
  end
  ##########################################################
  #Private methods
  private
  #Attributes for forms
  def picture_params
    params.require(:picture).permit(
      :description,
      picture_interests_attributes: [
        :interest_id,
        :earned_points,
        :_destroy,
        :id
      ]
    )
  end
    def image_io
      decoded_image = Base64.decode64(params[:picture][:image].sub(/^data:.*,/, ''))
      StringIO.new(decoded_image)
    end
    def image_name
      params[:picture][:image_name]
    end
end
