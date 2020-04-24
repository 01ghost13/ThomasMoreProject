class InterestsController < AdminController

  #Action for creation Interest
  def create
    authorize!
    @interest = Interest.new(interest_params)
    if @interest.save
      flash[:success] = 'Interest added!'
      redirect_to interests_path
    else
      load_info_for_page(@interest, false)
    end
  end

  #Action for updating interest
  def update
    interest = Interest.find(params[:interest][:id])
    authorize!(interest)
    if interest.update(interest_params)
      flash[:success] = 'Interest updated!'
      redirect_to interests_path
    else
      load_info_for_page(interest, true)
    end
  end

  def destroy
    interest = Interest.find(params[:id])
    authorize!(interest)
    if interest.destroy
      flash[:success] = 'Interest deleted!'
      redirect_to interests_path
    else
      load_info_for_page(interest, true)
    end
  end

  def index
    authorize!
    interest_query = Interest.order(:created_at).reverse_order
    @q = interest_query.ransack(params[:q])
    @interests_list = params[:q] && params[:q][:s] ? @q.result.order(params[:q][:s]) : @q.result

    @interests_list = @interests_list.page(params[:page]).per(5)
    @interest = Interest.new
  end
  ##########################################################
  #Private methods
  private
  #Attributes for forms
  def interest_params
    params.require(:interest).permit(:name, :id)
  end

  #Loads interest to page. if create_new true - creates new interest for form
  def load_info_for_page(interest, create_new)
    @interests_list = Interest.order(:created_at).reverse_order.page(params[:page]).per(5)
    @interest = Interest.new if create_new
    @user = interest
    render :index
  end
end
