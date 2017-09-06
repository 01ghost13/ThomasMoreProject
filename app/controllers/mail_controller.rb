class MailController < ApplicationController
  before_action :check_log_in, only: [:send_confirmation_again]
  before_action :check_log_out, except: [:send_confirmation_again, :confirmation_email]

  #Action for confirmation email
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

  #Action for resending confirmation email
  def send_confirmation_again
    #If not student and sending for himself
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

  #Page for sending reset link
  def forgot_password
  end

  #Action for sending email with reset link
  def submit_forgot_password
    info = Info.find_by_mail(params[:mail])
    if info
      info.email_reset
      AitscoreMailer.reset_password(info).deliver
      flash[:success] = 'Email was sent.'
      redirect_to :root
    else
      flash[:danger] = "Sorry. User doesn't exist"
      render :forgot_password
    end
  end

  #Page for reset password
  def reset_password
    #Saving reset-token for hidden html field
    @token = params[:id]
  end

  #Action for reset password
  def submit_reset_password
    info = Info.find_by_reset_token(params[:reset_token])
    if info && !params[:reset_token].nil?
      if info.reset_password(params)
        flash[:success] = 'Your password was changed!'
        redirect_to :root
      else
        @token = params[:reset_token]
        @user = info
        render :reset_password
      end
    else
      flash[:danger] = "Sorry. User doesn't exist"
      redirect_to reset_password_url(id: params[:reset_token])
    end
  end
end
