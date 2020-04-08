class TestsController < ApplicationController
  before_action :check_log_in
  before_action :check_exist_callback, only: [:testing, :edit, :update, :destroy]
  before_action :check_rights, only: [:testing]
  before_action :check_super_admin, only: [:new, :create, :edit, :update, :destroy]

  #Page of creation of Tests
  def new
    @test = Test.new
    @pictures = Picture.pictures_list
  end

  #Action for ajax
  def update_image
    @id = params[:event_id]
    @picture = Picture.find(params[:picture_id])
  end

  #Action for creation of test
  def create
    @test = Test.new(test_params)
    @picture = []
    #Numering questions
    @test.questions.each_with_index do |q, i|
      q.number = i + 1
      next if q.picture_id.blank?
      @picture << Picture.find(q.picture_id)
    end
    unless params[:test][:questions_attributes]
      @test.errors.add(:questions, :invalid, message: "Test can't be empty")
    end
    if params[:test][:questions_attributes] && @test.save
      flash[:success] = 'Test created!'
      render json: {}, status: :created
    else
      @user = @test
      @pictures = Picture.pictures_list
      @dummy = Picture.find(@pictures.first[1])
      @picture = [@dummy] if @picture.empty?
      render json: {
          response: {
              type: :error,
              fields: @test.errors.messages,
              full_messages: @test.errors.full_messages
          }
      }, status: :unprocessable_entity
    end
  end

  #Page of editing tests
  def edit
    @test = Test.find(params[:id])
    @picture = []
    @pictures = Picture.pictures_list
    @test.questions.each do |q|
      next if q.picture_id.blank?
      @picture << Picture.find(q.picture_id)
    end
    @dummy = Picture.find(@pictures.first[1])
    @picture = [@dummy] if @picture.empty?
  end

  def all_questions_destroy?(questions)
    questions.each_key do |key|
      if questions[key]['_destroy'] != 'true'
        return false
      end
    end
    true
  end

  #Action of editing tests
  def update
    @test = Test.find(params[:id])
    empty_list = all_questions_destroy?(test_params[:questions_attributes].to_hash)
    if !params[:test].nil? && !empty_list && @test.update(test_params)
      flash[:success] = 'Test updated!'
      render json: {}, status: :ok
    else
      if params[:test].nil? || empty_list
        @test.errors.add(:questions, :invalid, message: "Test can't be empty")
      end
      @picture = []
      #Loading questions
      @test.questions.each do |q|
        next if q.picture_id.blank?
        @picture << Picture.find(q.picture_id)
      end
      @user = @test
      @pictures = Picture.pictures_list
      @dummy = Picture.find(@pictures.first[1])
      @picture = [@dummy] if @picture.empty?
      render json: {
          response: {
              type: :error,
              fields: @test.errors.messages,
              full_messages: @test.errors.full_messages
          }
      }, status: :unprocessable_entity
    end
  end

  #Action for deleting tests
  def destroy
    test = Test.find(params[:id])
    if test.destroy
      flash[:success] = 'Test deleted!'
    else
      flash[:danger] = 'This test has associated results, please, delete them first.'
    end
    redirect_to tests_path
  end

  #Page of list of tests
  def index
    #Only super admin has access to aitscore\tests
    if params[:id].nil? && !is_super?
      flash[:warning] = 'You have no access to this page.'
      redirect_to current_user.role_model
      return
    end
    tests = Test.all
    @tests = []
    tests.each do |test|
      @tests << test.show_short
    end
    @tests = Kaminari.paginate_array(@tests).page(params[:page]).per(10)

    if params[:id].present?
      @not_finished_tests = ResultOfTest.where(client_id: params[:id], is_ended: false).order(created_at: :desc)
    end
  end

  #Private methods
  private
    def check_rights
      user = Client.find(params[:id])
      is_super_adm = is_super?
      is_my_client = current_user.mentor? && user.mentor_id == current_user.role_model.id
      is_client_of_my_mentor = current_user.local_admin? && user.mentor.administrator_id == current_user.role_model.id
      is_i = current_user.client? && params[:id].to_i == current_user.role_model.id
      unless is_super_adm || is_my_client || is_client_of_my_mentor || is_i
        flash[:warning] = 'You have no access to this page.'
        redirect_to current_user.role_model
      end
    end

    def test_params
      i = 1
      if params[:test][:questions_attributes].present?
        params[:test][:questions_attributes].each_pair do |key, _|
          params[:test][:questions_attributes][key][:number] = i
          i += 1
        end
      end
      params.require(:test).permit(
          :description,
          :name,
          :version,
          questions_attributes: [
            :picture_id,
            :_destroy,
            :id,
            :number,
            youtube_link_attributes: [
              :link
            ]
          ]
      )
    end

    def check_exist_callback
      #edit - params[:id], other - params[:test_id]
      unless !params[:test_id].nil? && check_exist(params[:test_id], Test) ||
              params[:test_id].nil? && check_exist(params[:id], Test)
        redirect_to current_user.role_model
      end
    end
end
