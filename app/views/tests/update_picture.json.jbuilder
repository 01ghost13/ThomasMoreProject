json.next_question do
  json.extract! @question, *%i[id number]
  json.description @description
  json.image_url url_for(@image)
end
json.start_time DateTime.current
