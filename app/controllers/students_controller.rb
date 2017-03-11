class StudentsController < ApplicationController
  before_action :check_login, only: [:new, :create, :index, :update, :edit, :destroy, :show]
  before_action :check_rights, only: [:new, :create, :index]
  before_action :check_editing_rights, only: [:update, :edit, :destroy, :show]
  #TODO: Make DRY Index
  #New student page
  def new
    @user = Student.new
    info_for_new_page
  end
  
  #Creation querry
  def create
    #Loading data for new.erb page
    info_for_new_page
    
    #Creating student
    @user = Student.new(student_params)
    @user.tutor_id = session[:type_id] if session[:user_type] == 'tutor'
    
    #trying to save
    if @user.save
      flash[:success] = 'Account created!'
      redirect_to @user
    else
      render :new
    end
  end
  
  def destroy
    
  end
  
  #Update page
  def edit
    #Searching student
    @user = Student.find(params[:id])
    #Loading info
    if @user.nil?
      flash[:error] = 'User does not exist.'
      redirect_to current_user
    end
    info_for_edit_page
  end
  
  #Update querry
  def update 
    #Listening params
    @user = Student.find(params[:id])
    
    #Loading info for page
    info_for_edit_page

    #Trying update 
    if !@user.nil? && @user.update(student_update_params)
      redirect_to(@user)
      flash[:success] = "Update Complete"
    else
      render :edit
    end
  end
  
  #Profile page
  def show
    @user = Student.find(params[:id])
    if @user.nil?
      flash[:error] = 'User does not exist.'
      redirect_to :root
    end
    @is_super_adm = is_super?
    @is_my_student = session[:user_type] == 'tutor' && @user.tutor_id == session[:type_id]
    @is_student_of_my_tutor = session[:user_type] == 'administrator' && @user.tutor.administrator_id == session[:type_id]
    unless @user.is_active
      #Student is inactive
      flash[:warning] = 'This student was deactivated in: ' + @user.date_off
      redirect_to current_user
    end
    @user_info = @user.show_info.to_a
    #Loading all test results
    @test_results = []
    ResultOfTest.order(:created_at).where(student_id: @user.id).take(5).each do |res|
      @test_results << res.show_short
    end
  end
  
  #Function for ajax updating
  def update_tutors
    @tutors = Tutor.tutors_list(params[:administrator_id])
    respond_to do |format|
       format.js {}
    end
  end
  
  def index
    if session[:user_type] == 'student'
      flash[:danger] = 'You have no access to this page!'
      redirect_to current_user
    end
    @students = []
    students = []
    if is_super?
      students = Student.order(:code_name).all
    elsif session[:user_type] == 'tutor'
      students = Student.order(:code_name).where(tutor_id: session[:type_id])
    elsif session[:user_type] == 'administrator'
      #TODO: Make get only id's
      tutors = Tutor.where(administrator_id: session[:type_id])
      tutors.each do |tutor|
        Student.order(:code_name).where(tutor_id: tutor.id).each do |student|
          students << student
        end
      end
    end
    students.each do |student|
      @students << student.show_short
    end
  end
  
  private
  
    def student_params
      params.require(:student).permit(:code_name,:tutor_id,:gender,:schooling_id,:is_current_in_school,:password,:password_confirmation)
    end
    
    def student_update_params
      if session[:user_type] == 'administrator'
        params.require(:student).permit(:code_name,:tutor_id,:gender,:mode_id,:schooling_id,:is_current_in_school,:password,:password_confirmation)
      else
        params.require(:student).permit(:code_name,:gender,:mode_id,:schooling_id,:is_current_in_school,:password,:password_confirmation)
      end
    end
    
    #Login checking
    def check_login
      unless logged_in?
        flash[:warning] = 'Only registrated people can see this page.'
        #Redirecting to home page
        redirect_to :root 
      end
    end
    
    #Rights checking
    def check_rights
      #Sa, admin, tutor
      unless is_super? || session[:user_type] == 'administrator' || session[:user_type] == 'tutor'
        flash[:warning] = 'You have no access to this page.'
        redirect_to current_user
      end
    end
    
    
    def check_editing_rights
      user = Student.find(params[:id])
      is_super_adm = is_super?
      is_my_student = session[:user_type] == 'tutor' && user.tutor_id == session[:type_id]
      is_student_of_my_tutor = session[:user_type] == 'administrator' && user.tutor.administrator_id == session[:type_id]
      is_i = session[:user_type] == 'student' && user.id == session[:type_id]
      unless is_super_adm || is_my_student || is_student_of_my_tutor || is_i
        flash[:warning] = 'You have no access to this page.'
        redirect_to current_user
      end
    end
    
    #Loads info for 'new' page
    def info_for_new_page
      @is_super_adm = is_super?
      if @is_super_adm
        #Loading Choosing of adm
        @admins = Administrator.admins_list
        if @admins.nil?
          @tutors = []
        else
          @tutors = Tutor.tutors_list(@admins.first[1])
        end
      elsif session[:user_type] == 'administrator'
        @tutors = Tutor.tutors_list(session[:type_id])
      end
    end
    
    #Loading data for edit.erb page
    def info_for_edit_page
      @is_super_adm = is_super?
      if @is_super_adm
        #Loading Choosing of adm
        @admins = Administrator.admins_list
        if @admins.nil?
          @tutors = []
        else
          administrator_of_student = @user.tutor.administrator_id
          @tutors = Tutor.tutors_list(administrator_of_student)
          @tutors_cur = @user.tutor_id
          @admins_cur = administrator_of_student
        end
      elsif session[:user_type] == 'administrator'
        @tutors = Tutor.where(administrator_id: session[:type_id]).map { |t| [t.info.name, t.id] }
        @tutors_cur = @tutors.to_a.index { |t| t.last == @user.tutor.id}
      end
   end
end