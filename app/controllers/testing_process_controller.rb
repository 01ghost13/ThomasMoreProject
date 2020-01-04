class TestingProcessController < ApplicationController
  before_action :check_log_in
  before_action :check_exist_callback, only: [:testing]
  before_action :check_rights, only: [:testing]

  #Updates picture in /testing process
  def update_picture
    #Finding our result of test
    res = ResultOfTest.where(client_id: params[:client_id], test_id: params[:test_id], is_ended: false).first
    cur_question = params[:question][:number].to_i

    #Loading next question and writing to db current
    #Writing result
    ##Checking - is it rewriting?
    if params[:rewrite] == 'true'
      #Updating cur question result
      q_to_upd = QuestionResult.where(result_of_test_id: res.id, number: cur_question).first
      q_to_upd.update(
          start: params[:start_time],
          end: DateTime.current,
          was_checked: params[:answer],
          was_rewrited: true
      )
    else
      cur_q = Question.where(test_id: res.test_id, number: cur_question).first
      question_result_params = {
          number: cur_question,
          start: params[:start_time],
          end: DateTime.current,
          was_checked: params[:answer],
          question_id: cur_q.id
      }
      if res.gaze_trace? && params[:gaze_trace_result_attributes].present?
        question_result_params[:gaze_trace_result_attributes] =
            params.require(:gaze_trace_result_attributes)
                .permit(GazeTraceResult.attribute_names,
                        gaze_points: [:x, :y],
                        picture_bounds: [:x, :y])
      end
      if res.emotion_recognition? && params[:emotion_state_result_attributes].present?
        question_result_params[:emotion_state_result_attributes] =
            params.require(:emotion_state_result_attributes).permit!
      end

      res.question_results << QuestionResult.new(question_result_params)
    end
    #Changing variables
    ##Finding next pic name
    @question = Question.where(test_id: params[:test_id], number: cur_question + 1).first
    ##if was last pic saving and redirecting to result
    if @question.nil?
      #current q was the last, saving and redirecting to result
      res.update(is_ended: true)
      render json: { result_url: client_result_of_test_path(params[:client_id], res.id) } and return
    end

    @description = @question.attachment_description

    respond_to do |format|
      format.json do
        render 'update_picture.json.jbuilder'
      end
    end
  end

  def testing
    #Loading test
    @test = Test.where(id: params[:test_id]).first

    #Loading client
    @client = Client.where(id: params[:id]).first

    if @test.blank? || @client.blank?
      #Cant find test or client
      flash[:danger] = "Can't find client" if @client.blank?
      flash[:danger] = "Can't find test" if @test.blank?
      redirect_back fallback_location: current_user and return
    end

    #Checking questions in test
    if @test.questions.blank?
      flash[:danger] = 'Test is empty and probably not ready for testing! Please, contact administrator.'
      redirect_back fallback_location: current_user and return
    end

    #Checking continue or creating new result
    res = ResultOfTest.where(client_id: params[:id], test_id: params[:test_id], is_ended: false).first
    if res.blank?
      #All tests were ended
      #Creating new result
      res = ResultOfTest.create(
          test_id: params[:test_id],
          was_in_school: @client.is_current_in_school,
          client_id: params[:id],
          gaze_trace: @client.gaze_trace,
          emotion_recognition: @client.emotion_recognition
      )
    end
    #Filling first question
    @question = res.last_question
    @previous_question = res.previous_question
    @description = @question.attachment_description
    @image = @question.picture&.middle_variant
    @res = res
    render layout: 'testing_layout'
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
        redirect_to current_user
      end
    end
end
