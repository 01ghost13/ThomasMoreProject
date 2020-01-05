class TestingManager
  attr_reader :result_of_test
  attr_reader :errors

  def initialize(result_of_test_id)
    @result_of_test = ResultOfTest
      .includes(:test, :client)
      .find_by(id: result_of_test_id)

    @client = @result_of_test.client
    @test = @result_of_test.test
    @errors = {}

    validate
  end

  def next(current_question, rewrite, start_time, answer, gaze_trace_attrs, emotion_state_attrs)
    if rewrite == 'true'
      #Updating cur question result
      q_to_upd = QuestionResult.find_by(
          result_of_test_id: @result_of_test.id,
          number: current_question
      )

      q_to_upd.update(
          start: start_time,
          end: DateTime.current,
          was_checked: answer,
          was_rewrited: true
      )
    else
      cur_q = Question.find_by(
          test_id: @result_of_test.test_id,
          number: current_question
      )
      question_result_params = {
          number: current_question,
          start: start_time,
          end: DateTime.current,
          was_checked: answer,
          question_id: cur_q.id
      }
      if @result_of_test.gaze_trace? && gaze_trace_attrs.present?
        question_result_params[:gaze_trace_result_attributes] =
            params.require(:gaze_trace_result_attributes)
                .permit(GazeTraceResult.attribute_names,
                        gaze_points: [:x, :y],
                        picture_bounds: [:x, :y])
      end
      if @result_of_test.emotion_recognition? && emotion_state_attrs.present?
        question_result_params[:emotion_state_result_attributes] =
            params.require(:emotion_state_result_attributes).permit!
      end

      @result_of_test.question_results << QuestionResult.new(question_result_params)
    end

    question = Question.find_by(test_id: @test.id, number: current_question + 1)

    if question.blank?
      finish
      nil
    else
      question
    end
  end

  def finish
    @result_of_test.update(is_ended: true)
    # { result_url: client_result_of_test_path(@client.id, @result_of_test.id) }
  end

  def validate
    if @test.questions.blank?
      errors[:test] = 'Test is empty'
    end

    if @result_of_test.is_ended?
      errors[:testing] = 'Testing is ended'
    end
  end

  def valid?
    errors.empty?
  end

  def current_question
    @result_of_test.last_question
  end
end
