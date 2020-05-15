json.picture do
  json.extract! picture, *%i[id description]

  json.picture_interests_attributes do
    json.array! picture.picture_interests, *%i[id interest_id earned_points]
  end
end
json.picture_preview url_for(picture.small_variant) if picture.image.attachment.present?
json.audio_preview url_for(picture.audio) if picture.audio.attachment.present?
json.interests_list do
  json.array! Interest.interests_hash
end
json.form_type form_type
