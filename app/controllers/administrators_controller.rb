class AdministratorsController < ApplicationController
  
  def find_admInfo(adm_id)
    adm = Administrator.find(adm_id)
    unless adm.nil?
      user = Info.find(adm.info_id)
      @user_info = [['Name: ', user.name],['Last name: ', user.last_name],['Phone: ', user.phone],['Mail: ', user.mail],['Organisation: ',adm.organisation]]
      @confirmed_mail = user.is_mail_confirmed || true
      @is_super_adm = adm.is_super
      return @user_info
    else
       #Throw error of 404
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
    @user = Administrator.find(params[:id])
    
    unless @user.nil?
      #checking rights
      if is_super? || current_user.id == @user.id
        @user_info = Info.find(@user.info_id)
        if @user_info.nil?
          #throw 404
        end
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
    find_admInfo(params[:id])
  end

  #Create Page
  def new
    @user = Administrator.new
    @user_info = Info.new
    @user.info = @user_info
  end
  #Create querry
  def create
    @user_info = Info.new(info_params)
    @user = Administrator.new(administrator_params)
    @user.info = @user_info
    @user.is_super = false
    @user_info.is_mail_confirmed = false
    if @user_info.save && @user.save
      flash[:success] = "Account created!"
      redirect_to(@user)
    else
      render 'new'
    end
  end
  private
  #Attributes
  def administrator_params
    params.require(:administrator).permit(:organisation)
  end
  def info_params
    params.require(:info).permit(:name,:last_name,:mail,:phone,:password,:password_confirmation)
  end
end
