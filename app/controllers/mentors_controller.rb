class MentorsController < AdminController
  translations_for_preload %i[
    common.flash.account_created
    common.flash.update_complete
    common.flash.mentor_deleted
    common.flash.no_access
  ]

  before_action :preload_entity, only: %i[edit update show delete delegate]
  before_action :info_for_forms, only: %i[new create edit update]

  def new
    authorize!
    @user = User.new
    @user.build_employee
  end

  def create
    authorize!
    @user = User.new(mentor_params)
    @user.role = :mentor
    @user.userable = @user.build_employee(mentor_params[:employee_attributes])
    @user.skip_confirmation! # FIXME: Mocked because email service is not working
    
    if @user.save
      flash[:success] = tf('common.flash.account_created')
      redirect_to mentor_path(@user)
    else
      render :new
    end
  end

  def edit
    authorize!(@user)
  end
  
  def update
    authorize!(@user)
    #If mentor exit and data - OK, changing
    if @user.update(mentor_params)
      flash[:success] = tf('common.flash.update_complete')
      redirect_to mentor_path(@user)
    else
      render :edit
    end
    
  end

  def index
    authorize!

    @is_super_adm = is_super?

    # Loading all mentors if super admin
    @q = User.all_mentors.joins(:employee)
    @q = if @is_super_adm
           @q
         else
           @q.mentors_of_administrator(current_user.role_model.id)
         end
    @q = @q.ransack(params[:q])

    @mentors = params[:q] && params[:q][:s] ? @q.result.order(params[:q][:s]) : @q.result
    @mentors = @mentors.page(params[:page]).per(5)
  end

  def show
    authorize!(@user)
    # TODO Make presenter
    @user_info = translate_hash(@user.show_nested)
  end

  def delegate
    authorize!(@user)
    @mentor = @user

    # TODO FIX BUG scope returns ALL other entities, but not related to old one
    @mentors = User
      .includes(:employee)
      .other_mentors(@mentor.id)
      .map do |t|
        employee = t.employee
        ['%{email}: %{lname} %{name}' % { email: t.email, lname: employee.last_name, name: employee.name }, employee.id]
      end
  end

  def delete
    authorize!(@user)
    @mentor = @user
    employee = @mentor.employee

    if employee.clients.empty? || employee.update(delete_mentor_params)
      if @mentor.reload.destroy
        flash[:success] = tf('common.flash.mentor_deleted')
        redirect_to mentors_path and return
      end
    end

    @mentors = User
      .includes(:employee)
      .other_mentors(@mentor.id)
      .map do |t|
        employee = t.employee
        ['%{email}: %{lname} %{name}' % { email: t.email, lname: employee.last_name, name: employee.name }, employee.id]
      end
    @user = @mentor
    render :delegate
  end
  ##########################################################
  #Private methods
  private

    def preload_entity
      @user = User.find_by(id: params[:id])
    end

  #Rights checking
  # @deprecated
  def check_rights
    user = User.find(params[:id])
    # It is my page?
    is_i = (current_user.mentor? && current_user.id == params[:id].to_i)
    # It is my mentor?
    is_my_mentor = (current_user.local_admin? && user.employee.employee_id == current_user.role_model.id)
    unless is_i || is_super? || is_my_mentor
      flash[:danger] = tf('common.flash.no_access')
      redirect_to show_path_resolver(current_user)
    end
  end

  #Rights of viewing
  # @deprecated
  def check_type_rights
    return if is_super?

    is_my_adm = current_user.local_admin?
    #Checking creation or showing
    unless params[:id].nil?
      user = User.find(params[:id])
      is_my_adm = (!user.nil? && current_user.local_admin? && user.employee.id == current_user.role_model.id)
    end

    #checking rights
    unless is_my_adm
      flash[:danger] = tf('common.flash.no_access')
      redirect_to show_path_resolver(current_user)
    end
  end

  #Attributes for forms
  def mentor_params
    params
      .require(:user)
      .permit(
        :email,
        :password,
        :password_confirmation,
        :language_id,
        employee_attributes: %i[id organisation phone organisation_address last_name name]
      )
      .tap do |p|
        p.delete(:password) if p[:password].blank?
        p.delete(:password_confirmation) if p[:password_confirmation].blank?

        if @is_super_admin
          p[:employee_attributes][:employee_id] = params.dig(:user, :employee_attributes, :employee_id)
        elsif current_user.local_admin?
          p[:employee_attributes][:employee_id] = current_user.employee.id
        end
      end
  end

  #Attributes for delete forms
  def delete_mentor_params
    params.require(:employee).permit(clients_attributes: %i[employee_id id])
  end

  #Loads info for creation/new pages
  def info_for_forms
    #Info for page
    #Saving info if we are SA
    @is_super_admin = is_super?
    #Array of admins for SA
    @admins = User.admins_list(with_mentors: false) if @is_super_admin
  end

  #Callback for checking existence of record
  # @deprecated
  def check_exist_callback
    unless check_exist(params[:id], User)
      redirect_to show_path_resolver(current_user)
    end
  end
end
