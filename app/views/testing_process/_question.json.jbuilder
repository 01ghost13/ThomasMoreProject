json.extract! question, *%i[id number]

json.description question.attachment_description

if question.youtube?
  json.youtube_link question.youtube_link.embed
else
  json.image_url url_for(question.picture.middle_variant)
  json.audio_url url_for(question.picture.audio) if question.picture.audio.attachment.present?
end
