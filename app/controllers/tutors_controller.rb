class TutorsController < ApplicationController
  def new
    #debugger
    unless logged_in? && session[:user_type] == 'administrator'
      #Try another type of checking
      flash[:warning] = "Only registrated people can see this page"
      redirect_to :root
    end
    @user = Tutor.new
    @user_info = Info.new
    @user.info = @user_info
    @is_super_admin = is_super?
    @admins = []
    admins_hash = Administrator.all.where(is_super: false)
    admins_hash.each do |admin|
      @admins << ["#{admin.organisation}:#{admin.info.last_name} #{admin.info.name}",admin.id]
    end
  end
  
  def create
    #Finding out about creating user
    is_sa = is_super?
    @user = Tutor.new
    @user_info = @user.build_info(info_params)
    @user_info.is_mail_confirmed = is_sa    
    #@user.info = @user_info
    @user.administrator_id = is_sa ? tutor_params[:administrator_id] : session[:type_id]
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
  end
  
  def update
    
  end

  def index
  end

  def show
    user = Tutor.find(params[:id])
    adm = Administrator.find(user.administrator_id)
    find_info(user) << ["Administrator: ", "#{adm.info.name}\n#{adm.info.last_name}"]
  end
  private
    def tutor_params
      params.require(:tutor).permit(:administrator_id)
    end
    def info_params
      params.require(:info).permit(:name,:last_name,:mail,:phone,:password,:password_confirmation)
    end
end
