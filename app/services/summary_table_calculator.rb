class SummaryTableCalculator
  attr_reader :max_questions

  def initialize(results, language_id)
    ids = results.map(&:id)

    results = ResultOfTest
      .where(id: ids)
      .includes(
        :test,
        client: {
          user: {},
          employee: { user: {}, employee: :user }
        },
        question_results: {
          question: {
            picture: { picture_interests: :interest },
            youtube_link: { picture_interests: :interest },
          }
        }
      )

    @max_questions = 0

    @wrapped = results.map do |result|
      questions_count = result.question_results.size

      if questions_count > @max_questions
        @max_questions = questions_count
      end

      OpenStruct.new this: result,
                     question_results: QuestionResultPresenter.wrap(result.question_results, language_id).sort_by(&:number)
    end
  end

  def summary_table
    return @summary_table if @summary_table.present?

    @summary_table = @wrapped.map do |wrapped_result|
      result = wrapped_result.this

      client = result.client
      mentor = client.employee
      local_admin = mentor.employee
      last_question = wrapped_result.question_results.last

      row = [
        client.code_name,
        mentor.full_name,
        local_admin&.organisation,
        local_admin&.full_name,
        result.created_at,
        result.is_ended ? 1 : 0,
        result.is_ended ? last_question&.finish : '',
        result.test.name,
      ]

      wrapped_result.question_results.each do |wrapped_qr|
        # - for each question 3 additional columns : response (1/0) interest field, time for answering
        row.concat([
          wrapped_qr.counted? ? 1 : 0,
          wrapped_qr.interests.map { |wrapped_i| wrapped_i.interest.name }.join(', '),
          '%0.2f s'%[wrapped_qr.answer_time]
        ])
      end
      diff = @max_questions - wrapped_result.question_results.size

      row.concat(['']*3*diff) if diff.positive?

      row
    end
  end
end
