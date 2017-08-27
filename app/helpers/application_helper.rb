module ApplicationHelper
  #Function for image-links
  def link_to_image(image_path, target_link,options={})
    link_to(image_tag(image_path,class: 'img-responsive'), target_link, options)
  end

  #Title for pages
  def full_title(page_title = '')
    base_title = 'AitScore'
    if page_title.empty?
      base_title
    else
      page_title + ' | ' + base_title
    end
  end

  #Adds date_text class to date, so it could be converted via js
  def date_to_local(date=nil)
    if date.nil? || date == ''
      return
    end
    converted_date = date.to_s(:iso8601)
    html_string = "<div class=\"date_to_local\">#{converted_date}</div>".html_safe
  end
end
