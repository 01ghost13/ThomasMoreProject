class ResultOfTestsController < ApplicationController
  before_action :result_exist_callback, only: [:edit, :update, :show, :destroy]
  before_action :client_exist_callback
  before_action :check_log_in
  before_action :check_rights, only: [:show, :index]
  before_action :check_admin_rights, except: [:show, :index]

  #Edit results page
  def edit
    #Loading res info
    @result = ResultOfTest.find(params[:result_id])
    @user = @result
    #Only finished results are editable
    unless @result.is_ended
	    flash[:warning] = 'Test is not finished'
      redirect_back fallback_location: client_path(params[:client_id])
    end
  end

  #Action for updating results
  def update
    #Loading res info
    @result = ResultOfTest.find(params[:result_id])
    @user = @result
    if @result.update(result_params)
      flash[:success] = 'Update Complete'
      redirect_to(client_result_of_test_path(params[:client_id], params[:result_id]))
    else
      render :edit
    end
  end

  #Page of result
  def show
    #Loading result
    result = ResultOfTest.result_page.find(params[:result_id])

    #If test was changed, results are outdated
    if result.is_outdated?
      flash.now[:danger] = 'The test was edited. Points for interests are outdated!'
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
        related_i = q.picture.related_interests if q.number == r.number
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

  #List of results
  def index
    #Loading test results
    results = ResultOfTest.where(client_id: params[:client_id]).order(:created_at).reverse_order
    client = Client.find(params[:client_id])
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

  #Action for deleting results
  def destroy
    result = ResultOfTest.find(params[:result_id])
    if result.destroy
      flash[:success] = 'Result deleted!'
      redirect_to client_result_of_tests_path(params[:client_id])
    else
      @user = result
      render :index
    end
  end

  def show_heatmap
    #Loading test
    @result = ResultOfTest.result_page.find(params[:result_id])
    @test = @result.test

    #Loading client
    @client = @result.client

    if @test.blank? || @client.blank?
      #Cant find test or client
      flash[:danger] = "Can't find client" if @client.blank?
      flash[:danger] = "Can't find test" if @test.blank?
      redirect_back fallback_location: current_user and return
    end

    #Checking questions in test
    if @test.questions.blank?
      flash[:danger] = 'Test is empty!'
      redirect_back fallback_location: current_user and return
    end

    #Filling first question
    question_result = @result.get_question_result(params[:number] || 1)
    @question = question_result.question
    @description = @question.picture.description
    @image = @question.picture.image
    @heatmap = question_result.gaze_trace_result
  end

  ##########################################################
  #Private methods
  private
  def result_params
    params.require(:result_of_test).permit(question_results_attributes: [:was_checked,:id])
  end
  def check_rights
    user = Client.find(params[:client_id])
    is_super_adm = is_super?
    is_my_client = session[:user_type] == 'mentor' && user.mentor_id == session[:type_id]
    is_client_of_my_mentor = session[:user_type] == 'administrator' && user.mentor.administrator_id == session[:type_id]
    @i_am_client = session[:user_type] == 'client'
    is_i = @i_am_client && params[:client_id].to_i == session[:type_id]
    unless is_super_adm || is_my_client || is_client_of_my_mentor || is_i
      flash[:danger] = 'You have no access to this page.'
      redirect_to current_user
    end
  end
  def check_admin_rights
    client = Client.find(params[:client_id])
    is_super_adm = is_super?
    is_my_client = session[:user_type] == 'mentor' && client.mentor_id == session[:type_id]
    is_client_of_my_mentor = session[:user_type] == 'administrator' && client.mentor.administrator_id == session[:type_id]
    unless is_super_adm || is_my_client || is_client_of_my_mentor
      flash[:danger] = 'You have no access to this page.'
      redirect_to current_user
    end
  end
  def result_exist_callback
    unless check_exist(params[:result_id], ResultOfTest)
      redirect_to current_user
    end
  end
  def client_exist_callback
    unless check_exist(params[:client_id], Client)
      redirect_to current_user
    end
  end
end
