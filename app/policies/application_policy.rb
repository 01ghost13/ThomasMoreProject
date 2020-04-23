# Base class for application policies
class ApplicationPolicy < ActionPolicy::Base
  # Configure additional authorization contexts here
  # (`user` is added by default).
  #
  #   authorize :account, optional: true
  #
  # Read more about authoriztion context: https://actionpolicy.evilmartians.io/#/authorization_context

  private

    def exist?
      record.present?
      # if class_ref.exists?(id)
      #   true
      # else
      #   # https://actionpolicy.evilmartians.io/#/reasons?id=detailed-reasons
      #   # flash[:danger] = "This #{class_ref.to_s.downcase} does not exist."
      #   false
      # end
    end

    def mentor?
      user.mentor?
    end

    def local_admin?
      user.local_admin?
    end

    def super?
      user.super_admin?
    end

    #Callback for checking type of user
    def admin_group?
      # unless current_user.local_admin? || is_super?
      #   flash[:danger] = 'You have no access to this page!'
      #   redirect_to show_path_resolver(current_user)
      # end
      user.local_admin? || super?
    end

    def mail_confirmed?
      # return if current_user.client?
      #
      # unless current_user.confirmed?
      #   flash[:danger] = "You haven't confirmed your mail!\n Please, confirm your mail."
      #   redirect_to :root
      # end
      user.client? || user.confirmed?
    end

    def me?
      user.id == record.id
    end

    def my_mentor?
      user.employee.id == record.employee.try(:employee_id)
    end
end
