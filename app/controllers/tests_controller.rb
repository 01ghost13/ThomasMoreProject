class TestsController < AdminController

  def new
    authorize!
    @test = Test.new
    @pictures = Picture.pictures_list
  end

  #Action for ajax
  def update_image
    authorize!
    @id = params[:event_id]
    @picture = Picture.find(params[:picture_id])
  end

  def create
    authorize!
    @test = Test.new(test_params)
    @picture = []
    #Numering questions
    @test.questions.each_with_index do |q, i|
      q.number = i + 1
      next if q.picture_id.blank?
      @picture << Picture.find(q.picture_id)
    end
    unless params[:test][:questions_attributes]
      @test.errors.add(:questions, :invalid, message: "Test can't be empty")
    end
    if params[:test][:questions_attributes] && @test.save
      flash[:success] = 'Test created!'
      render json: {}, status: :created
    else
      @user = @test
      @pictures = Picture.pictures_list
      @dummy = Picture.find(@pictures.first[1])
      @picture = [@dummy] if @picture.empty?
      render json: {
          response: {
              type: :error,
              fields: @test.errors.messages,
              full_messages: @test.errors.full_messages
          }
      }, status: :unprocessable_entity
    end
  end

  def edit
    @test = Test.find_by(id: params[:id])
    authorize!(@test)
    @picture = []
    @pictures = Picture.pictures_list
    @test.questions.each do |q|
      next if q.picture_id.blank?
      @picture << Picture.find(q.picture_id)
    end
    @dummy = Picture.find(@pictures.first[1])
    @picture = [@dummy] if @picture.empty?
  end

  def update
    @test = Test.find_by(id: params[:id])
    authorize!(@test)

    empty_list = all_questions_destroy?(test_params[:questions_attributes].to_hash)
    if !params[:test].nil? && !empty_list && @test.update(test_params)
      flash[:success] = 'Test updated!'
      render json: {}, status: :ok
    else
      if params[:test].nil? || empty_list
        @test.errors.add(:questions, :invalid, message: "Test can't be empty")
      end
      @picture = []
      #Loading questions
      @test.questions.each do |q|
        next if q.picture_id.blank?
        @picture << Picture.find(q.picture_id)
      end
      @user = @test
      @pictures = Picture.pictures_list
      @dummy = Picture.find(@pictures.first[1])
      @picture = [@dummy] if @picture.empty?
      render json: {
          response: {
              type: :error,
              fields: @test.errors.messages,
              full_messages: @test.errors.full_messages
          }
      }, status: :unprocessable_entity
    end
  end

  def destroy
    test = Test.find_by(params[:id])
    authorize!(test)

    if test.destroy
      flash[:success] = 'Test deleted!'
    else
      flash[:danger] = 'This test has associated results, please, delete them first.'
    end
    redirect_to tests_path
  end

  def index
    #Only super admin has access to aitscore\tests
    authorize!(params)

    @tests = Test.all.map(&:show_short)
    @tests = Kaminari.paginate_array(@tests).page(params[:page]).per(10)

    if params[:id].present?
      @not_finished_tests = ResultOfTest
        .joins(client: :user)
        .where('users.id': params[:id], is_ended: false)
        .order(created_at: :desc)
    end
  end

  private

    def all_questions_destroy?(questions)
      questions.each_key do |key|
        if questions[key]['_destroy'] != 'true'
          return false
        end
      end
      true
    end

    def test_params
      i = 1
      if params[:test][:questions_attributes].present?
        params[:test][:questions_attributes].each_pair do |key, _|
          params[:test][:questions_attributes][key][:number] = i
          i += 1
        end
      end
      params.require(:test).permit(
          :description,
          :name,
          :version,
          questions_attributes: [
            :picture_id,
            :_destroy,
            :id,
            :number,
            youtube_link_attributes: [
              :link
            ]
          ]
      )
    end
end
