class AdministratorsController < AdminController
  translations_for_preload %i[
    common.flash.account_created
    common.flash.update_complete
    common.flash.administrator_deleted
    common.flash.administrator_cant_be_deleted
    common.flash.no_access
  ]

  before_action :preload_entity, only: %i[edit update show delete delegate]

  def new
    authorize!
    @user = User.new
    @user.build_employee
  end

  def create
    authorize!
    @user = User.new(administrator_params)
    @user.role = :local_admin
    @user.userable = @user.build_employee(administrator_params[:employee_attributes])

    if @user.save
      flash[:success] = tf('common.flash.account_created')

      redirect_to administrator_path(@user)
    else
      render :new
    end
  end

  def index
    authorize!
    @q = User.all_local_admins.joins(:employee).ransack(params[:q])
    @admins = params[:q] && params[:q][:s] ? @q.result.order(params[:q][:s]) : @q.result
    @admins = @admins.page(params[:page]).per(5)
  end

  def edit
    authorize!(@user)
  end
  
  def update
    authorize!(@user)

    if @user.update(administrator_params)
      flash[:success] = tf('common.flash.update_complete')
      redirect_to administrator_path(@user)
    else
      render :edit
    end
  end

  def show
    authorize!(@user)
    # TODO Make presenter
    @user_info = @user.show.to_a
  end

  def delegate
    authorize!(@user)
    @administrator = @user

    # TODO FIX BUG scope returns ALL other entities, but not related to old one
    # Loading information about mentors and admins for page
    @admins = User
      .includes(:employee)
      .other_local_admins(@administrator.id)
      .map(&:employee)
      .map do |t|
        ['%{org}: %{lname} %{name}' % { org: t.organisation, lname: t.last_name, name: t.name }, t.id]
      end
  end

  def delete
    authorize!(@user)
    @administrator = @user

    employee = @administrator.employee
    # Admin can be deleted only if hasn't mentors
    if employee.employees.empty? || employee.update(delete_administrator_params)
      if @administrator.reload.destroy
        flash[:success] = tf('common.flash.administrator_deleted')
        redirect_to administrators_path and return
      end
    end

    @admins = User
      .includes(:employee)
      .other_local_admins(@administrator.id)
      .map(&:employee)
      .map do |t|
        ['%{org}: %{lname} %{name}' % { org: t.organisation, lname: t.last_name, name: t.name }, t.id]
      end
    render :delegate
  end

  private

    def preload_entity
      @user = User.find_by(id: params[:id])
    end

    # @deprecated
    def load_admin_for_deletion
      administrator = User.find(params[:id])
      #Blocking a deletion of super administrator
      if administrator.super_admin?
        flash[:danger] = tf('common.flash.administrator_cant_be_deleted')
        redirect_to show_path_resolver(current_user)
      end
      administrator
    end

    def administrator_params
      params
        .require(:user)
        .permit(
          :email,
          :password,
          :password_confirmation,
          employee_attributes: %i[id organisation phone organisation_address last_name name]
        )
        .tap do |p|
          p.delete(:password) if p[:password].blank?
          p.delete(:password_confirmation) if p[:password_confirmation].blank?
        end
    end

    #Attributes for delete forms
    def delete_administrator_params
      params.require(:employee).permit(employees_attributes: %i[employee_id id])
    end

    #Callback for checking rights
    # @deprecated
    def check_rights
      #Only SA or user can edit/delete their accounts
      unless is_super? || current_user.local_admin? && current_user.id == params[:id].to_i
        flash[:danger] = tf('common.flash.no_access')
        #Redirect
        redirect_to show_path_resolver(current_user)
      end
    end

    #Callback for checking type of user
    # @deprecated
    def check_type_rights
      unless current_user.local_admin? || is_super?
        flash[:danger] = tf('common.flash.no_access')
        redirect_to show_path_resolver(current_user)
      end
    end

    #Callback for checking existence of record
    # @deprecated
    def check_exist_callback
      unless check_exist(params[:id], User)
        redirect_to show_path_resolver(current_user)
      end
    end
end
