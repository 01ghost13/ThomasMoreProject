# basic controller for admin scope
class AdminController < ApplicationController
  before_action :authenticate_user!
  verify_authorized

  rescue_from ActionPolicy::Unauthorized do |ex|
    Rails.logger.warn <<-TEXT
      User #{current_user.id}(#{current_user.role}) failed authorization.
      Stage: #{ex.result.reasons.details}
      Backtrace: #{ex.backtrace}
    TEXT

    flash[:danger] = tf('common.flash.no_access')
    redirect_to show_path_resolver(current_user)
  end

  # Callback for checking confirmation of mail
  # @deprecated
  def check_mail_confirmation
    return if current_user.client?

    unless current_user.confirmed?
      flash[:danger] = tf('common.flash.unconfirmed_mail')
      redirect_to :root
    end
  end

  # @deprecated
  def check_exist(id, class_ref)
    if class_ref.exists?(id)
      true
    else
      flash[:danger] = tf('common.flash.does_not_exist', options: { class_name: class_ref.to_s.downcase })
      false
    end
  end

  # @deprecated
  def check_super_admin
    unless is_super?
      flash[:danger] = tf('common.flash.no_access')
      redirect_to show_path_resolver(current_user)
    end
  end
end
