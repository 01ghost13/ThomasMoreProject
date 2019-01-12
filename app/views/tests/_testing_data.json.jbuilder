json.testing do
  json.current_question do
    json.extract! question, *%i[id number]
    json.description description
    json.image_url url_for(image)
  end

  json.previous_question do
    json.extract! previous_question, *%i[id number]
    json.description previous_question.picture.description
    json.image_url url_for(previous_question.picture.image)
  end
end

json.static_pics do
  json.btn_back image_url('btn_back.png')
  json.btn_exit image_url('btn_exit.png')
  json.btn_thumbs_down image_url('btn_td.png')
  json.btn_thumbs_up image_url('btn_tu.png')
  json.btn_question_mark image_url('btn_qm.png')
end

json.questions_count test.questions.count

json.test_id test.id

json.student_id student.id

json.start_time DateTime.current
