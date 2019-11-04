class TutorsController < ApplicationController

  before_action :check_exist_callback, only: [:edit, :update, :show, :delete, :delegate]
  before_action :check_log_in, only: [:new,:create,:edit,:update,:show,:index,:delegate, :delete]
  before_action :check_type_rights, only: [:new,:create,:index,:delegate, :delete]
  before_action :check_rights, only: [:edit,:update,:show]
  before_action :check_mail_confirmation, except: [:show]
  before_action :info_for_forms, only: [:new, :create, :edit, :update]

  #Create tutor page
  def new
    #Creating tutor obj
    @user = Tutor.new
    @user_info = Info.new
    @user.info = @user_info
  end

  #Action for create
  def create
    #Loading info
    @user = Tutor.new(tutor_params)

    @user.administrator_id = session[:type_id] unless @is_super_admin
    
    #If all is ok - creating
    if @user.save
      flash[:success] = 'Account created!'
      AitscoreMailer.registration_confirmation(@user.info).deliver
      redirect_to @user
    else
      render :new
    end
  end

  #Edit profile page
  def edit
    #Finding user
    @user = Tutor.find(params[:id])
  end
  
  #Action for updating user
  def update
    #Finding tutor
    @user = Tutor.find(params[:id])
    #If tutor exit and data - OK, changing
    if @user.update(tutor_params)
      flash[:success] = 'Update Complete'
      redirect_to @user
    else
      render :edit
    end
    
  end

  #All tutors page
  def index
    unless session[:user_type] == 'administrator'
      flash[:danger] = 'You have no access to this page!'
      redirect_to current_user and return
    end
    @is_super_adm = is_super?
    #Loading all tutors if super admin
    if @is_super_adm
        @q = Tutor.all_tutors.ransack(params[:q])
      else
        @q = Tutor.tutors_of_administrator(session[:type_id]).ransack(params[:q])
    end
    @tutors = params[:q] && params[:q][:s] ? @q.result.order(params[:q][:s]) : @q.result
    @tutors = @tutors.page(params[:page]).per(5)
  end

  #Profile page
  def show
    @user = Tutor.find(params[:id])
    @user_info = @user.show.to_a
  end

  #Page of deletion of Tutor
  def delegate
    @tutor = Tutor.find(params[:id])
    @tutors = @tutor.other_tutors
  end

  #Action for deleting Tutor
  def delete
    @tutor = Tutor.find(params[:id])
    if @tutor.clients.empty? || @tutor.update(delete_tutor_params)
      if @tutor.reload.destroy
        flash[:success] = 'Tutor was deleted!'
        redirect_to tutors_path and return
      end
    end

    @tutors = @tutor.other_tutors
    @user = @tutor
    render :delegate
  end
  ##########################################################
  #Private methods
  private
  #Rights checking
  def check_rights
    user = Tutor.find(params[:id])
    #It is my page?
    is_i = (session[:user_type] == 'tutor' && session[:type_id] == params[:id].to_i)
    #It is my tutor?
    is_my_tutor = (!user.nil? && session[:user_type] == 'administrator' && user.administrator_id == session[:type_id])
    unless is_i || is_super? || is_my_tutor
      flash[:danger] = 'You have no access to this page.'
      redirect_to current_user
    end
  end

  #Rights of viewing
  def check_type_rights
    is_my_adm = session[:user_type] == 'administrator'
    #Checking creation or showing
    unless params[:id].nil?
      user = Tutor.find(params[:id])
      is_my_adm = (!user.nil? && session[:user_type] == 'administrator' && user.administrator_id == session[:type_id])
    end

    #checking rights
    unless is_super? || is_my_adm
      flash[:danger] = 'You have no access to this page.'
      redirect_to current_user
    end
  end

  #Attributes for forms
  def tutor_params
    t_param = params
    t_param[:tutor][:info_attributes][:id] = @user.info.id unless params[:id].nil?
    t_param.require(:tutor).permit(:administrator_id,info_attributes: [:id,:name,:last_name,:mail,:phone,:password,:password_confirmation])
  end

  #Attributes for delete forms
  def delete_tutor_params
    params.require(:tutor).permit(clients_attributes: [:tutor_id, :id])
  end

  #Loads info for creation/new pages
  def info_for_forms
    #Info for page
    #Saving info if we are SA
    @is_super_admin = is_super?
    #Array of admins for SA
    @admins = Administrator.admins_list if @is_super_admin
  end

  #Callback for checking existence of record
  def check_exist_callback
    unless check_exist(params[:id], Tutor)
      redirect_to current_user
    end
  end
end
