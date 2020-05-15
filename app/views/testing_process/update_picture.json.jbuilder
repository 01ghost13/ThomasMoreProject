json.next_question do
  json.partial! partial: 'testing_process/question.json', locals: { question: @question }
end
json.start_time DateTime.current
start_number = @start_number

json.questions do
  questions = @test.questions.sort_by(&:number).slice(start_number, 10)
  json.partial! partial: 'testing_process/question.json',
                collection: questions,
                as: :question
end
