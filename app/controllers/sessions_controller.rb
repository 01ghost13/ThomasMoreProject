class SessionsController < ApplicationController
  def new
    if logged_in?
      redirect_to current_user
    end
  end
  def create
    #Checking group of search
    if params[:session][:is_student] == '1'
      user = Student.find_by(code_name: params[:session][:codename])
    else
      user = Info.find_by(mail: params[:session][:codename])
    end
    #Checking log and pass
    if user && user.authenticate(params[:session][:password])
      if user.is_mail_confirmed == false
        flash.now[:warning] = "Your mail hasnt confirmed yet."
        render :root
        return
      end
      name_user = ''
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
  
  def destroy
    log_out
    redirect_to root_url
  end
end
