class TutorsController < ApplicationController
  def new
    unless logged_in? && session[:user_type] == 'administrator'
      #Try another type of checking
      flash[:warning] = "Only registrated people can see this page"
      redirect_to :root
    end
    @user = Tutor.new
    @user_info = Info.new
    @user.info = @user_info
    @is_super_admin = is_super?
    @admins = find_admins
  end
  
  def create
    #Finding out about creating user
    @admins = find_admins
    @is_super_admin = is_super?
    @user = Tutor.new
    @user_info = @user.build_info(info_params)
    @user_info.is_mail_confirmed = @is_super_admin    
    #@user.info = @user_info
    @user.administrator_id = @is_super_admin ? tutor_params[:administrator_id] : session[:type_id]
    #Can use current_user.id instead session[:type_id]
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

  def edit
    @user = Tutor.find(params[:id])
    @user_info = @user.info
    #Checking: is tutor page real?
    unless @user.nil?
      #Cheking logging
      if logged_in?
        #checking rights
        #It is my profile?
        is_i = (session[:user_type] == 'tutor' && session[:type_id] == params[:id])
        #it is my tutor?
        is_my_adm = (session[:user_type] == 'administrator' && @user.administrator_id == session[:type_id])
        unless is_i || is_super? || is_my_adm
          flash[:warning] = "You have not access to this page"
          redirect_to current_user
        end  
      else
          flash[:warning] = "Only registrated people can see this page"
          redirect_to :root
      end
    else
       #throw 404
    end
    #loading info for SA
    @admins = find_admins
    @is_super_admin = is_super?
  end
  
  def update
    @admins = find_admins
    @is_super_admin = is_super?
    @user = Tutor.find(params[:id])
    @user_info = @user.info
    if !@user_info.nil? && !@user.nil? && @user_info.update(info_params) && @user.update(tutor_params)
      redirect_to(@user)
      flash[:success] = "Update Complete"
    else
      render :edit
    end
  end

  def index
  end

  def show
    @user = Tutor.find(params[:id])
    adm = Administrator.find(@user.administrator_id)
    find_info(@user) << ["Administrator: ", "#{adm.info.name}\n#{adm.info.last_name}"]
  end
  private
    def tutor_params
      params.require(:tutor).permit(:administrator_id)
    end
    def info_params
      params.require(:info).permit(:name,:last_name,:mail,:phone,:password,:password_confirmation)
    end
    def find_admins
      admins = []
      admins_hash = Administrator.all.where(is_super: false)
      admins_hash.each do |admin|
        admins << ["#{admin.organisation}:#{admin.info.last_name} #{admin.info.name}",admin.id]
      end
      return admins
    end
end
