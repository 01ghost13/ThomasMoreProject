class ApplicationController < ActionController::Base
  include SessionsHelper
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  #Callback for checking session
  def check_log_in
    unless logged_in?
      flash[:warning] = 'Only registered people can see this page.'
      #Redirecting to home page
      redirect_to :root
    end
  end

  #Callback for checking log out session
  # @deprecated
  def check_log_out
    if logged_in?
      flash[:warning] = 'This pages only for logged out users'
      #Redirecting to home page
      redirect_to :root
    end
  end

  #Callback for checking confirmation of mail
  def check_mail_confirmation
    return if current_user.client?

    unless current_user.confirmed?
      flash[:danger] = "You haven't confirmed your mail!\n Please, confirm your mail."
      redirect_to :root
    end
  end

  def check_exist(id, class_ref)
    if class_ref.exists?(id)
      true
    else
      flash[:danger] = "This #{class_ref.to_s.downcase} does not exist."
      false
    end
  end

  def check_super_admin
    unless is_super?
      flash[:danger] = 'You have no access to this page!'
      redirect_to current_user.role_model
    end
  end

  # Checks is user logged?
  def logged_in?
    user_signed_in?
  end

  # Checks is user - SA
  def is_super?
    current_user.super_admin?
  end
end
