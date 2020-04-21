class AdministratorsController < ApplicationController
  # include Recaptcha::ClientHelper
  # include Recaptcha::Verify

  before_action :check_exist_callback, only: [:edit, :update, :show, :delete, :delegate]
  before_action :check_log_in, only: [:new, :create, :index, :edit, :update, :show, :delegate]
  before_action :check_rights, only: [:edit, :update, :show]
  before_action :check_type_rights, only: [:edit, :update, :show]
  before_action :check_mail_confirmation, except: [:new, :show, :create]
  before_action :check_super_admin, only: [:new, :create, :index, :delegate, :delete]

  def new
    @user = User.new
    @user.build_employee
  end

  def create
    @user = User.new(administrator_params)
    @user.role = :local_admin
    @user.userable = @user.build_employee(administrator_params[:employee_attributes])

    if @user.save
      flash[:success] = 'Account created! Confirmation of account was sent to email.'

      redirect_to administrator_path(@user)
    else
      render :new
    end
  end

  def index
    @q = User.all_local_admins.joins(:employee).ransack(params[:q])
    @admins = params[:q] && params[:q][:s] ? @q.result.order(params[:q][:s]) : @q.result
    @admins = @admins.page(params[:page]).per(5)
  end

  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])

    if @user.update(administrator_params)
      flash[:success] = 'Update Complete'
      redirect_to administrator_path(@user)
    else
      render :edit
    end
  end

  def show
    @user = User.find(params[:id])
    # TODO Make presenter
    @user_info = @user.show.to_a
  end

  def delegate
    @administrator = load_admin_for_deletion

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
    @administrator = load_admin_for_deletion

    employee = @administrator.employee
    # Admin can be deleted only if hasn't mentors
    if employee.employees.empty? || employee.update(delete_administrator_params)
      if @administrator.reload.destroy
        flash[:success] = 'Administrator was deleted!'
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
    @user = @administrator
    render :delegate
  end

  private

    def load_admin_for_deletion
      administrator = User.find(params[:id])
      #Blocking a deletion of super administrator
      if administrator.super_admin?
        flash[:danger] = "You can't delete this administrator!"
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
    def check_rights
      #Only SA or user can edit/delete their accounts
      unless is_super? || current_user.local_admin? && current_user.id == params[:id].to_i
        flash[:danger] = 'You have no access to this page.'
        #Redirect
        redirect_to show_path_resolver(current_user)
      end
    end

    #Callback for checking type of user
    def check_type_rights
      unless current_user.local_admin? || is_super?
        flash[:danger] = 'You have no access to this page!'
        redirect_to show_path_resolver(current_user)
      end
    end

    #Callback for checking existence of record
    def check_exist_callback
      unless check_exist(params[:id], User)
        redirect_to show_path_resolver(current_user)
      end
    end
end
