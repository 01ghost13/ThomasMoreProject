class AdministratorsController < ApplicationController
  include Recaptcha::ClientHelper
  include Recaptcha::Verify

  before_action :check_log_in, only: [:index,:edit, :update, :show, :delegate]
  before_action :check_rights, only: [:edit, :update, :show]
  before_action :check_type_rights, only: [:edit, :update, :show]
  before_action :check_mail_confirmation, except: [:new, :show, :create]
   #TODO: Create DRY index
  #Create Page
  def new
    if logged_in? && !is_super?
      redirect_back fallback_location: current_user and return
    end
    @user = Administrator.new
    @user_info = Info.new
    @user.info = @user_info
  end

  #Create querry
  def create
    #Loading data
    @user = Administrator.new(administrator_params)
    #If data ok - creating
    if verify_recaptcha(model: @user) && @user.save
      flash[:success] = 'Account created! Confirmation of your account was sent to email.'
      AitscoreMailer.registration_confirmation(@user.info).deliver
      log_in @user.info unless logged_in?
      redirect_to @user
    else
      render :new
    end
  end
  
  #Only for SA
  def index
    unless is_super?
      flash[:danger] = 'You have no access to this page!'
      redirect_to current_user and return
    end
    administrators = Administrator.order(:organisation).all
    #todo change order to order.except superadmin
    @admins = []
    administrators.each do |admin|
      @admins << admin.show_short unless admin.is_super
    end
    @admins = Kaminari.paginate_array(@admins).page(params[:page]).per(5)
  end

  #Editing page
  def edit
    #finding user
    @user = Administrator.find(params[:id])
    #is exist?
    if @user.nil?
      flash[:error] = 'User does not exist.'
      redirect_to current_user
    end
  end
  
  #Update querry
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
    if @user.nil?
      flash[:error] = 'User does not exist.'
      redirect_to :root and return
    end
    @user_info = @user.show.to_a
  end

   #Page of deletion of Admin
  def delegate
    unless is_super?
      flash[:danger] = 'You have no access to this page!'
      redirect_to current_user and return
    end
    @administrator = Administrator.find(params[:id])
    if @administrator.is_super
      flash[:danger] = "You can't delete this administrator!"
      redirect_to current_user and return
    end
    @admins = @administrator.other_administrators
    @tutors = @administrator.tutors.to_a
  end


  def delete
    @administrator = Administrator.find(params[:id])
    if @administrator.is_super
      flash[:danger] = "You can't delete this administrator!"
      redirect_to current_user and return
    end
    if @administrator.tutors.empty? || @administrator.update(delete_administrator_params)
      if @administrator.reload.destroy
        flash[:success] = 'Administrator was deleted!'
        redirect_to administrators_path
      else
        @admins = @administrator.other_administrators
        @user = @administrator
        render :delegate
      end
    else
      @tutors = @administrator.tutors
      @admins = @administrator.other_administrators
      @user = @administrator
      render :delegate
    end
  end

  private
    #Attributes
    def administrator_params
      adm_param = params
      adm_param[:administrator][:info_attributes][:id] = @user.info.id unless params[:id].nil?
      adm_param.require(:administrator).permit(:organisation,:organisation_address,info_attributes: [:id,:name,:last_name,:mail,:phone,:password,:password_confirmation])
    end

    def delete_administrator_params
      params.require(:administrator).permit(tutors_attributes: [:administrator_id, :id])
    end

    #Callback for checking session
    def check_log_in
      unless logged_in?
        flash[:warning] = 'Only registrated people can see this page.'
        #Redirecting to home page
        redirect_to :root 
      end
    end
    
    #Callback for checking rights
    def check_rights
      #Only SA or user can edit/delete their accounts
      unless is_super? || session[:user_type] == 'administrator' && session[:type_id] == params[:id].to_i
        flash[:warning] = 'You have no access to this page.'
        #Redirect
        redirect_to current_user
      end
    end
    
    #Callback for checking confirmation of mail
    def check_mail_confirmation
      user = current_user
      unless session[:user_type] != 'student' && user.info.is_mail_confirmed
        flash[:danger] = "You haven't confirmed your mail! Please, confirm your mail."
        redirect_to :root
      end
    end
    
    #Callback for checking type of user
    def check_type_rights
      unless session[:user_type] == 'administrator' || is_super?
        flash[:danger] = 'You have no access to this page!'
        redirect_to current_user
      end
    end
end
