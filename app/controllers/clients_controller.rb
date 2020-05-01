class ClientsController < AdminController
  translations_for_preload %i[
    common.flash.cant_hide_client
    common.flash.client_cant_be_deleted
    common.flash.client_created
    common.flash.client_deleted
    common.flash.client_hided_or_recovered
    common.flash.client_was_deactivated
    common.flash.update_complete
    common.flash.update_complete
    common.forms.confirm
    common.forms.delete
    common.forms.delete_confirm
    common.forms.edit
    common.forms.hide
    common.forms.search
    common.kaminari.last
    common.kaminari.next
    common.menu.all
    common.menu.create
    common.menu.edit_profile
    common.menu.log_out
    common.menu.my_profile
    common.menu.profile
    common.menu.settings
    entities.clients.all_clients
    entities.clients.choose_admin
    entities.clients.create
    entities.local_administrators.administrator
    entities.clients.fields.code_name
    entities.clients.fields.gender
    entities.clients.fields.is_current_in_school
    entities.mentors.mentor
    entities.clients.index
    entities.clients.search_prompt
    entities.employees.fields.organisation
    entities.interests.index
    entities.local_administrators.create
    entities.local_administrators.index
    entities.mentors.create
    entities.mentors.index
    entities.pictures.index
    entities.tests.index
    entities.users.fields.email
  ]

  before_action :preload_entity, only: %i[edit update destroy show mode_settings update_mode_settings]
  before_action :info_for_new_page, only: %i[create new]

  def new
    authorize!
    @user = User.new
    @user.build_client
  end
  
  def create
    authorize!
    @user = User.new(client_params)
    @user.role = :client
    @user.userable = @user.build_client(client_params[:client_attributes])

    if @user.save
      flash[:success] = tf('common.flash.client_created')
      redirect_to client_path(@user)
    else
      render :new
    end
  end

  def destroy
    authorize!(@user)
    client = @user

    if params[:paranoic] == 'true' || params[:paranoic] == nil
      if client.hide
        flash[:success] = tf('common.flash.client_hided_or_recovered')
      else
        flash[:warning] = tf('common.flash.cant_hide_client')
      end
    elsif params[:paranoic] == 'false' && is_super?
      # True deleting
      if client.destroy
        flash[:success] = tf('common.flash.client_deleted')
      else
        flash[:danger] = tf('common.flash.client_cant_be_deleted')
      end
    end

    redirect_back fallback_location: show_path_resolver(current_user)
  end
  
  def edit
    authorize!(@user)
    info_for_edit_page
  end
  
  def update
    authorize!(@user)
    if @user.update(client_params)
      flash[:success] = tf('common.flash.update_complete')
      redirect_to client_path(@user)
    else
      info_for_edit_page
      render :edit
    end
  end
  
  def show
    authorize!(@user)
    client = @user.role_model

    @is_super_adm = is_super?
    @is_my_client = current_user.mentor? && client.employee_id == current_user.role_model.id
    @is_client_of_my_mentor = current_user.local_admin? && client.employee.employee_id == current_user.role_model.id

    unless @user.is_active
      # Client is inactive
      flash[:warning] = tf('common.flash.client_was_deactivated', options: { time: @user.date_off.to_s })
      unless is_super?
        redirect_to clients_path
        return
      end
    end

    @user_info = translate_hash(@user.show_nested)
    # Loading all test results
    @test_results = []
    ResultOfTest.order(:created_at).reverse_order.where(client_id: client.id).limit(5).each do |res|
      @test_results << res.show_short
    end
  end
  
  # Function for ajax updating
  # TODO TEST IF DEPRECATED
  def update_mentors
    authorize!
    @mentors = User.mentors_list(params[:administrator_id])
    respond_to do |format|
       format.js {}
    end
  end

  def index
    authorize!

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
  end

  # Page for editing modes
  def mode_settings
    authorize!(@user)
  end

  # Update edited modes
  def update_mode_settings
    authorize!(@user)
    if @user.update(mode_params)
      flash[:success] = tf('common.flash.update_complete')
      redirect_to tests_client_path(params[:id])
    else
      render :mode_settings
    end
  end

  private

    def preload_entity
      @user = User.find_by(id: params[:id])
    end

  def client_params
    params
      .require(:user)
      .permit(
        :password,
        :password_confirmation,
        client_attributes: %i[id code_name employee_id gender is_current_in_school],
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

  # Loads info for 'new' page
  def info_for_new_page
    # TODO FIX BUG WHEN SAVING FAILS LINKED MENTOR IS UNSET
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
        employee = @user.client.employee
        if employee.present?
          @admins_cur = employee.employee_id
          @mentors_cur = @user.client.employee_id
        else
          @admins_cur = params[:administrator_id]
          @mentors_cur = 0
        end
        @mentors = User.mentors_list(@admins_cur)
      end
    elsif current_user.local_admin?
      @mentors = User.mentors_list(current_user.role_model.id)
      @mentors_cur = @user.client.employee_id
    end
  end
end
