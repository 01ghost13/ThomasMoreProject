class ResultOfTestsController < AdminController
  translations_for_preload %i[
    common.flash.test_unfinished
    common.flash.update_complete
    common.flash.test_result_outdated
    common.flash.test_result_deleted
    common.flash.cant_find_client
    common.flash.cant_find_test
    common.flash.empty_test
  ]

  def edit
    @result = ResultOfTest.find_by(id: params[:result_id])
    authorize!(@result)
    @user = @result
    #Only finished results are editable
    unless @result.is_ended
	    flash[:warning] = tf('common.flash.test_unfinished')
      redirect_back fallback_location: client_path(params[:client_id])
    end
  end

  def update
    @result = ResultOfTest.find_by(id: params[:result_id])
    authorize!(@result)
    @user = @result
    if @result.update(result_params)
      flash[:success] = tf('common.flash.update_complete')
      redirect_to(client_result_of_test_path(params[:client_id], params[:result_id]))
    else
      render :edit
    end
  end

  def show
    result = ResultOfTest.result_page.find_by(id: params[:result_id])
    @result = result
    @test = Test.select(:id, :name).find(result.test_id)
    result.language_id = current_user.language_id

    authorize!(result)

    #If test was changed, results are outdated
    if result.is_outdated?
      flash.now[:danger] = tf('common.flash.test_result_outdated')
    end

    avg_time_per_interest = {}
    #Loading question results
    q_res  = result.question_results.order(:number)
    q_test = Question.where(test_id: result.test_id) #questions of test
    #Loading all interests
    interests = {}
    interests_max = {}
    timestamps = []
    #Making array of interests
    q_res.each do |r|
      timestamps << r.show
      #Related interests for result
      related_i = {}
      q_test.each do |q|
        attachment =
            if q.youtube?
              q.youtube_link
            else
              q.picture
            end
        wrap_language(attachment)
        related_i = attachment.related_interests if q.number == r.number
      end
      related_i.each_key do |interest|
        if interests[interest].nil?
          interests_max[interest] = related_i[interest]
          interests[interest] = 0
          avg_time_per_interest[interest] = r.end - r.start
          interests[interest] = related_i[interest] if r.was_checked == 3 #Was thumbs up
        else
          interests_max[interest] += related_i[interest]
          interests[interest] += related_i[interest] if r.was_checked == 3
          avg_time_per_interest[interest] += r.end - r.start
        end
      end
    end
    avg_time_per_interest.each_key do |k|
      avg_time_per_interest[k] /= interests.count
    end
    client = Client.find(result.client_id)
    @client_user = client.user
    #Sorting
    @list_interests = interests.to_a.sort{ |x,y| y[1] - x[1]}
    @list_timestamps = timestamps
    @list_interests_max = interests_max
    @client = client.code_name.titleize
    @res = [
      result.was_in_school,
      result.show_time_to_answer,
      avg_time_per_interest,
      result.show_timeline,
      result.show_emotion_dynamic
    ]
    @has_heatmap = result.gaze_trace?
    if @has_heatmap
      gaze_calculator = GazeMultiplierCalculator.new(q_res)
      @list_interests_with_gaze = gaze_calculator.recount_results(@list_interests.to_h, @list_interests_max)
    end

    @has_emotion_track = result.emotion_recognition?

    if @has_emotion_track
      emotion_calculator = EmotionMultiplierCalculator.new(q_res)
      @list_interests_with_emotions = emotion_calculator.recount_results(@list_interests.to_h, @list_interests_max)
    end

    respond_to do |format|
      format.html
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename=\"result of #{@client}.xlsx\""
      }
    end
  end

  def index
    user = User.find_by(id: params[:client_id])
    authorize!(user)

    client = user.client
    results = ResultOfTest.where(client_id: client.id).order(:created_at).reverse_order
    @code_name = client.code_name
    @results = []
    results.each do |result|
      @results << result.show_short
    end
    @results = Kaminari.paginate_array(@results).page(params[:page]).per(5)
    #Preparing graphs
    @interest_points = client.get_client_interests[:points_interests]
    @avg_time = client.get_client_interests[:avg_answer_time]
  end

  def destroy
    result = ResultOfTest.find_by(id: params[:result_id])
    authorize!(result)

    if result.destroy
      flash[:success] = tf('common.flash.test_result_deleted')
    else
      flash[:error] = tf('entities.result_of_tests.errors.delete')
    end

    redirect_back fallback_location: client_path(params[:client_id])
  end

  def show_heatmap
    @result = ResultOfTest.result_page.find_by(id: params[:result_id])
    authorize!(@result)
    @test = @result.test

    #Loading client
    @client = @result.client

    if @test.blank? || @client.blank?
      #Cant find test or client
      flash[:danger] = tf('common.flash.cant_find_client') if @client.blank?
      flash[:danger] = tf('common.flash.cant_find_test') if @test.blank?
      redirect_back fallback_location: show_path_resolver(current_user) and return
    end

    #Checking questions in test
    if @test.questions.blank?
      flash[:danger] = tf('common.flash.empty_test')
      redirect_back fallback_location: show_path_resolver(current_user) and return
    end

    #Filling first question
    question_result = @result.get_question_result(params[:number] || 1)
    @question = question_result.question
    @description = @question.picture.description
    @image = @question.picture.image
    @heatmap = question_result.gaze_trace_result
  end

  def summary_results
    authorize!

    @tree = UsersTreeLoader.new(current_user, nil)
    @results_tree = @tree.call(params: params[:q])
  end

  def summary_result
    @test = Test.find(params[:id])

    @summary_target =
      if params[:user_id].present?
        User.find(params[:user_id])
      else
        current_user
      end

    authorize!(@summary_target, with: ResultOfTestPolicy)

    @name =
      if @summary_target.client?
        @summary_target.client.code_name
      else
        @summary_target.employee.full_name
      end

    user_tree = UsersTreeLoader.new(@summary_target, @test.id)
    user_tree.call
    @calc = SummaryResultCalculator.new(user_tree.results, current_user.language_id)


    respond_to do |format|
      format.html
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename=\"Test #{@test.name} summary result.xlsx\""
      }
    end
  end

  def summary_result_table

    @summary_target =
      if params[:user_id].present?
        User.find(params[:user_id])
      else
        current_user
      end

    authorize!(@summary_target, with: ResultOfTestPolicy)

    @name =
      if @summary_target.client?
        @summary_target.client.code_name
      else
        @summary_target.employee.full_name
      end

    user_tree = UsersTreeLoader.new(@summary_target, nil)
    user_tree.call
    @calc = SummaryTableCalculator.new(user_tree.results, current_user.language_id)


    respond_to do |format|
      format.html
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename=\"Tests summary table result.xlsx\""
      }
    end
  end

  private
    def result_params
      params
        .require(:result_of_test)
        .permit(question_results_attributes: %i[was_checked id])
    end
end
