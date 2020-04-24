# basic controller for admin scope
class AdminController < ApplicationController
  before_action :authenticate_user!
  verify_authorized

  rescue_from ActionPolicy::Unauthorized do |ex|
    Rails.logger.error <<-TEXT
      User #{current_user.id}(#{current_user.role}) failed authorization.
      Stage: #{ex.result.reasons.details}
      Backtrace: #{ex.backtrace}
    TEXT

    flash[:danger] = ex.result.reasons.full_messages
    redirect_to show_path_resolver(current_user)
  end

  # Callback for checking confirmation of mail
  # @deprecated
  def check_mail_confirmation
    return if current_user.client?

    unless current_user.confirmed?
      flash[:danger] = "You haven't confirmed your mail!\n Please, confirm your mail."
      redirect_to :root
    end
  end

  # @deprecated
  def check_exist(id, class_ref)
    if class_ref.exists?(id)
      true
    else
      flash[:danger] = "This #{class_ref.to_s.downcase} does not exist."
      false
    end
  end

  # @deprecated
  def check_super_admin
    unless is_super?
      flash[:danger] = 'You have no access to this page!'
      redirect_to show_path_resolver(current_user)
    end
  end
end
