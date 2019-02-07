class TestsController < ApplicationController
  before_action :check_log_in
  before_action :check_exist_callback, only: [:testing, :edit, :update, :destroy]
  before_action :check_rights, only: [:testing]
  before_action :check_super_admin, only: [:new, :create, :edit, :update, :destroy]

  #Page of creation of Tests
  def new
    @test = Test.new
    @pictures = Picture.pictures_list
  end

  #Action for ajax
  def update_image
    @id = params[:event_id]
    @picture = Picture.find(params[:picture_id])
  end

  #Action for creation of test
  def create
    @test = Test.new(test_params)
    @picture = []
    #Numering questions
    @test.questions.each_with_index do |q, i|
      q.number = i + 1
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
      render json: { errors: @test.errors }, status: :unprocessable_entity
    end
  end

  #Page of editing tests
  def edit
    @test = Test.find(params[:id])
    @picture = []
    @pictures = Picture.pictures_list
    @test.questions.each do |q|
      @picture << Picture.find(q.picture_id)
    end
    @dummy = Picture.find(@pictures.first[1])
    @picture = [@dummy] if @picture.empty?
  end

  def all_questions_destroy?(questions)
    questions.each_key do |key|
      if questions[key]['_destroy'] != 'true'
        return false
      end
    end
    true
  end

  #Action of editing tests
  def update
    @test = Test.find(params[:id])
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
        @picture << Picture.find(q.picture_id)
      end
      @user = @test
      @pictures = Picture.pictures_list
      @dummy = Picture.find(@pictures.first[1])
      @picture = [@dummy] if @picture.empty?
      render :edit
    end
  end

  #Action for deleting tests
  def destroy
    test = Test.find(params[:id])
    if test.destroy
      flash[:success] = 'Test deleted!'
    else
      flash[:danger] = 'This test has associated results, please, delete them first.'
    end
    redirect_to tests_path
  end

  #Page of list of tests
  def index
    #Only super admin has access to aitscore\tests
    if params[:id].nil? && !is_super?
      flash[:warning] = 'You have no access to this page.'
      redirect_to current_user
      return
    end
    tests = Test.all
    @tests = []
    tests.each do |test|
      @tests << test.show_short
    end
    @tests = Kaminari.paginate_array(@tests).page(params[:page]).per(10)
  end

  #Updates picture in /testing process
  def update_picture
    #Finding our result of test
    res = ResultOfTest.where(student_id: params[:student_id], test_id: params[:test_id], is_ended: false).first
    cur_question = params[:question][:number].to_i

    #Loading next question and writing to db current
    #Writing result
    ##Checking - is it rewriting?
    if params[:rewrite] == 'true'
      #Updating cur question result
      q_to_upd = QuestionResult.where(result_of_test_id: res.id, number: cur_question).first
      q_to_upd.update(
          start: params[:start_time],
          end: DateTime.current,
          was_checked: params[:answer],
          was_rewrited: true
      )
    else
      cur_q = Question.where(test_id: res.test_id, number: cur_question).first
      question_result_params = {
          number: cur_question,
          start: params[:start_time],
          end: DateTime.current,
          was_checked: params[:answer],
          question_id: cur_q.id
      }
      if res.gaze_trace? && params[:gaze_trace_result_attributes].present?
        question_result_params[:gaze_trace_result_attributes] =
            params.require(:gaze_trace_result_attributes).permit(GazeTraceResult.attribute_names, gaze_points: [:x, :y])
      end
      if res.emotion_recognition? && params[:emotion_state_result_attributes].present?
        question_result_params[:emotion_state_result_attributes] =
            params.require(:emotion_state_result_attributes).permit!
      end

      res.question_results << QuestionResult.new(question_result_params)
    end
    #Changing variables
    ##Finding next pic name
    @question = Question.where(test_id: params[:test_id], number: cur_question + 1).first
    ##if was last pic saving and redirecting to result
    if @question.nil?
      #current q was the last, saving and redirecting to result
      res.update(is_ended: true)
      render json: { result_url: student_result_of_test_path(params[:student_id], res.id) } and return
    end

    pic = @question.picture
    @description = pic.description
    @image = pic.image

    respond_to do |format|
       format.json do
         render '/tests/update_picture.json.jbuilder'
       end
    end
  end
  
  def testing
    #Loading test
    @test = Test.where(id: params[:test_id]).first

    #Loading student
    @student = Student.where(id: params[:id]).first
    
    if @test.blank? || @student.blank?
      #Cant find test or student
      flash[:danger] = "Can't find student" if @student.blank?
      flash[:danger] = "Can't find test" if @test.blank?
      redirect_back fallback_location: current_user and return
    end

    #Checking questions in test
    if @test.questions.blank?
      flash[:danger] = 'Test is empty and probably not ready for testing! Please, contact administrator.'
      redirect_back fallback_location: current_user and return
    end

    #Checking continue or creating new result
    res = ResultOfTest.where(student_id: params[:id], test_id: params[:test_id], is_ended: false).first
    if res.blank?
      #All tests were ended
      #Creating new result
      res = ResultOfTest.create(
        test_id: params[:test_id],
        was_in_school: @student.is_current_in_school,
        schooling_id: @student.schooling.id,
        student_id: params[:id],
        gaze_trace: @student.gaze_trace,
        emotion_recognition: @student.emotion_recognition
      )
    end
    #Filling first question
    @question = res.last_question
    @previous_question = res.previous_question
    @description = @question.picture.description
    @image = @question.picture.image
    @res = res
    render layout: 'testing_layout'
  end
  ##########################################################
  #Private methods
  private
  def check_rights
    user = Student.find(params[:id])
    is_super_adm = is_super?
    is_my_student = session[:user_type] == 'tutor' && user.tutor_id == session[:type_id]
    is_student_of_my_tutor = session[:user_type] == 'administrator' && user.tutor.administrator_id == session[:type_id]
    is_i = session[:user_type] == 'student' && params[:id].to_i == session[:type_id]
    unless is_super_adm || is_my_student || is_student_of_my_tutor || is_i
      flash[:warning] = 'You have no access to this page.'
      redirect_to current_user
    end
  end
  def test_params
    i = 1
    if params[:test][:questions_attributes]
      params[:test][:questions_attributes].each_pair do |key, _|
        params[:test][:questions_attributes][key][:number] = i
        i += 1
      end
    end
    params.require(:test).permit(
        :description, :name, :version, questions_attributes: [
        :picture_id, :_destroy, :id, :number, :is_tutorial])
  end
  def check_exist_callback
    #edit - params[:id], other - params[:test_id]
    unless !params[:test_id].nil? && check_exist(params[:test_id], Test) ||
            params[:test_id].nil? && check_exist(params[:id], Test)
      redirect_to current_user
    end
  end
end
