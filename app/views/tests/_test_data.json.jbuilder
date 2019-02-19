json.test do
  json.extract! test, *Test.attribute_names
  json.questions_attributes do
    json.array! test.questions, *Question.attribute_names
  end
end

json.picture_list do
  json.array! Picture.with_attached_image.order(:description) do |picture|
    json.id picture.id
    json.preview url_for(picture.image.variant(resize: '150x150')) if picture.image.attachment.present?
    json.name picture.description
  end
end

json.form_type form_type