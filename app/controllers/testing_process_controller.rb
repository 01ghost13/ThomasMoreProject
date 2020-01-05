class TestingProcessController < ApplicationController
  before_action :check_log_in
  before_action :check_exist_callback, only: %i[begin]
  before_action :check_rights, only: %i[begin]

  #Updates picture in /testing process
  def answer
    manager = TestingManager.new(params[:result_of_test_id])

    unless manager.valid?
      flash[:danger] = manager.errors.values.last
      redirect_back fallback_location: current_user
      return
    end

    @question = manager.next(
      params[:question][:number].to_i,
      params[:rewrite],
      params[:start_time],
      params[:answer],
      params[:gaze_trace_result_attributes],
      params[:emotion_state_result_attributes]
    )

    if @question.blank?
      res = manager.result_of_test
      render json: {
        result_url: client_result_of_test_path(res.client_id, res.id)
      }
      return
    end

    @description = @question.attachment_description

    respond_to do |format|
      format.json do
        render 'update_picture.json.jbuilder'
      end
    end
  end

  def testing
    manager = TestingManager.new(params[:result_of_test_id])

    unless manager.valid?
      flash[:danger] = manager.errors.values.last
      redirect_back fallback_location: current_user
      return
    end

    @test = manager.result_of_test.test
    @client = manager.result_of_test.client
    @res = manager.result_of_test

    #Filling first question
    @question = @res.last_question
    @previous_question = @res.previous_question
    @description = @question.attachment_description
    @image = @question.picture&.middle_variant

    render layout: 'testing_layout'
  end

  def begin
    @client = Client.find_by(id: params[:id])

    @result_of_test = ResultOfTest.create(
        test_id: params[:test_id],
        was_in_school: @client.is_current_in_school,
        client_id: @client.id,
        gaze_trace: @client.gaze_trace,
        emotion_recognition: @client.emotion_recognition
    )

    redirect_to testing_path(@result_of_test.id)
  end

  private
    def check_rights
      user = Client.find(params[:id])
      is_super_adm = is_super?
      is_my_client = session[:user_type] == 'mentor' && user.mentor_id == session[:type_id]
      is_client_of_my_mentor = session[:user_type] == 'administrator' && user.mentor.administrator_id == session[:type_id]
      is_i = session[:user_type] == 'client' && params[:id].to_i == session[:type_id]
      unless is_super_adm || is_my_client || is_client_of_my_mentor || is_i
        flash[:warning] = 'You have no access to this page.'
        redirect_to current_user
      end
    end

    def check_exist_callback
      #edit - params[:id], other - params[:test_id]
      unless !params[:test_id].nil? && check_exist(params[:test_id], Test) ||
          params[:test_id].nil? && check_exist(params[:id], Test)
        redirect_to current_user
      end
    end
end
