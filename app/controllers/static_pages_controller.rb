class StaticPagesController < ApplicationController
  def log_in

  end

  def about
    added = %w(
    All\ pictures\ should\ have\ text\ description
    Test\ should\ have\ progress\ bar
    Every\ step\ in\ the\ test\ should\ have\ 1\ picture\ instead\ of\ 3
    Test\ should\ have\ several\ navigation\ buttons:\ Exit,\ Step\ back,\ Like\ ,\ Don’t\ like
    Every\ picture\ must\ represent\ several\ fields\ of\ interests
    Administrator\ for\ managing\ users
    Profiles\ for\ students,\ teachers
    Saving\ and\ managing\ all\ results\ of\ tests
    Information\ which\ must\ be\ saved:\ date,\ time\ of\ test,\ time\ between\ answers,\ the\ fact\ of\ reanswering
    Table\ with\ results
    Switching\ off\ student\ accounts\ instead\ of\ deleting\ from\ DB
    Creation\ of\ tests,\ interests
    Protection\ from\ spam-bots
    Confirmation\ of\ registration\ via\ e-mail
    )
    will_be_added = %w(
    Graph\ with\ results
    Highlighting\ of\ buttons
    Recovering\ of\ account\ via\ e-mail
    Student\ and\ teacher\ search\ page
    Export\ to\ excel
    Sound\ description\ of\ images,\ for\ people\ with\ poor\ eyesight
    )
    @arr = {}
    added.each do |el|
      @arr[el] = true
    end
    will_be_added.each do |el|
      @arr[el] = false
    end
  end

  def contacts

  end

  def confirmation_email
    info = Info.find_by_confirm_token(params[:id])
    if info && !params[:id].nil?
      info.email_activate
      flash[:success] = 'Your email has been confirmed!'
    else
      flash[:danger] = "Sorry. User doesn't exist"
    end
    redirect_to :root
  end

  def send_confirmation_again
    if session[:user_type] != 'student' && params[:id].to_i == session[:user_id]
      user_info = Info.find(params[:id])
      if user_info.is_mail_confirmed?
        redirect_back fallback_location: :root
        return
      end
      AitscoreMailer.registration_confirmation(user_info).deliver
      flash[:success] = 'New email was sent!'
    else
      flash[:danger] = "Sorry. User doesn't exist"
    end
    redirect_back fallback_location: :root
  end

  def forgot_password
    #Page for submission
  end

  def reset_password

  end

  def submit_forgot_password

  end
end
