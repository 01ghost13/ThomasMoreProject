class TestsController < ApplicationController
  before_action :check_log_in
  before_action :check_exist_callback, only: [:testing, :edit, :update, :destroy]
  before_action :check_rights, only: [:testing]
  before_action :check_super_admin, only: [:new, :create, :edit, :update, :destroy]

  #Page of creation of Tests
  def new
    @test = Test.new
    @test.questions << [Question.new]
    @pictures = Picture.pictures_list
    @dummy = Picture.find(@pictures.first[1])
    @picture = [@dummy] #Adding dummy picture
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
      q.is_tutorial = false
      @picture << Picture.find(q.picture_id)
    end
    unless params[:questions_attributes]
      @test.errors.add(:questions, :invalid, message: "Test can't be empty")
    end
    if params[:questions_attributes] && @test.save
      flash[:success] = 'Test created!'
      redirect_to tests_path
    else
      @user = @test
      @pictures = Picture.pictures_list
      @dummy = Picture.find(@pictures.first[1])
      @picture = [@dummy] if @picture.empty?
      render :new
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

  #Action of editing tests
  def update
    @test = Test.find(params[:id])
    if params[:questions_attributes] && @test.update(test_params)
      flash[:success] = 'Test updated!'
      redirect_to tests_path
    else
      unless params[:questions_attributes]
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

  #Exits /testing process
  def exit
    session.delete(:cur_question)
    session.delete(:result_of_test_id)
    session.delete(:start_time)
    session.delete(:next_rewrite)
    nil
  end

  #Updates picture in /testing process
  def update_picture
    #Finding our result of test
    res = ResultOfTest.find(session[:result_of_test_id])
    cur_question = session[:cur_question].to_i

    if params[:value] == '0'
      #Was pressed btn - go back
      return if cur_question == 1 || session[:next_rewrite] == true #If was pressed on first question - returning
      #Loading prev question
      prev_q = Question.where('test_id = :test and number = :number',{test: res.test_id, number: cur_question-1}).take
      #Loading info
      ##hiding btn back
      @show_btn_back = 'visibility:hidden'
      session[:next_rewrite] = true #Flag to know, next click - to update
      ##Changing progress bar
      step = -100.0 / Question.where(test_id: res.test_id).count
      pic = prev_q.picture
      session[:cur_question] -= 1
    else
      #Loading next question and writing to db current
      @show_btn_back = ''
      #Writing result
      ##Checking - is it rewriting?
      if session[:next_rewrite]
        session[:next_rewrite] = false
        #Updating cur question result
        q_to_upd = QuestionResult.where('result_of_test_id = :res and number = :number',
                                        {res: res.id, number: cur_question}).take
        q_to_upd.update({start: session[:start_time],:end => DateTime.current,
                         was_checked: params[:value], was_rewrited: true})
      else
        cur_q = Question.find_by(test_id: res.test_id, number: cur_question)
        res.question_results << QuestionResult.new(number: cur_question, start: session[:start_time],
                                                   was_checked: params[:value], question_id: cur_q.id)
      end
      #Changing variables
      ##Finding next pic name
      next_q = Question.where('test_id = :test and number = :number',{test: res.test_id, number: cur_question+1}).take
      ##if was last pic saving and redirecting to result
      if next_q.nil?
        #current q was the last, saving and redirecting to end
        res.update(is_ended: true)
        render js: %(window.location.pathname='#{student_result_of_test_path(res.student_id,res.id)}')
        return
      end
      step = 100.0 / Question.where(test_id: res.test_id).count
      pic = next_q.picture
      session[:cur_question] += 1
    end
    @progress_bar_value = params[:progress].to_f + step
    @description = pic.description
    @image = pic.image
    session[:start_time] = DateTime.current
    respond_to do |format|
       format.js {}
    end
  end
  
  def testing
    @progress_bar_value = 0
    #Loading test
    test = Test.find(params[:test_id])
    #Loading student
    student = Student.find(params[:id])
    
    if test.nil? || student.nil?
      #Cant find test or student
      flash[:danger] = "Can't find student" if student.nil?
      flash[:danger] = "Can't find test" if test.nil?
      redirect_to current_user and return
    end

    #Checking questions in test
    if test.questions.empty?
      flash[:danger] = 'Test is empty and probably not ready for testing! Please, contact with administrator.'
      redirect_back fallback_location: current_user and return
    end
    #Checking continue or creating new result
    res = ResultOfTest.where('student_id = :student and test_id = :test and is_ended = :is_ended',
                             { student: student.id, test: test.id, is_ended: false }).take
    if res.nil?
      #All tests were ended
      #Creating new result
      res = ResultOfTest.create(test_id: test.id, was_in_school: student.is_current_in_school,
                                schooling_id: student.schooling.id, student_id: student.id)
    else
      total_q = Question.where(test_id: res.test_id).count.to_f
      done_q = res.question_results.count
      
      @progress_bar_value = done_q / total_q * 100.0
    end
    #Filling first question
    question = res.last_question
    session[:result_of_test_id] = res.id
    session[:cur_question] = question.number
    @show_btn_back = (question.number == 1) ? 'visibility:hidden' : ''
    session[:start_time] = DateTime.current
    @description = question.picture.description
    @image = question.picture.image
    session[:next_rewrite] = false
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
        i+=1
      end
    end
    params.require(:test).permit(
        :description, :name, :version, questions_attributes: [
        :picture_id, :_destroy, :id, :number, :is_tutorial])
  end
  def check_exist_callback
    unless check_exist(params[:test_id], Test)
      redirect_to current_user
    end
  end
end
