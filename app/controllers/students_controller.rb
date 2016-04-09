class StudentsController < ApplicationController
  before_action :check_login, only: [:new,:create, :index,:update,:edit,:destroy]
  before_action :check_rights, only: [:new, :create, :index, :update, :edit, :destroy]
  
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
      flash[:success] = "Account created!"
      redirect_to(@user)
      #Which redirect is best? To my profile or to created?
    else
      render 'new'
    end
  end
  
  def destroy
    
  end
  
  #Update page
  def edit
    #Searching student
    @user = Student.find(params[:id])
    
    #Loading info
    unless @user.nil? 
      info_for_edit_page
    else
      #404
    end
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
    @is_super_adm = is_super?
    @is_my_student = params[:user_type] == 'tutor' && @user.tutor_id == params[:type_id]
    @is_student_of_my_tutor = params[:user_type] == 'administrator' && @user.tutor.administrator_id == params[:type_id]
    unless @user.nil?
      #throw 404
    end
    unless @user.is_active
      #Student is unactive
      flash[:warning] = "This student was deactivated in: " + @user.date_off
      #Redirect_back_or ?
      redirect_to current_user
    end
    @user_info = @user.show_info.to_a
    #Loading test
  end
  
  #Function for ajax updating
  def update_tutors
    @tutors = Tutor.where(administrator_id: params[:administrator_id])
    respond_to do |format|
       format.js {}
    end
  end
  
  def index
    
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
        flash[:warning] = "Only registrated people can see this page."
        #Redirecting to home page
        redirect_to :root 
      end
    end
    
    #Rights checking
    def check_rights
      #Sa, admin, tutor
      unless is_super? || session[:type] == 'administrator' || session[:type] == 'tutor'
        flash[:warning] = "You have no access to this page."
        redirect_to current_user
      end
    end
    
    #Loads info for 'new' page
    def info_for_new_page
      @is_super_adm = is_super?
      if @is_super_adm
        #Loading Choosing of adm
        local_admins = Administrator.where(is_super: false)
        @admins = local_admins.map { |adm| [adm.info.name, adm.id] }
        @tutors = Tutor.where(administrator_id: local_admins.take.id).map { |t| [t.info.name, t.id] }
      elsif session[:type] == 'administrator'
        @tutors = Tutor.where(administrator_id: session[:type_id]).map { |t| [t.info.name, t.id] }
      end
    end
    
    #Loading data for edit.erb page
    def info_for_edit_page
      @is_super_adm = is_super?
      if @is_super_adm
        #Loading Choosing of adm
        local_admins = Administrator.where(is_super: false)
        @admins = local_admins.map { |adm| [adm.info.name, adm.id] }
        @tutors = Tutor.where(administrator_id: local_admins.take.id).map { |t| [t.info.name, t.id] }
        @admins_cur = @admins.to_a.index { |t| t.last == @user.tutor.administrator_id}
        @tutors_cur = @tutors.to_a.index { |t| t.last == @user.tutor.id}
      elsif session[:type] == 'administrator'
        @tutors = Tutor.where(administrator_id: session[:type_id]).map { |t| [t.info.name, t.id] }
        @tutors_cur = @tutors.to_a.index { |t| t.last == @user.tutor.id}
      end
   end
end