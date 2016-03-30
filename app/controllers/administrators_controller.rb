class AdministratorsController < ApplicationController
  before_action :check_log_in, only: [:index,:edit,:update,:show,:destroy]
  before_action :check_rights, only: [:edit,:update,:destroy]
  before_action :check_mail_confirmation, only: [:index,:edit,:update,:show,:destroy]
  #Create Page
  def new
    @user = Administrator.new
    @user_info = Info.new
    @user.info = @user_info
  end

  #Create querry
  def create
    #Loading data
    @user_info = Info.new(info_params)
    @user = Administrator.new(administrator_params)
    @user.info = @user_info
    @user.is_super = false
    @user_info.is_mail_confirmed = is_super?
    #If data ok - creating
    if @user_info.save && @user.save
      flash[:success] = "Account created!"
      redirect_to(@user)
    else
      @user_info.delete
      @user.delete
      render 'new'
    end
  end
  
  #Only for SA
  def index
    administrators = Administrator.all
    @names_admins = []
    administrators.each do |admin|
      @names_admins << Info.find(admin.info_id)
    end
  end

  #Editing page
  def edit
    #finding user
    @user = Administrator.find(params[:id])
    #is exist?
    unless @user.nil?
      #checking rights
      @user_info = Info.find(@user.info_id)
      if @user_info.nil?
        #throw 404
      end
    else
      #throw 404
    end
  end
  
  #Update querry
  def update
    @user = Administrator.find(params[:id])
    @user_info = Info.find(@user.info_id)
    if !@user_info.nil? && !@user.nil? && @user_info.update(info_params) && @user.update(administrator_params)
      redirect_to(@user)
      flash[:success] = "Update Complete"
    else
      render :edit
    end
  end
  
  #Profile page
  def show
    @user = Administrator.find(params[:id])
    find_info(@user) << ["Organisation: ",@user.organisation]
  end

  #Deleting record
  def destroy
    
  end
  
  private
    #Attributes
    def administrator_params
      params.require(:administrator).permit(:organisation)
    end
    def info_params
      params.require(:info).permit(:name,:last_name,:mail,:phone,:password,:password_confirmation)
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
      unless is_super? || session[:user_type] == 'administrator' && session[:type_id] == params[:id]
        flash[:warning] = "You have not access to this page."
        #Redirect back or?
        redirect_to current_user
      end
    end
    
    #Callback for checking confirmation of mail
    def check_mail_confirmation
      user = current_user
      unless user.info.is_mail_confirmed
        flash[:danger] = "You haven't confirmed your mail!\n Please, confirm your mail."
        redirect_to user
      end
    end
end
