class StudentsController < ApplicationController
  before_action :check_exist_callback, only: [:destroy, :edit, :update, :show]
  before_action :check_log_in, only: [:new, :create, :index, :update, :edit, :destroy, :show]
  before_action :check_rights, only: [:new, :create, :index]
  before_action :check_editing_rights, only: [:update, :edit, :destroy, :show]
  before_action :info_for_new_page, only: [:create, :new]
  before_action :check_deactivated, only: [:edit, :update]
  before_action :info_for_edit_page, only: [:edit, :update]

  #New student page
  def new
    @user = Student.new
  end
  
  #Action for create student
  def create
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

  #Action for hiding and deleting students
  def destroy
    student = Student.find(params[:id])
    if params[:paranoic] == 'true' || params[:paranoic] == nil
      if student.hide
        flash[:success] = 'Student was hided/recovered.'
      else
        flash[:warning] = "Can't hide/recover student"
      end
    elsif params[:paranoic] == 'false' && is_super?
      #True deleting
      if student.destroy
        flash[:success] = 'Student was deleted.'
      else
        flash[:danger] = "You can't delete this student"
      end
    end
    redirect_back fallback_location: current_user
  end
  
  #Update student profile page
  def edit
    @user = Student.find(params[:id])
  end
  
  #Action for updating
  def update
    @user = Student.find(params[:id])
    if @user.update(student_update_params)
      flash[:success] = 'Update Complete'
      redirect_to @user
    else
      render :edit
    end
  end
  
  #Profile page
  def show
    @user = Student.find(params[:id])
    @is_super_adm = is_super?
    @is_my_student = session[:user_type] == 'tutor' && @user.tutor_id == session[:type_id]
    @is_student_of_my_tutor = session[:user_type] == 'administrator' && @user.tutor.administrator_id == session[:type_id]
    unless @user.is_active
      #Student is inactive
      flash[:warning] = 'Student was deactivated in: ' + @user.date_off.to_s
      redirect_back fallback_location: current_user and return
    end
    @user_info = @user.show_info.to_a
    #Loading all test results
    @test_results = []
    ResultOfTest.order(:created_at).reverse_order.where(student_id: @user.id).limit(5).each do |res|
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

  #List of students
  def index
    if session[:user_type] == 'student'
      flash[:danger] = 'You have no access to this page!'
      redirect_to current_user and return
    end
    @is_super_adm = is_super?
    @students = []
    students = []
    if @is_super_adm
      students = Student.order(:code_name).all
    elsif session[:user_type] == 'tutor'
      students = Student.order(:code_name).where(tutor_id: session[:type_id], is_active: true)
    elsif session[:user_type] == 'administrator'
      tutors = Tutor.where(administrator_id: session[:type_id])
      tutors.each do |tutor|
        Student.order(:code_name).where(tutor_id: tutor.id, is_active: true).each do |student|
          students << student
        end
      end
    end
    students.each do |student|
      @students << student.show_short
    end
    @students = Kaminari.paginate_array(@students).page(params[:page]).per(5)
  end
  ##########################################################
  #Private methods
  private
  #Attributes for creation page
  def student_params
    params.require(:student).permit(:code_name,:tutor_id,:gender,:schooling_id,:is_current_in_school,:password,:password_confirmation)
  end

  #Attributes for edit page
  def student_update_params
    if session[:user_type] == 'administrator'
      params.require(:student).permit(:code_name,:tutor_id,:gender,:mode_id,:schooling_id,:is_current_in_school,:password,:password_confirmation)
    else
      params.require(:student).permit(:code_name,:gender,:mode_id,:schooling_id,:is_current_in_school,:password,:password_confirmation)
    end
  end

  #Rights checking
  def check_rights
    #Sa, admin, tutor
    unless is_super? || session[:user_type] == 'administrator' || session[:user_type] == 'tutor'
      flash[:danger] = 'You have no access to this page.'
      redirect_to current_user
    end
  end

  #Rights of editing profile
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
      if @admins.empty?
        @tutors = []
      else
        @tutors = Tutor.tutors_list(@admins.first[1])
      end
    elsif session[:user_type] == 'administrator'
      @tutors = Tutor.tutors_list(session[:type_id])
    end
  end

  #Loading data for edit page
  def info_for_edit_page
    @is_super_adm = is_super?
    if @is_super_adm
      #Loading Choosing of adm
      @admins = Administrator.admins_list
      if @admins.empty?
        @tutors = []
      else
        @admins_cur = @user.tutor.administrator_id
        @tutors = Tutor.tutors_list(@admins_cur)
        @tutors_cur = @user.tutor_id
      end
    elsif session[:user_type] == 'administrator'
      @tutors = Tutor.tutors_list(session[:type_id])
      @tutors_cur = @user.tutor_id
    end
  end

  #Callback for checking existence of record
  def check_exist_callback
    unless check_exist(params[:id], Student)
      redirect_to current_user
    end
  end

  #Callback for checking deactivated students
  def check_deactivated
    if !is_super? && @user.date_off != nil
      flash[:warning] = "You can't edit deactivated student!"
      redirect_back fallback_location: current_user
    end
  end
end