json.test do
  json.extract! test, *Test.attribute_names
  json.questions_attributes do
    # json.array! test.questions, *Question.attribute_names
    json.array! test.questions do |q|
      json.extract! q, *Question.attribute_names

      if q.youtube_link.present?
        json.youtube_link_attributes do
          json.extract! q.youtube_link, *YoutubeLink.attribute_names
        end
      end
    end
  end
end

json.picture_list do
  json.array! Picture.with_attached_image.order(:description) do |picture|
    json.id picture.id
    json.preview url_for(picture.small_variant) if picture.image.attachment.present?
    json.name picture.description
  end
end

json.form_type form_type
