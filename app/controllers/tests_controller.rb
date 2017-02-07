class TestsController < ApplicationController
  #TODO: Creation of tests
  before_action :check_login
  before_action :check_rights, only: [:testing]
  def new
  end
  def create
    
  end
  def edit
  end
  def update
    
  end

  def index
    tests = Test.all
    @tests = []
    tests.each do |test|
      @tests << test.show_short
    end
  end
  def exit
    #debugger
    session.delete(:cur_question)
    session.delete(:result_of_test_id)
    session.delete(:start_time)
    session.delete(:next_rewrite)
    nil
  end
  def update_picture
    #Finding our result of test
    res = ResultOfTest.find(session[:result_of_test_id])
    cur_question = session[:cur_question].to_i
    if params[:value] == '0'
    #We are going back
      return if cur_question == 1 #If was pressed on first question - returning
      #Loading prev q
      prev_q = Question.where('test_id = :test and number = :number',{test: res.test_id, number: cur_question-1}).take
      #Loading info
      ##switch off btn back
      @show_btn_back = 'hidden'
      session[:next_rewrite] = true #Flag to know, next click - to update
      step = -100 / Question.where(test_id: res.test_id).count
      pic = prev_q.picture
      session[:cur_question] -= 1
    else
      #Loading next q
      @show_btn_back = 'visible'
      #Writing result
      ##Checking - is it rewriting?
      if session[:next_rewrite]
        session[:next_rewrite] = false
        #Updating cur q result
        q_to_upd = QuestionResult.where('result_of_test_id = :res and number = :number',{res: res.id, number: cur_question}).take
        q_to_upd.update({start: session[:start_time],:end => DateTime.current,was_checked: params[:value], was_rewrited: true})
      else
        res.question_results << QuestionResult.new(number: cur_question, start: session[:start_time],was_checked: params[:value])
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
      step = 100 / Question.where(test_id: res.test_id).count
      pic = next_q.picture
      session[:cur_question] += 1  
    end
    @progress_bar_value = params[:progress].to_i + step.to_i
    @description = pic.description
    #@image = pic.path
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
      redirect_back_or current_user
    end
    
    #Checking continue or creating new result
    res = ResultOfTest.where('student_id = :student and test_id = :test and is_ended = :is_ended', { student: student.id, test: test.id, is_ended: false }).take
    if res.nil?
      #All tests were ended
      #Creating new result
      res = ResultOfTest.create(test_id: test.id, was_in_school: student.is_current_in_school, schooling_id: student.schooling.id, student_id: student.id)
    else
      total_q = Question.where(test_id: res.test_id).count.to_f
      done_q = res.question_results.count
      
      @progress_bar_value = done_q / total_q * 100.0
    end
    #Filling first question
    question = res.last_question
    session[:result_of_test_id] = res.id
    session[:cur_question] = question.number
    @show_btn_back = (question.number == 1) ? "hidden" : "visible"
    session[:start_time] = DateTime.current
    @description = question.picture.description
    @image = question.picture.image
    session[:next_rewrite] = false
  end
  private
    def check_login
      unless logged_in?
        flash[:warning] = "Only registrated people can see this page."
        #Redirecting to home page
        redirect_to :root 
      end
    end
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
end
