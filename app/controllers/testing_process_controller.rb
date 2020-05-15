class TestingProcessController < AdminController
  translations_for_preload %i[
    testing_process.test_loading
  ]

  before_action :preload_entity

  def answer
    result_of_test = ResultOfTest.find_by(id: params[:result_of_test_id])

    @start_number = params[:last_available_question].to_i

    authorize!(result_of_test, with: TestProccessPolicy)
    manager = TestingManager.new(params[:result_of_test_id])
    @test = manager.result_of_test.test

    unless manager.valid?
      flash[:danger] = tf("errors.#{manager.errors.last}")
      render json: {
        result_url: show_path_resolver(current_user)
      }
      return
    end

    start_time = DateTime.parse(params[:start_time])
    loading_time = params[:loading_time]
    if loading_time.present?
      start_time += loading_time.to_f.seconds
    end

    @question = manager.next(
      params[:question][:number].to_i,
      params[:rewrite],
      start_time,
      params[:answer],
      params[:gaze_trace_result_attributes],
      params[:emotion_state_result_attributes]
    )

    if @question.blank?
      res = manager.result_of_test
      render json: {
        # result_url: client_result_of_test_path(res.client.user.id, res.id)
        result_url: finish_page_path(res.id)
      }
      return
    end

    @description = wrap_language(@question.attachment)&.description || ''

    respond_to do |format|
      format.json do
        render 'update_picture.json.jbuilder'
      end
    end
  end

  def testing
    result_of_test = ResultOfTest.find_by(id: params[:result_of_test_id])

    authorize!(result_of_test, with: TestProccessPolicy)
    manager = TestingManager.new(params[:result_of_test_id])

    unless manager.valid?
      flash[:danger] = tf("errors.#{manager.errors.last}")
      redirect_back fallback_location: show_path_resolver(current_user)
      return
    end

    @test = manager.result_of_test.test
    @client = manager.result_of_test.client
    @res = manager.result_of_test

    #Filling first question
    @question = @res.last_question
    @previous_question = @res.previous_question
    @description = wrap_language(@question.attachment)&.description || ''
    @image = @question.picture&.middle_variant

    render layout: 'testing_layout'
  end

  def begin
    test = Test.find(params[:test_id])
    authorize!(@user, with: TestProccessPolicy)

    @client = @user.client

    @result_of_test = ResultOfTest.create(
      test_id: params[:test_id],
      was_in_school: @client.is_current_in_school,
      client_id: @client.id,
      # gaze_trace:  && @client.gaze_trace,
      # emotion_recognition: @client.emotion_recognition
      gaze_trace: false,
      emotion_recognition: false
    )

    redirect_to testing_path(@result_of_test.id)
  end

  def index
    authorize!(@user, with: TestProccessPolicy)
    tests = Test.filter_by_availability(@user.head_user)
    @tests = wrap_language(tests).map(&:show_short)
    @tests = Kaminari.paginate_array(@tests).page(params[:page]).per(10)

    @not_finished_tests = ResultOfTest
                              .joins(client: :user)
                              .where('users.id': params[:id], is_ended: false)
                              .order(created_at: :desc)

    render 'tests/index'
  end

  def finish
    @result_of_test = ResultOfTest
      .includes(
        question_results: {
          question: {
            picture: { picture_interests: :interest },
            youtube_link: { picture_interests: :interest },
          }
        }
      )
      .find_by(id: params[:result_of_test_id])

    authorize!(@result_of_test, with: TestProccessPolicy)

    q_res = @result_of_test.question_results
    language_id = current_user.language_id

    wrapped = QuestionResultPresenter.wrap(q_res, language_id)
    rated_interests = SummaryResultCalculator
      .table_interest_points(wrapped)
      .first(1)
      .map(&:this)

    @interest = rated_interests.map(&:name).join(', ')

    @top_rated_pics = Picture.select('pictures.*, picture_interests.earned_points')
      .joins(
        questions: {
          picture: { picture_interests: :interest },
        }
      )
      .where(
        'questions.test_id': @result_of_test.test_id,
        'interests.id': rated_interests.map(&:id)
      )
      .order('picture_interests.earned_points DESC')
      .limit(4)
      .distinct

    render layout: 'testing_layout'
  end

  private

    def preload_entity
      @user = User.find_by(id: params[:id])
    end
end
