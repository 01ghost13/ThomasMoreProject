class QuestionResultPresenter
  attr_reader :start,
              :finish,
              :answer,
              :type,
              :interests,
              :number,
              :corrupted

  class << self
    def wrap(question_results, language_id)
      question_results.map do |qr|
        new(qr, language_id)
      end
    end
  end

  def initialize(question_result, language_id)
    @start = question_result.start
    @finish = question_result.end
    @answer = question_result.was_checked
    @number = question_result.number
    @corrupted = question_result.question_id.blank?

    if @corrupted
      @type = nil
      @interests = []
    else
      @type = check_type(question_result)

      @interests = load_interests(question_result, language_id)
    end
  end

  def answer_time
    @finish - @start
  end

  def counted?
    answer == 3
  end

  private

    def check_type(question_result)
      question = question_result.question
      if question.attachment.is_a?(Picture)
        :picture
      else
        :youtube_link
      end
    end

    def load_interests(question_result, language_id)
      question = question_result.question
      attachment = question.attachment

      attachment.picture_interests.map do |picture_interest|
        weight = picture_interest.earned_points

        OpenStruct.new interest: wrap_language(picture_interest.interest, language_id),
                       weight: weight,
                       counted: counted?,
                       answer_time: answer_time
      end
    end

    def wrap_language(array, language_id)
      Translatable.wrap_language(array, language_id)
    end
end
