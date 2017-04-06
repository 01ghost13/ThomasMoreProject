class InterestsController < ApplicationController
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
end
