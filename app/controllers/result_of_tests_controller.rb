class ResultOfTestsController < ApplicationController
  #TODO: Add group stats
  before_action :check_login
  before_action :check_rights
  def edit
    #Loading res info
    @result = ResultOfTest.find(params[:result_id])
    @user = @result
  end
  def update
    #Loading res info
    @result = ResultOfTest.find(params[:result_id])
    @user = @result
    if @result.update(result_params)
      redirect_to(student_result_of_test_path(params[:student_id],params[:result_id]))
      flash[:success] = "Update Complete"
    else
      render :edit
    end
  end

  def show
    #Loading result
    result = ResultOfTest.find(params[:result_id])
    #Loading q results
    q_res  = result.question_results
    q_test = Question.where(test_id: result.test_id)
    #Loading all interests
    interests = {}
    interests_max = {}
    timestamps = []
    #Making array of interests
    #debugger
    q_res.each do |r|
      #debugger
      timestamps << r.show
      #debugger
      #Related interests for result
      related_i = []
      q_test.each do |q|
        related_i = q.picture.related_interests if q.number == r.number
      end
      #debugger
      related_i.each_key do |interest|
        #debugger
        if interests[interest].nil?
          #debugger
          interests_max[interest] = related_i[interest]
          interests[interest] = 0
          interests[interest] = related_i[interest] if r.was_checked == 3 #Was thumbs up
        else
          #debugger
          interests_max[interest] += related_i[interest]
          interests[interest] += related_i[interest] if r.was_checked == 3
          #interests[i] -= related_i[i] if r.was_checked == 1  
        end
      end
    end
    student = Student.find(result.student_id)
    #Sorting
    @list_interests = interests.to_a.sort{ |x,y| y[1] - x[1]}
    @list_timestamps = timestamps
    @list_interests_max = interests_max
    @student = student.code_name.titleize
  end
  
  def index
    
  end
  private
    def result_params
      params.require(:result_of_test).permit(question_results_attributes: [:was_checked,:id])
    end
    def check_login
      unless logged_in?
        flash[:warning] = "Only registrated people can see this page."
        #Redirecting to home page
        redirect_to :root 
      end
    end
    def check_rights
      user = Student.find(params[:student_id])
      is_super_adm = is_super?
      is_my_student = session[:user_type] == 'tutor' && user.tutor_id == session[:type_id]
      is_student_of_my_tutor = session[:user_type] == 'administrator' && user.tutor.administrator_id == session[:type_id]
      @i_am_student = session[:user_type] == 'student'
      is_i = @i_am_student && params[:student_id] == session[:type_id]
      unless is_super_adm || is_my_student || is_student_of_my_tutor || is_i
        flash[:warning] = "You have no access to this page."
        redirect_to current_user
      end
    end
end
