class AdministratorsController < ApplicationController
  include Recaptcha::ClientHelper
  include Recaptcha::Verify

  before_action :check_exist_callback, only: [:edit, :update, :show, :delete, :delegate]
  before_action :check_log_in, only: [:index,:edit, :update, :show, :delegate]
  before_action :check_rights, only: [:edit, :update, :show]
  before_action :check_type_rights, only: [:edit, :update, :show]
  before_action :check_mail_confirmation, except: [:new, :show, :create]
  before_action :check_super_admin, only: [:index, :delegate, :delete]

  #Create admin page
  def new
    #If super administrator, then have access
    if logged_in? && !is_super?
      redirect_back fallback_location: current_user and return
    end
    #Loading info for viewing
    @user = Administrator.new
    @user_info = Info.new
    @user.info = @user_info
  end

  #Action for create
  def create
    #Loading data
    @user = Administrator.new(administrator_params)
    #If data ok - creating
    if verify_recaptcha(model: @user) && @user.save
      flash[:success] = 'Account created! Confirmation of account was sent to email.'
      AitscoreMailer.registration_confirmation(@user.info).deliver
      #Logging in as a new user if not logged
      log_in @user.info unless logged_in?
      redirect_to @user
    else
      render :new
    end
  end
  
  #Page with list of admins
  def index
    @q = Administrator.all_administrators.ransack(params[:q])
    @admins = params[:q] && params[:q][:s] ? @q.result.order(params[:q][:s]) : @q.result
    @admins = @admins.page(params[:page]).per(5)
  end

  #Edit profile page
  def edit
    @user = Administrator.find(params[:id])
  end
  
  #Action for updating user
  def update
    @user = Administrator.find(params[:id])

    if @user.update(administrator_params)
      flash[:success] = 'Update Complete'
      redirect_to @user
    else
      render :edit
    end
  end

  #Profile page
  def show
    @user = Administrator.find(params[:id])
    #Gaining info for profile
    @user_info = @user.show.to_a
  end

  #Page of deletion of admins
  def delegate
    @administrator = load_admin_for_deletion

    #Loading information about tutors and admins for page
    @admins = @administrator.other_administrators
  end

  #Action for deleting admin
  def delete
    @administrator = load_admin_for_deletion

    #Admin can be deleted only if hasn't tutors
    if @administrator.tutors.empty? || @administrator.update(delete_administrator_params)
      if @administrator.reload.destroy
        flash[:success] = 'Administrator was deleted!'
        redirect_to administrators_path and return
      end
    end

    @admins = @administrator.other_administrators
    @user = @administrator
    render :delegate
  end
  ##########################################################
  #Private methods
  private
  def load_admin_for_deletion
    administrator = Administrator.find(params[:id])
    #Blocking a deletion of super administrator
    if administrator.is_super
      flash[:danger] = "You can't delete this administrator!"
      redirect_to current_user
    end
    administrator
  end

  #Attributes for forms
  def administrator_params
    adm_param = params
    adm_param[:administrator][:info_attributes][:id] = @user.info.id unless params[:id].nil?
    adm_param.require(:administrator).permit(:organisation,:organisation_address,info_attributes: [:id,:name,:last_name,:mail,:phone,:password,:password_confirmation])
  end

  #Attributes for delete forms
  def delete_administrator_params
    params.require(:administrator).permit(tutors_attributes: [:administrator_id, :id])
  end

  #Callback for checking rights
  def check_rights
    #Only SA or user can edit/delete their accounts
    unless is_super? || session[:user_type] == 'administrator' && session[:type_id] == params[:id].to_i
      flash[:danger] = 'You have no access to this page.'
      #Redirect
      redirect_to current_user
    end
  end

  #Callback for checking type of user
  def check_type_rights
    unless session[:user_type] == 'administrator' || is_super?
      flash[:danger] = 'You have no access to this page!'
      redirect_to current_user
    end
  end

  #Callback for checking existence of record
  def check_exist_callback
    unless check_exist(params[:id], Administrator)
      redirect_to current_user
    end
  end
end
