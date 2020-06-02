class PicturesController < AdminController
  translations_for_preload %i[
    common.flash.picture_created
    common.flash.picture_deleted
    common.flash.picture_updated
    common.forms.confirm
    entities.interests.interest
    entities.pictures.add_interest
    entities.pictures.fields.description
    entities.pictures.fields.image
    entities.pictures.fields.weight
    entities.pictures.remove_interest
  ]

  def index
    authorize!
    picture_query = Picture.with_attached_image.includes(:picture_interests).order(:created_at).reverse_order
    @q = picture_query.ransack(params[:q])
    @pictures = params[:q] && params[:q][:s] ? @q.result.order(params[:q][:s]) : @q.result
    @pictures = @pictures.page(params[:page]).per(5)
  end

  def new
    authorize!
    @picture = Picture.new
    @interests = Interest.interests_list
  end

  def create
    authorize!
    @picture = Picture.new(picture_params)

    respond_to do |types|
      types.json do
        if @picture.save
          flash[:success] = tf('common.flash.picture_created')

          render json: {
            response: {
              type: :success,
              message: tf('common.flash.picture_created')
            }
          }, status: :ok
        else

          render json: {
              response: {
                  type: :error,
                  fields: @picture.errors.messages,
                  full_messages: translate_errors(@picture.errors, @picture)
              }
          }, status: :unprocessable_entity
        end
      end
    end
  end

  def edit
    @picture = Picture.find(params[:id])
    authorize!(@picture)
    @interests = Interest.interests_list
  end

  def update
    @picture = Picture.find(params[:id])
    authorize!(@picture)

    respond_to do |types|
      types.json do
        if @picture.update(picture_params)
          flash[:success] = tf('common.flash.picture_updated')
          render json: { response: { type: :success } }, status: :ok
        else
          render json: {
              response: {
                  type: :error,
                  errors: @picture.errors.messages,
                  full_messages: translate_errors(@picture.errors, @picture)
              }
          }, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    picture = Picture.find(params[:id])
    authorize!(picture)
    if picture.destroy
      flash[:success] = tf('common.flash.picture_deleted')
    else
      @user = picture
    end
    index
    render :index
  end

  def show
    question = Question.find_by(number: params[:question_number], test_id: params[:test_id])
    authorize!

    if question.blank?
      render json: {}, status: :not_found
      return
    end

    attachment = question.attachment
    if question.youtube?
      link = attachment.embed
      type = 'youtube'
    else
      link = url_for(attachment.middle_variant)
      type = 'picture'
    end

    respond_to do |types|
      types.json do
        render json: {
          title: '',
          link: link,
          type: type
        }
      end
    end
  end

  private

    def picture_params
      params
        .require(:picture)
        .permit(
          :description,
          :image,
          :audio,
          picture_interests_attributes: [
            :interest_id,
            :earned_points,
            :_destroy,
            :id
          ]
        )
    end
end
