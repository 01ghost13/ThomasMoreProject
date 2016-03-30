class TutorsController < ApplicationController
  before_action :check_login, only: [:new,:create,:edit,:update,:destroy]
  before_action :check_rights, only: [:edit,:update,:destroy]
  before_action :check_mail_confirmation
  #New tutor page
  def new
    #Only adm can create tutors
    unless session[:user_type] == 'administrator'
      flash[:warning] = "You have not acces to this page"
      redirect_to current_user
    end
    
    #Creating tutor obj
    @user = Tutor.new
    @user_info = Info.new
    @user.info = @user_info
    
    #Info for page
    #Saving info if we are SA
    @is_super_admin = is_super?    
    #Array of admins for SA
    @admins = find_admins if @is_super_admin
  end
  
  #Create querry
  def create
    #Reloading info for page
    @is_super_admin = is_super?
    @admins = find_admins if @is_super_admin
    @user = Tutor.new
    
    #Loading info
    @user_info = @user.build_info(info_params)
    @user_info.is_mail_confirmed = @is_super_admin
    @user.administrator_id = @is_super_admin ? tutor_params[:administrator_id] : session[:type_id]
    #Can use current_user.id instead session[:type_id]
    
    #If all is ok - creating
    if @user_info.save && @user.save
      flash[:success] = "Account created!"
      redirect_to(@user)
      #Which redirect is best? To my profile or to created?
    else
      @user_info.delete
      @user.delete
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
        @is_super_admin = is_super?
        @admins = find_admins if @is_super_admin
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
    @is_super_admin = is_super?
    @admins = find_admins if @is_super_admin
    
    #Finding tutor
    @user = Tutor.find(params[:id])
    @user_info = @user.info
    #If tutor exit and data - OK, changing
    if !@user_info.nil? && !@user.nil? && @user_info.update(info_params) && @user.update(tutor_params)
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
    adm = Administrator.find(@user.administrator_id)
    find_info(@user) << ["Administrator: ", "#{adm.info.name}\n#{adm.info.last_name}"]
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
        flash[:warning] = "You have not access to this page."
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
    
    #Array of admins
    def find_admins
      admins = []
      admins_hash = Administrator.all.where(is_super: false)
      admins_hash.each do |admin|
        admins << ["#{admin.organisation}:#{admin.info.last_name} #{admin.info.name}",admin.id]
      end
      return admins
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
