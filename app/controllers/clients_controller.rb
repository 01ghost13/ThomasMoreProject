class ClientsController < AdminController
  before_action :check_exist_callback, only: [:destroy, :edit, :update, :show, :mode_settings]
  # before_action :check_log_in, only: [:new, :create, :index, :update, :edit, :destroy, :show, :mode_settings]
  before_action :check_rights, only: [:new, :create, :index]
  before_action :check_editing_rights, only: [:update, :edit, :destroy, :show, :mode_settings]
  before_action :info_for_new_page, only: [:create, :new]
  before_action :check_deactivated, only: [:edit, :update, :mode_settings]

  def new
    @user = User.new
    @user.build_client
  end
  
  def create
    @user = User.new(client_params)
    @user.role = :client
    @user.userable = @user.build_client(client_params[:client_attributes])

    if @user.save
      flash[:success] = 'Account created!'
      redirect_to client_path(@user)
    else
      render :new
    end
  end

  def destroy
    client = User.find(params[:id])

    if params[:paranoic] == 'true' || params[:paranoic] == nil
      if client.hide
        flash[:success] = 'Client was hided/recovered.'
      else
        flash[:warning] = "Can't hide/recover client"
      end
    elsif params[:paranoic] == 'false' && is_super?
      # True deleting
      if client.destroy
        flash[:success] = 'Client was deleted.'
      else
        flash[:danger] = "You can't delete this client"
      end
    end

    redirect_back fallback_location: show_path_resolver(current_user)
  end
  
  def edit
    @user = User.find(params[:id])
    info_for_edit_page
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update(client_params)
      flash[:success] = 'Update Complete'
      redirect_to client_path(@user)
    else
      info_for_edit_page
      render :edit
    end
  end
  
  def show
    @user = User.find(params[:id])
    client = @user.role_model

    @is_super_adm = is_super?
    @is_my_client = current_user.mentor? && client.employee_id == current_user.role_model.id
    @is_client_of_my_mentor = current_user.local_admin? && client.employee.employee_id == current_user.role_model.id

    unless @user.is_active
      # Client is inactive
      flash[:warning] = 'Client was deactivated in: ' + @user.date_off.to_s
      unless is_super?
        redirect_to clients_path
        return
      end
    end

    @user_info = @user.show.to_a
    # Loading all test results
    @test_results = []
    ResultOfTest.order(:created_at).reverse_order.where(client_id: client.id).limit(5).each do |res|
      @test_results << res.show_short
    end
  end
  
  # Function for ajax updating
  def update_mentors
    @mentors = User.mentors_list(params[:administrator_id])
    respond_to do |format|
       format.js {}
    end
  end

  def index
    if current_user.client?
      flash[:danger] = 'You have no access to this page!'
      redirect_to show_path_resolver(current_user) and return
    end
    @is_super_adm = is_super?
    @q =
        if @is_super_adm
          User.all_clients_ransack
        elsif current_user.mentor?
          User.clients_of_mentor(current_user.role_model.id)
        elsif current_user.local_admin?
          User.clients_of_admin(current_user.role_model.id)
        end
    @q = @q.ransack(params[:q])
    @clients = params[:q] && params[:q][:s] ? @q.result.order(params[:q][:s]) : @q.result
    @clients = @clients.page(params[:page]).per(5)
    # @clients = @clients.includes(:client, client: [:employee, employee: :user]).page(params[:page]).per(5)
  end

  # Page for editing modes
  def mode_settings
    @user = User.find(params[:id])
  end

  # Update edited modes
  def update_mode_settings
    @user = User.find(params[:id])
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

  def client_params
    params
      .require(:user)
      .permit(
        :password,
        :password_confirmation,
        client_attributes: %i[code_name employee_id gender is_current_in_school],
      )
      .tap do |p|
        # HACK FOR DEVISE TO WORK
        # TODO FIX THIS LATER

        p.delete(:password) if p[:password].blank?
        p.delete(:password_confirmation) if p[:password_confirmation].blank?
        p[:email] = "#{p.dig(:client_attributes, :code_name).gsub(' ','')}@mail.com"

        if current_user.mentor?
          p[:client_attributes][:employee_id] = current_user.role_model.id
        end
      end
  end

  def mode_params
    params
      .require(:user)
      .permit(client_attributes: %i[gaze_trace emotion_recognition])
  end

  #Rights checking
  def check_rights
    #Sa, admin, mentor
    unless is_super? || current_user.local_admin? || current_user.mentor?
      flash[:danger] = 'You have no access to this page.'
      redirect_to show_path_resolver(current_user)
    end
  end

  #Rights of editing profile
  def check_editing_rights
    user = User.find(params[:id])
    client = user.role_model
    is_super_adm = is_super?
    is_my_client = current_user.mentor? && client.employee_id == current_user.role_model.id
    is_client_of_my_mentor = current_user.local_admin? && client.employee.employee_id == current_user.role_model.id
    is_i = current_user.client? && user.id == current_user.id
    unless is_super_adm || is_my_client || is_client_of_my_mentor || is_i
      flash[:warning] = 'You have no access to this page.'
      redirect_to show_path_resolver(current_user)
    end
  end

  # Loads info for 'new' page
  def info_for_new_page
    @is_super_adm = is_super?

    if @is_super_adm
      # Loading Choosing of adm
      @admins = User.admins_list

      @mentors =
        if @admins.empty?
          []
        else
          User.mentors_list(@admins.first[1])
        end
    elsif current_user.local_admin?
      @mentors = User.mentors_list(current_user.role_model.id)
    end
  end

  # Loading data for edit page
  def info_for_edit_page
    @is_super_adm = is_super?

    if @is_super_adm
      # Loading Choosing of adm
      @admins = User.admins_list

      if @admins.empty?
        @mentors = []
      else
        employee = @user.employee
        if employee.present?
          @admins_cur = employee.employee_id
          @mentors_cur = @user.employee_id
        else
          @admins_cur = params[:administrator_id]
          @mentors_cur = 0
        end
        @mentors = User.mentors_list(@admins_cur)
      end
    elsif current_user.local_admin?
      @mentors = User.mentors_list(current_user.role_model.id)
      @mentors_cur = @user.employee_id
    end
  end

  # Callback for checking existence of record
  def check_exist_callback
    unless check_exist(params[:id], User)
      redirect_to show_path_resolver(current_user)
    end
  end

  # Callback for checking deactivated clients
  def check_deactivated
    @user = User.find(params[:id])
    if !is_super? && @user.date_off.present?
      flash[:warning] = "You can't edit deactivated client!"
      redirect_back fallback_location: current_user
    end
  end
end
