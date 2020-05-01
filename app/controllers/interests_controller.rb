class InterestsController < AdminController
  translations_for_preload %i[
    common.flash.interest_created
    common.flash.interest_deleted
    common.flash.interest_updated
    common.forms.add
    common.forms.delete
    common.forms.delete_confirm
    common.forms.edit
    common.forms.search
    common.kaminari.first
    common.kaminari.last
    common.kaminari.next
    common.kaminari.previous
    common.menu.all
    common.menu.create
    common.menu.log_out
    common.menu.my_profile
    common.menu.profile
    common.menu.settings
    entities.clients.create
    entities.clients.index
    entities.interests.all_interests
    entities.interests.create_interest
    entities.interests.fields.name
    entities.interests.index
    entities.interests.search_prompt
    entities.local_administrators.create
    entities.local_administrators.index
    entities.mentors.create
    entities.mentors.index
    entities.pictures.index
    entities.tests.index
  ]

  #Action for creation Interest
  def create
    authorize!
    @interest = Interest.new(interest_params)
    if @interest.save
      flash[:success] = tf('common.flash.interest_created')
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
      flash[:success] = tf('common.flash.interest_updated')
      redirect_to interests_path
    else
      load_info_for_page(interest, true)
    end
  end

  def destroy
    interest = Interest.find(params[:id])
    authorize!(interest)
    if interest.destroy
      flash[:success] = tf('common.flash.interest_deleted')
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
    interest_query = Interest.order(:created_at).reverse_order
    @q = interest_query.ransack(params[:q])
    @interests_list = params[:q] && params[:q][:s] ? @q.result.order(params[:q][:s]) : @q.result
    @interests_list = @interests_list.page(params[:page]).per(5)

    @interest = Interest.new if create_new
    @user = interest
    render :index
  end
end
