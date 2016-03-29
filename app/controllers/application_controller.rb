class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper
  
  def find_info(user)
    unless user.nil?
      info = Info.find(user.info_id)
      @user_info = [['Name: ', info.name],['Last name: ', info.last_name],['Phone: ', info.phone],['Mail: ', info.mail]]
      @confirmed_mail = info.is_mail_confirmed || true
      @is_super_adm = is_super?
      return @user_info
    else
       #Throw error of 404
    end
  end
end
