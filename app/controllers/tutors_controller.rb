class TutorsController < ApplicationController
  def new
    unless logged_in? && session[:user_type] == 'administrator'
      #Try another type of checking
      flash[:warning] = "Only registrated people can see this page"
      redirect_to :root
    end
    @is_super_admin = is_super?
    @user = Tutor.new
    @user_info = Info.new
    @user.info = @user_info
    @admins = []
    admins_hash = Administrator.all.where(is_super: false)
    #debugger
    admins_hash.each do |admin|
      @admins << ["#{admin.organisation}:#{admin.info.last_name} #{admin.info.name}",admin.id]
    end
  end

  def edit
  end

  def index
  end

  def show
  end
end
