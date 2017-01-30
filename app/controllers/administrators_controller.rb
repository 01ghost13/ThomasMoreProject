class AdministratorsController < ApplicationController
  before_action :check_log_in, only: [:index,:edit,:update,:show,:destroy]
  before_action :check_rights, only: [:edit,:update,:destroy,:show]
  before_action :check_type_rights, only: [:edit,:update,:show,:destroy]
  before_action :check_mail_confirmation, only: [:edit,:update,:show,:destroy]
   #TODO: Create DRY index
  #Create Page
  def new
    if logged_in? && !is_super?
      redirect_back fallback_location: current_user
      return
    end
    @user = Administrator.new
    @user_info = Info.new
    @user.info = @user_info
  end

  #Create querry
  def create
    #Loading data
    @user = Administrator.new(administrator_params)
    #@user_info.is_mail_confirmed = true
    #If data ok - creating
    if @user.save
      flash[:success] = 'Account created!'
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
      redirect_to current_user
      return
    end
    administrators = Administrator.order(:organisation).all
    @admins = []
    administrators.each do |admin|
      @admins << admin.show_short unless admin.is_super
    end
  end

  #Editing page
  def edit
    #finding user
    @user = Administrator.find(params[:id])
    #is exist?
    unless @user.nil?
      #checking rights
    else
      #throw 404
    end
  end
  
  #Update querry
  def update
    @user = Administrator.find(params[:id])
    #debugger
    if @user.update(administrator_params)
      redirect_to(@user)
      flash[:success] = "Update Complete"
    else
      render :edit
    end
  end
  
  #Profile page
  def show
    @user = Administrator.find(params[:id])
    @user_info = @user.show.to_a
  end

  #Deleting record
  def destroy
    
  end
  
  private
    #Attributes
    def administrator_params
      adm_param = params
      adm_param[:administrator][:info_attributes][:id] = @user.info.id unless params[:id].nil?
      adm_param.require(:administrator).permit(:organisation,:organisation_address,info_attributes: [:id,:name,:last_name,:mail,:phone,:password,:password_confirmation])
    end
    #Callback for checking session
    def check_log_in
      unless logged_in?
        flash[:warning] = "Only registrated people can see this page."
        #Redirecting to home page
        redirect_to :root 
      end
    end
    
    #Callback for checking rights
    def check_rights
      #Only SA or user can edit/delete their accounts
      #debugger
      unless is_super? || session[:user_type] == 'administrator' && session[:type_id] == params[:id].to_i
        flash[:warning] = "You have no access to this page."
        #Redirect back or?
        redirect_to current_user
      end
    end
    
    #Callback for checking confirmation of mail
    def check_mail_confirmation
      user = current_user
      unless session[:user_type] != 'student' && user.info.is_mail_confirmed
        flash[:danger] = "You haven't confirmed your mail! Please, confirm your mail."
        redirect_to user
      end
    end
    
    #Callback for checking type of user
    def check_type_rights
      unless session[:user_type] == 'administrator' || is_super?
        flash[:danger] = "You have no access to this page!"
        redirect_to current_user
      end
    end
end
