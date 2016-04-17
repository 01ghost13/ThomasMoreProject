module ApplicationHelper
  #Function for image-links
  def link_to_image(image_path, target_link,options={})
    link_to(image_tag(image_path,class: "img-responsive"), target_link, options)
  end
end
