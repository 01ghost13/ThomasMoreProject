class PicturesController < AdminController
  # before_action :check_log_in
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

	if Rails.env.staging?
	  file = convert_data_uri_to_upload(params[:picture])
	  @picture.image.attach(io: File.open(file.path), filename: image_name)
	else
	  @picture.image.attach(io: image_io, filename: image_name) if params[:picture][:image].is_a?(String)
	end

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
	def split_base64(uri_str)
	  if uri_str.match(%r{^data:(.*?);(.*?),(.*)$})
		uri = Hash.new
		uri[:type] = $1 # "image/gif"
		uri[:encoder] = $2 # "base64"
		uri[:data] = $3 # data string
		uri[:extension] = $1.split('/')[1] # "gif"
		return uri
	  else
		return nil
	  end
	end

	def convert_data_uri_to_upload(obj_hash)
	  if obj_hash[:image].try(:match, %r{^data:(.*?);(.*?),(.*)$})
	    image_data = split_base64(obj_hash[:image])
	    image_data_string = image_data[:data]
	    image_data_binary = Base64.decode64(image_data_string)

	    temp_img_file = Tempfile.new("")
	    temp_img_file.binmode
	    temp_img_file << image_data_binary
	    temp_img_file.rewind

		return temp_img_file  
	  end  
	end
end
