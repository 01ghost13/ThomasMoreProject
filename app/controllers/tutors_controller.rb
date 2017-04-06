class TutorsController < ApplicationController
  before_action :check_login, only: [:new,:create,:edit,:update,:show,:index,:destroy]
  before_action :check_type_rights, only: [:new,:create,:show,:index]
  before_action :check_rights, only: [:edit,:update,:destroy]
  before_action :check_mail_confirmation
  
  #TODO: Create DRY index
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
    @user = Tutor.new(tutor_params)

    @user.administrator_id = session[:type_id] unless @is_super_admin
    #Can use current_user.id instead session[:type_id]
    
    #If all is ok - creating
    if @user.save
      flash[:success] = 'Account created!'
      redirect_to @user
    else
      render :new
    end 
  end

  #Edit page
  def edit
    #Finding user
    @user = Tutor.find(params[:id])
    #Checking: redirect if can't load user or info
    if @user.nil?
      flash[:danger] = 'User does not exist'
      redirect_to current_user
    else
      @user_info = @user.info
      unless @user_info.nil?
        info_for_forms
        return
      end
      flash[:danger] = "Can't load user information"
      redirect_to current_user
    end
  end
  
  #Update querry
  def update
    #Loading info for page
    info_for_forms
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
    tutors = @is_super_adm ? Tutor.all : Tutor.where(administrator_id: session[:type_id])
    @tutors = []
    tutors.each do |tutor|
      @tutors << tutor.show_short
    end
    @tutors = Kaminari.paginate_array(@tutors).page(params[:page]).per(5)
  end

  #Tutor Profile
  def show
    @user = Tutor.find(params[:id])
    if @user.nil?
      flash[:danger] = 'User does not exist.'
      redirect_to :root and return
    end
    @user_info = @user.show.to_a
  end
  
  #Destroy querry
  def destroy
    
  end
  
  private
    #Login checking
    def check_login
      unless logged_in?
        flash[:warning] = 'Only registrated people can see this page.'
        #Redirecting to home page
        redirect_to :root 
      end
    end
    
    #Rights checking
    def check_rights
      user = Tutor.find(params[:id])
      #It is my page?
      is_i = (session[:user_type] == 'tutor' && session[:type_id] == params[:id].to_i)
      #It is my tutor?
      is_my_tutor = (!user.nil? && session[:user_type] == 'administrator' && user.administrator_id == session[:type_id])
      unless is_i || is_super? || is_my_tutor
        flash[:warning] = 'You have no access to this page.'
        redirect_to current_user
      end  
    end
    
    #Rights of viewing
    def check_type_rights
      is_my_adm = session[:user_type] == 'administrator'
      is_i = (session[:user_type] == 'tutor' && session[:type_id] == params[:id].to_i)
      #Checking creation or showing
      unless params[:id].nil?
        user = Tutor.find(params[:id])
        is_my_adm = (!user.nil? && session[:user_type] == 'administrator' && user.administrator_id == session[:type_id])
      end
      
      #checking rights
      unless is_super? || is_my_adm || is_i
        flash[:warning] = 'You have no access to this page.'
        redirect_to current_user
      end
    end

    #Strict params
    def tutor_params
      t_param = params
      t_param[:tutor][:info_attributes][:id] = @user.info.id unless params[:id].nil?
      t_param.require(:tutor).permit(:administrator_id,info_attributes: [:id,:name,:last_name,:mail,:phone,:password,:password_confirmation])
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
