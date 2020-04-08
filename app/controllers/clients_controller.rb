class ClientsController < ApplicationController
  before_action :check_exist_callback, only: [:destroy, :edit, :update, :show, :mode_settings]
  before_action :check_log_in, only: [:new, :create, :index, :update, :edit, :destroy, :show, :mode_settings]
  before_action :check_rights, only: [:new, :create, :index]
  before_action :check_editing_rights, only: [:update, :edit, :destroy, :show, :mode_settings]
  before_action :info_for_new_page, only: [:create, :new]
  before_action :check_deactivated, only: [:edit, :update, :mode_settings]

  #New client page
  def new
    @user = Client.new
  end
  
  #Action for create client
  def create
    #Creating client
    @user = Client.new(client_params)
    @user.mentor_id = current_user.role_model.id if current_user.mentor?
    
    #trying to save
    if @user.save
      flash[:success] = 'Account created!'
      redirect_to @user
    else
      render :new
    end
  end

  #Action for hiding and deleting clients
  def destroy
    client = Client.find(params[:id])
    if params[:paranoic] == 'true' || params[:paranoic] == nil
      if client.hide
        flash[:success] = 'Client was hided/recovered.'
      else
        flash[:warning] = "Can't hide/recover client"
      end
    elsif params[:paranoic] == 'false' && is_super?
      #True deleting
      if client.destroy
        flash[:success] = 'Client was deleted.'
      else
        flash[:danger] = "You can't delete this client"
      end
    end
    redirect_back fallback_location: current_user
  end
  
  #Update client profile page
  def edit
    @user = Client.find(params[:id])
    info_for_edit_page
  end
  
  #Action for updating
  def update
    @user = Client.find(params[:id])
    if @user.update(client_update_params)
      flash[:success] = 'Update Complete'
      redirect_to @user
    else
      info_for_edit_page
      render :edit
    end
  end
  
  #Profile page
  def show
    @user = Client.find(params[:id])
    @is_super_adm = is_super?
    @is_my_client = current_user.mentor? && @user.mentor_id == current_user.role_model.id
    @is_client_of_my_mentor = current_user.local_admin? && @user.mentor.administrator_id == current_user.role_model.id
    unless @user.is_active
      #Client is inactive
      flash[:warning] = 'Client was deactivated in: ' + @user.date_off.to_s
      unless is_super?
        redirect_to clients_path
        return
      end
    end
    @user_info = @user.show_info.to_a
    #Loading all test results
    @test_results = []
    ResultOfTest.order(:created_at).reverse_order.where(client_id: @user.id).limit(5).each do |res|
      @test_results << res.show_short
    end
  end
  
  #Function for ajax updating
  def update_mentors
    @mentors = Mentor.mentors_list(params[:administrator_id])
    respond_to do |format|
       format.js {}
    end
  end

  #List of clients
  def index
    if current_user.client?
      flash[:danger] = 'You have no access to this page!'
      redirect_to current_user.role_model and return
    end
    @is_super_adm = is_super?
    if @is_super_adm
      @q = Client.all_clients.ransack(params[:q])
    elsif current_user.mentor?
      @q = Client.clients_of_mentor(current_user.role_model.id).ransack(params[:q])
    elsif current_user.local_admin?
      @q = Client.clients_of_admin(current_user.role_model.id).ransack(params[:q])
    end
    @clients = params[:q] && params[:q][:s] ? @q.result.order(params[:q][:s]) : @q.result
    @clients = @clients.page(params[:page]).per(5)
  end

  # Page for editing modes
  def mode_settings
    @user = Client.find(params[:id])
  end

  # Update edited modes
  def update_mode_settings
    @user = Client.find(params[:id])
    if @user.update(mode_params)
      flash[:success] = 'Update Complete'
      redirect_to tests_client_path(params[:id])
    else
      render :mode_settings
    end
  end

  ##########################################################
  #Private methods
  private
  #Attributes for creation page
  def client_params
    params.require(:client).permit(:code_name,:mentor_id,:gender,
                                    :is_current_in_school,:password,:password_confirmation)
  end

  def mode_params
    params.require(:client).permit(:gaze_trace, :emotion_recognition)
  end

  #Attributes for edit page
  def client_update_params
    if current_user.local_admin?
      params[:client][:mentor_id] ||= ''
      params.require(:client).permit(:code_name,:mentor_id,:gender,
                                      :is_current_in_school,:password,:password_confirmation)
    else
      params.require(:client).permit(:code_name,:gender,
                                      :is_current_in_school,:password,:password_confirmation)
    end
  end

  #Rights checking
  def check_rights
    #Sa, admin, mentor
    unless is_super? || current_user.local_admin? || current_user.mentor?
      flash[:danger] = 'You have no access to this page.'
      redirect_to current_user.role_model
    end
  end

  #Rights of editing profile
  def check_editing_rights
    user = Client.find(params[:id])
    is_super_adm = is_super?
    is_my_client = current_user.mentor? && user.mentor_id == current_user.role_model.id
    is_client_of_my_mentor = current_user.local_admin? && user.mentor.administrator_id == current_user.role_model.id
    is_i = current_user.client? && user.id == current_user.role_model.id
    unless is_super_adm || is_my_client || is_client_of_my_mentor || is_i
      flash[:warning] = 'You have no access to this page.'
      redirect_to current_user.role_model
    end
  end

  #Loads info for 'new' page
  def info_for_new_page
    @is_super_adm = is_super?
    if @is_super_adm
      #Loading Choosing of adm
      @admins = Administrator.admins_list
      if @admins.empty?
        @mentors = []
      else
        @mentors = Mentor.mentors_list(@admins.first[1])
      end
    elsif current_user.local_admin?
      @mentors = Mentor.mentors_list(current_user.role_model.id)
    end
  end

  #Loading data for edit page
  def info_for_edit_page
    @is_super_adm = is_super?
    if @is_super_adm
      #Loading Choosing of adm
      @admins = Administrator.admins_list
      if @admins.empty?
        @mentors = []
      else
        if @user.mentor
          @admins_cur = @user.mentor.administrator_id
          @mentors = Mentor.mentors_list(@admins_cur)
          @mentors_cur = @user.mentor_id
        else
          @admins_cur = params[:administrator_id]
          @mentors = Mentor.mentors_list(@admins_cur)
          @mentors_cur = 0
        end
      end
    elsif current_user.local_admin?
      @mentors = Mentor.mentors_list(current_user.role_model.id)
      @mentors_cur = @user.mentor_id
    end
  end

  #Callback for checking existence of record
  def check_exist_callback
    unless check_exist(params[:id], Client)
      redirect_to current_user.role_model
    end
  end

  #Callback for checking deactivated clients
  def check_deactivated
    @user = Client.find(params[:id])
    if !is_super? && @user.date_off != nil
      flash[:warning] = "You can't edit deactivated client!"
      redirect_back fallback_location: current_user
    end
  end
end
