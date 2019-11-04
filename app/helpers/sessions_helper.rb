module SessionsHelper
  #Login user
  def log_in(user)
    #User's info id
    session[:user_id] = user.id
    #Is it client?
    if user.class.name == 'Client'
      #client
      session[:user_type] = 'client'
      session[:type_id] = user.id
      return user
    else
      #Mentor/Administrator
      adm = Administrator.find_by(info_id: session[:user_id])
      mentor = Mentor.find_by(info_id: session[:user_id])
      if adm
        session[:user_type] = 'administrator'
        session[:type_id] = adm.id
        return adm
      elsif mentor
        session[:user_type] = 'mentor'
        session[:type_id] = mentor.id
        return mentor
      else
        #Something get wrong
      end
    end
  end
  
  #Returns users_type obj
  def current_user
    if session[:user_type].nil?
      return nil
    end
    if session[:user_type] == 'client'
      @current_user ||= Client.find_by(id: session[:user_id])
    else
      @current_user = Administrator.find_by(info_id: session[:user_id]) || Mentor.find_by(info_id: session[:user_id])
    end
  end
  
  #Checks is user logged?
  def logged_in?
    !current_user.nil?
  end
  
  #Logs out the current user.
  def log_out
    session.delete(:user_id)
    session.delete(:type_id)
    session.delete(:user_type)
    @current_user = nil
  end
  
  #Checks is user - SA
  def is_super?
    if session[:user_type] == 'administrator'
      Administrator.find_by(id: session[:type_id]).is_super
    else
      false
    end
  end
end
