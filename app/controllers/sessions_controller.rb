class SessionsController < ApplicationController
  #Home page
  def new
    if logged_in?
      redirect_to current_user
    end
  end

  #Action for log in
  def create
    #Checking group of search
    if params[:session][:is_student] == '1'
      user = Student.find_by(code_name: params[:session][:codename])
    else
      user = Info.find_by(mail: params[:session][:codename])
    end
    #Checking log and pass
    if user && user.authenticate(params[:session][:password])
      #if Student was deactivated
      if params[:session][:is_student] == '1' && user.date_off != nil
        flash.now[:warning] = 'Your profile was deactivated!'
        render :new
        return
      end
      #Saving name
      if params[:session][:is_student] == '1'
        name_user = user.code_name
      else
        name_user = user.name
      end
      flash[:success] = "Welcome, #{name_user}"
      #Logging and redirecting
      redirect_to log_in user
    else
      flash.now[:danger] = 'Invalid email/codename or password combination'
      render :new
    end
  end

  #Action for log out
  def destroy
    log_out
    redirect_to root_url
  end
end
