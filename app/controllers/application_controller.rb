class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper

  #Callback for checking session
  def check_log_in
    unless logged_in?
      flash[:warning] = 'Only registered people can see this page.'
      #Redirecting to home page
      redirect_to :root
    end
  end

  #Callback for checking log out session
  def check_log_out
    if logged_in?
      flash[:warning] = 'This pages only for logged out users'
      #Redirecting to home page
      redirect_to :root
    end
  end

  #Callback for checking confirmation of mail
  def check_mail_confirmation
    user = current_user
    unless session[:user_type] != 'student' && user.info.is_mail_confirmed
      flash[:danger] = "You haven't confirmed your mail!\n Please, confirm your mail."
      redirect_to :root
    end
  end


  def check_exist(id, class_ref)
    if class_ref.exists?(id)
      true
    else
      flash[:danger] = 'User does not exist.'
      false
    end
  end
end
