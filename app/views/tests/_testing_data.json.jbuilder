json.testing do
  json.current_question do
    json.extract! question, *%i[id number]
    json.description description
    json.image_url url_for(image)
  end

  if previous_question.present?
    json.previous_question do
      json.extract! previous_question, *%i[id number]
      json.description previous_question.picture.description
      json.image_url url_for(previous_question.picture.middle_variant)
    end
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

json.webgazer mode == 'heatmap' ? false : result_of_test.gaze_trace?

json.emotion_tracking mode == 'heatmap' ? false : result_of_test.emotion_recognition?

json.emotion_recogniser_url 'https://westeurope.api.cognitive.microsoft.com/face/v1.0/detect?returnFaceId=false&returnFaceLandmarks=false&returnFaceAttributes=emotion'

json.emotion_azure_key ENV['AZURE_KEY']

json.mode mode
