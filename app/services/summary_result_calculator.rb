class SummaryResultCalculator

  def initialize(results)
    ids = results.map(&:id)

    results = ResultOfTest
      .where(id: ids)
      .includes(
        question_results: {
          question: {
            picture: { picture_interests: :interest },
            youtube_link: { picture_interests: :interest },
          }
        }
      )

    @wrapped = results.map do |result|
      OpenStruct.new this: result,
                     question_results: QuestionResultPresenter.wrap(result.question_results)
    end
  end

  def to_graph_data(array, x_axis, y_axis)
    array.reduce({}) { |memo, el| memo[el.send(x_axis)] = el.send(y_axis); memo }
  end

  def table_answer_time
    @table_answer_time ||=
      @wrapped
        .reduce([]) { |memo, result| memo += result.question_results }
        .group_by(&:number)
        .map do |number, qrs|
          times = qrs.map(&:answer_time)

          avg = if times.blank?
                  0
                else
                  times.reduce(&:+) / times.count
                end
          OpenStruct.new number: number,
                         answer_time: avg,
                         pretty_avg: '%0.2f sec' % avg,
                         interests: qrs.first.interests.map(&:interest)
        end
        .sort { |a, b| a.number <=> b.number }
  end

  def avg_answer_time_by_interest
    @avg_answer_time_by_interest ||=
      @wrapped
        .reduce([]) { |memo, result| memo += result.question_results }
        .reduce([]) { |memo, qr| memo += qr.interests }
        .group_by { |interest_presenter| interest_presenter.interest }
        .map do |interest, interest_presenters|
          container = OpenStruct.new(avg_time: 0, this: interest, name: interest.name)
          interest_presenters.reduce(container) do |memo, interest_presenter|
            memo.avg_time += interest_presenter.answer_time

            memo
          end
          container.avg_time /= interest_presenters.count
          container
        end
  end

  def table_interest_points
    # Fix to absolute weights

    @table_interest_points ||=
      @wrapped
        .reduce([]) { |memo, result| memo += result.question_results }
        .reduce([]) { |memo, qr| memo += qr.interests }
        .group_by { |interest_presenter| interest_presenter.interest }
        .map do |interest, interest_presenters|
          container = OpenStruct.new(max_weight: 0, total_weight: 0, this: interest, name: interest.name)

          interest_presenters.reduce(container) do |memo, interest_presenter|
            memo.max_weight += interest_presenter.weight

            if interest_presenter.counted
              memo.total_weight += interest_presenter.weight
            end

            memo
          end

          container.max_weight /= @wrapped.count
          container.total_weight /= @wrapped.count

          container
        end
        .sort { |a, b| b.total_weight <=> a.total_weight }
  end
end
