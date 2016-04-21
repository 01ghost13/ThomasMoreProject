class TutorsController < ApplicationController
  before_action :check_login, only: [:new,:create,:edit,:update,:show,:index,:destroy]
  before_action :check_type_rights, only: [:new,:create,:show,:index]
  before_action :check_rights, only: [:edit,:update,:destroy]
  before_action :check_mail_confirmation
  
  #New tutor page
  def new
    #Loading info for page
    info_for_forms
    
    #Creating tutor obj
    @user = Tutor.new
    @user_info = Info.new
    @user.info = @user_info 
  end
  
  #Create querry
  def create
    #Reloading info for page
    info_for_forms
        
    #Loading info
    @user = Tutor.new
    @user_info = @user.build_info(info_params)
    @user_info.is_mail_confirmed = true
    @user_info.is_mail_confirmed = true if @is_super_admin
    @user.administrator_id = @is_super_admin ? tutor_params[:administrator_id] : session[:type_id]
    #Can use current_user.id instead session[:type_id]
    
    #If all is ok - creating
    if @user.save && @user_info.save
      flash[:success] = "Account created!"
      redirect_to @user
      #Which redirect is best? To my profile or to created?
    else
      render 'new'
    end 
  end

  #Edit page
  def edit
    #Finding user
    @user = Tutor.find(params[:id])
    #Checking: is tutor page real?
    unless @user.nil?
      #Loading info
      @user_info = @user.info
      #Cheking logging
      unless @user_info.nil?
        #loading info for SA
        info_for_forms
      else
        #throw 404
      end
    else
       #throw 404
    end
  end
  
  #Update querry
  def update
    #Loading info for page
    info_for_forms
    
    #Finding tutor
    @user = Tutor.find(params[:id])
    @user_info = @user.info
    #If tutor exit and data - OK, changing
    if !@user_info.nil? && !@user.nil? && @user.update(tutor_params) && @user_info.update(info_params)
      redirect_to(@user)
      flash[:success] = "Update Complete"
    else
      render :edit
    end
    
  end

  #All tutors page
  def index
  end

  #Tutor Profile
  def show
    @user = Tutor.find(params[:id])
    @user_info = @user.show.to_a
  end
  
  #Destroy querry
  def destroy
    
  end
  
  private
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
      user = Tutor.find(params[:id])
      #It is my page?
      is_i = (session[:user_type] == 'tutor' && session[:type_id] == params[:id])
      #It is my tutor?
      is_my_adm = (!user.nil? && session[:user_type] == 'administrator' && user.administrator_id == session[:type_id])
      unless is_i || is_super? || is_my_adm
        flash[:warning] = "You have no access to this page."
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
        flash[:warning] = "You have no access to this page."
        redirect_to current_user
      end
    end
    #Strict params
    def tutor_params
      params.require(:tutor).permit(:administrator_id)
    end
    def info_params
      params.require(:info).permit(:name,:last_name,:mail,:phone,:password,:password_confirmation)
    end

    #Callback for checking confirmation of mail
    def check_mail_confirmation
      user = current_user
      unless user.info.is_mail_confirmed
        flash[:danger] = "You haven't confirmed your mail!\n Please, confirm your mail."
        log_out
      end
    end
    
    #Loads info for creation/new pages
    def info_for_forms
      #Info for page
      #Saving info if we are SA
      @is_super_admin = is_super?    
      #Array of admins for SA
      @admins = Administrator.admins_list if @is_super_admin
    end
end
