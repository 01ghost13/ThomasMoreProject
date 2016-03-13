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
    @local_admin = Administrator.find(params[:id])
    unless @local_admin.nil?
      @user = Info.find(@local_admin.info_id)
      if @user.nil?
        #throw 404
      end
    else
      #throw 404
    end
  end
  #Update querry
  def update
    @local_admin = Administrator.find(params[:id])
    @user = Info.find(@local_admin.info_id)
    @brkpnt = info_params
    if @local_admin.update_attributes(administrator_params) && @user.update_attributes(info_params)
      redirect_to(@local_admin)
      flash[:success] = "Update Complete"
    else
      render :edit
    end
  end
  def update_password
    
  end
  #Profile page
  def show
    find_admInfo(params[:id])
  end

  #Create Page
  def new
  end
  #Create querry
  def create
    
  end
  #Attributes
  def administrator_params
    params.require(:administrator).permit(:organisation)
  end
  def info_params
    params.require(:info).permit(:name,:last_name,:mail,:phone)
  end
  def password_params
    params.require(:info).permit(:password,:password_confirmation)
  end
end
