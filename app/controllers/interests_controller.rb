class InterestsController < ApplicationController
  before_action :check_log_in
  before_action :check_rights

  def create
    @interest = Interest.new(interest_params)
    if @interest.save
      flash[:success] = 'Interest added!'
      redirect_to interests_path
    else
      @interests_list = Interest.order(:created_at).reverse_order.page(params[:page]).per(5)
      @user = @interest
      render :index
    end
  end

  def update
    interest = Interest.find(params[:interest][:id])
    if interest.update(interest_params)
      flash[:success] = 'Interest updated!'
      redirect_to interests_path
    else
      @interests_list = Interest.order(:created_at).reverse_order.page(params[:page]).per(5)
      @interest = Interest.new
      @user = interest
      render :index
    end
  end

  def destroy
    interest = Interest.find(params[:id])
    if interest.destroy
      flash[:success] = 'Interest deleted!'
      redirect_to interests_path
    else
      @interests_list = Interest.order(:created_at).reverse_order.page(params[:page]).per(5)
      @interest = Interest.new
      @user = interest
      render :index
    end
  end

  def index
    @interests_list = Interest.order(:created_at).reverse_order.page(params[:page]).per(5)
    @interest = Interest.new
    @user = @interest
  end

  private
    def interest_params
      params.require(:interest).permit(:name, :id)
    end

  #Callback for checking session
  def check_log_in
    unless logged_in?
      flash[:warning] = 'Only registrated people can see this page.'
      #Redirecting to home page
      redirect_to :root
    end
  end

  #Callback for checking rights
  def check_rights
    #Only SA
    unless is_super?
      flash[:warning] = 'You have no access to this page.'
      #Redirect
      redirect_to current_user
    end
  end
end
