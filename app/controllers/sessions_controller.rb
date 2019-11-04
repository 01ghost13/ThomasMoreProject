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
    user = Info.find_by(mail: params[:session][:codename])
    is_client = false

    if user.blank?
      is_client = true
      user = Client.find_by(code_name: params[:session][:codename])
    end

    #Checking log and pass
    if user && user.authenticate(params[:session][:password])
      #if Client was deactivated
      if is_client && user.date_off.present?
        flash.now[:warning] = 'Your profile was deactivated!'
        render :new
        return
      end
      #Saving name
      if is_client
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
