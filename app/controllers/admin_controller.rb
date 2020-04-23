class AdminController < ApplicationController
  before_action :authenticate_user!
  verify_authorized

  #Callback for checking session
  # @deprecated
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
      redirect_to show_path_resolver(current_user)
    end
  end
end
