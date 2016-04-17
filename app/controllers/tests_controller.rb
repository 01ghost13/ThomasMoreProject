class TestsController < ApplicationController
  
  def new
  end
  def create
    
  end
  def edit
  end
  def update
    
  end

  def index
  end
  def exit
    #if has answers - saving
    #redirecting to result
  end
  def update_picture
    #Finding our result of test
    res = ResultOfTest.find(session[:result_of_test_id])
    cur_question = session[:cur_question].to_i
    #Writing result
    res.question_results << QuestionResult.new(number: cur_question, start: session[:start_time],was_checked: params[:value])
    #Changing variables
    ##Finding next pic name
    next_q = Question.where("test_id = :test and number = :number",{test: res.test_id, number: cur_question+1}).take
    ##if was last pic saving and redirecting to result
    if next_q.nil?
      #current q was the last, saving and redirecting to end
      res.update(is_ended: true)
      session.delete(:cur_question)
      session.delete(:result_of_test_id)
      session.delete(:start_time)
      render js: %(window.location.pathname='#{student_result_of_test_path(res.id)}')
      return
    end
    #If it wasnt last question
    @progress_bar_value = params[:progress].to_i + 10
    pic = next_q.picture
    @description = pic.description
    @image = pic.path
    session[:cur_question] += 1
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
    res = ResultOfTest.where("student_id = :student and test_id = :test and is_ended = :is_ended", { student: student.id, test: test.id, is_ended: false }).take
    if res.nil?
      #All tests were ended
      #Creating new result
      res = ResultOfTest.create(test_id: test.id, was_in_school: student.is_current_in_school, schooling_id: student.schooling.id, student_id: student.id)
    end
    #Filling first question
    #debugger
    question = res.last_question
    session[:result_of_test_id] = res.id
    session[:cur_question] = question.number
    session[:start_time] = DateTime.current
    @description = question.picture.description
    @image = question.picture.path
  end
end
