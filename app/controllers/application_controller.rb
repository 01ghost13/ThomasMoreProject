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
end
