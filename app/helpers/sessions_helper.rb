module SessionsHelper
  #Login user
  def log_in(user)
    #User's info id
    session[:user_id] = user.id
    #Is it student?
    if user.name.nil?
      #Student
      session[:user_type] = 'student'
      session[:type_id] = user.id
      return user
    else
      #Tutor/Administrator
      adm = Administrator.find_by(info_id: session[:user_id])
      tutor = Tutor.find_by(info_id: session[:user_id])
      if adm
        session[:user_type] = 'administrator'
        session[:type_id] = adm.id
        return adm
      elsif tutor
        session[:user_type] = 'tutor'
        session[:type_id] = tutor.id
        return tutor
      else
        #Something get wrong
      end
    end
  end
  
  #Returns users_type obj
  def current_user
    if session[:user_type] == 'student'
      @current_user ||= Student.find_by(id: session[:user_id])
    else
      @current_user = Administrator.find_by(info_id: session[:user_id]) || Tutor.find_by(info_id: session[:user_id])
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
      return Administrator.find_by(id: session[:type_id]).is_super
    else
      return false
    end
  end
end
