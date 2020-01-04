json.next_question do
  json.extract! @question, *%i[id number]
  json.description @description

  if @question.youtube?
    json.youtube_link @question.youtube_link.embed
  else
    json.image_url url_for(@question.picture.middle_variant)
  end
end
json.start_time DateTime.current
