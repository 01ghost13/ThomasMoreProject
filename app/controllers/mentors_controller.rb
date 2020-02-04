class MentorsController < ApplicationController

  before_action :check_exist_callback, only: [:edit, :update, :show, :delete, :delegate]
  before_action :check_log_in, only: [:new,:create,:edit,:update,:show,:index,:delegate, :delete]
  before_action :check_type_rights, only: [:new,:create,:index,:delegate, :delete]
  before_action :check_rights, only: [:edit,:update,:show]
  before_action :check_mail_confirmation, except: [:show]
  before_action :info_for_forms, only: [:new, :create, :edit, :update]

  #Create mentor page
  def new
    #Creating mentor obj
    @user = Mentor.new
    @user_info = Info.new
    @user.info = @user_info
  end

  #Action for create
  def create
    #Loading info
    @user = Mentor.new(mentor_params)

    @user.administrator_id = session[:type_id] unless @is_super_admin
    
    #If all is ok - creating
    if @user.save
      flash[:success] = 'Account created!'
      begin
        AitscoreMailer.registration_confirmation(@user.info).deliver
      rescue => e
        Rails.logger.error("Failed to email: \n #{e.backtrace}")
      end
      redirect_to @user
    else
      render :new
    end
  end

  #Edit profile page
  def edit
    #Finding user
    @user = Mentor.find(params[:id])
  end
  
  #Action for updating user
  def update
    #Finding mentor
    @user = Mentor.find(params[:id])
    #If mentor exit and data - OK, changing
    if @user.update(mentor_params)
      flash[:success] = 'Update Complete'
      redirect_to @user
    else
      render :edit
    end
    
  end

  #All mentors page
  def index
    unless session[:user_type] == 'administrator'
      flash[:danger] = 'You have no access to this page!'
      redirect_to current_user and return
    end
    @is_super_adm = is_super?

    #Loading all mentors if super admin
    @q = Mentor.all_mentors
    @q = if @is_super_adm
           @q
         else
           @q.mentors_of_administrator(session[:type_id])
         end
    @q = @q.ransack(params[:q])

    @mentors = params[:q] && params[:q][:s] ? @q.result.order(params[:q][:s]) : @q.result
    @mentors = @mentors.page(params[:page]).per(5)
  end

  #Profile page
  def show
    @user = Mentor.find(params[:id])
    @user_info = @user.show.to_a
  end

  #Page of deletion of Mentor
  def delegate
    @mentor = Mentor.find(params[:id])
    @mentors = @mentor.other_mentors
  end

  #Action for deleting Mentor
  def delete
    @mentor = Mentor.find(params[:id])
    if @mentor.clients.empty? || @mentor.update(delete_mentor_params)
      if @mentor.reload.destroy
        flash[:success] = 'Mentor was deleted!'
        redirect_to mentors_path and return
      end
    end

    @mentors = @mentor.other_mentors
    @user = @mentor
    render :delegate
  end
  ##########################################################
  #Private methods
  private
  #Rights checking
  def check_rights
    user = Mentor.find(params[:id])
    #It is my page?
    is_i = (session[:user_type] == 'mentor' && session[:type_id] == params[:id].to_i)
    #It is my mentor?
    is_my_mentor = (!user.nil? && session[:user_type] == 'administrator' && user.administrator_id == session[:type_id])
    unless is_i || is_super? || is_my_mentor
      flash[:danger] = 'You have no access to this page.'
      redirect_to current_user
    end
  end

  #Rights of viewing
  def check_type_rights
    is_my_adm = session[:user_type] == 'administrator'
    #Checking creation or showing
    unless params[:id].nil?
      user = Mentor.find(params[:id])
      is_my_adm = (!user.nil? && session[:user_type] == 'administrator' && user.administrator_id == session[:type_id])
    end

    #checking rights
    unless is_super? || is_my_adm
      flash[:danger] = 'You have no access to this page.'
      redirect_to current_user
    end
  end

  #Attributes for forms
  def mentor_params
    t_param = params
    t_param[:mentor][:info_attributes][:id] = @user.info.id unless params[:id].nil?
    t_param.require(:mentor).permit(:administrator_id,info_attributes: [:id,:name,:last_name,:mail,:phone,:password,:password_confirmation])
  end

  #Attributes for delete forms
  def delete_mentor_params
    params.require(:mentor).permit(clients_attributes: [:mentor_id, :id])
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
    unless check_exist(params[:id], Mentor)
      redirect_to current_user
    end
  end
end
