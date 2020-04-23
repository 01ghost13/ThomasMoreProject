class MentorsController < AdminController
  before_action :check_exist_callback, only: [:edit, :update, :show, :delete, :delegate]
  # before_action :check_log_in, only: [:new,:create,:edit,:update,:show,:index,:delegate, :delete]
  before_action :check_type_rights, only: [:new,:create,:index,:delegate, :delete]
  before_action :check_rights, only: [:edit,:update,:show]
  before_action :check_mail_confirmation, except: [:show]
  before_action :info_for_forms, only: [:new, :create, :edit, :update]

  def new
    @user = User.new
    @user.build_employee
  end

  def create
    @user = User.new(mentor_params)
    @user.role = :mentor
    @user.userable = @user.build_employee(mentor_params[:employee_attributes])
    
    if @user.save
      flash[:success] = 'Account created! Confirmation of account was sent to email.'
      redirect_to mentor_path(@user)
    else
      render :new
    end
  end

  #Edit profile page
  def edit
    #Finding user
    @user = User.find(params[:id])
  end
  
  #Action for updating user
  def update
    #Finding mentor
    @user = User.find(params[:id])
    #If mentor exit and data - OK, changing
    if @user.update(mentor_params)
      flash[:success] = 'Update Complete'
      redirect_to mentor_path(@user)
    else
      render :edit
    end
    
  end

  def index
    unless current_user.local_admin? || current_user.super_admin?
      flash[:danger] = 'You have no access to this page!'
      redirect_to show_path_resolver(current_user)
      return
    end

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
    @user = User.find(params[:id])
    # TODO Make presenter
    @user_info = @user.show.to_a
  end

  def delegate
    @mentor = User.find(params[:id])

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
    @mentor = User.find(params[:id])
    employee = @mentor.employee

    if employee.clients.empty? || employee.update(delete_mentor_params)
      if @mentor.reload.destroy
        flash[:success] = 'Mentor was deleted!'
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
  #Rights checking
  def check_rights
    user = User.find(params[:id])
    # It is my page?
    is_i = (current_user.mentor? && current_user.id == params[:id].to_i)
    # It is my mentor?
    is_my_mentor = (current_user.local_admin? && user.employee.id == current_user.role_model.id)
    unless is_i || is_super? || is_my_mentor
      flash[:danger] = 'You have no access to this page.'
      redirect_to show_path_resolver(current_user)
    end
  end

  #Rights of viewing
  def check_type_rights
    return if is_super?

    is_my_adm = current_user.local_admin?
    #Checking creation or showing
    unless params[:id].nil?
      user = User.find(params[:id])
      is_my_adm = (!user.nil? && current_user.local_admin? && user.administrator_id == current_user.role_model.id)
    end

    #checking rights
    unless is_my_adm
      flash[:danger] = 'You have no access to this page.'
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
        employee_attributes: %i[id organisation phone organisation_address last_name name]
      )
      .tap do |p|
        p.delete(:password) if p[:password].blank?
        p.delete(:password_confirmation) if p[:password_confirmation].blank?

        if @is_super_admin
          p[:employee_attributes][:employee_id] = params.dig(:user, :employee_attributes, :employee_id)
        else
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
    @admins = User.admins_list if @is_super_admin
  end

  #Callback for checking existence of record
  def check_exist_callback
    unless check_exist(params[:id], User)
      redirect_to show_path_resolver(current_user)
    end
  end
end
