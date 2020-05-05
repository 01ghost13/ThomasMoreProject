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
    "<div class=\"date_to_local\">#{converted_date}</div>".html_safe
  end

  def settings_partial
    path = {
      client: 'clients',
      local_admin: 'administrators',
      mentor: 'mentors',
      super_admin: 'administrators'
    }[current_user.role.to_sym]
    "#{path}/settings"
  end

  # Checks is user logged?
  def logged_in?
    user_signed_in?
  end

  # Checks is user - SA
  def is_super?
    current_user.super_admin?
  end

  def show_path_resolver(user)
    case(user.role)
      when :client
        client_path(user)
      when :local_admin
        administrator_path(user)
      when :super_admin
        administrator_path(user)
      when :mentor
        mentor_path(user)
      else
        root_path
    end
  end

  def translate_hash(user_hash, root_key: nil)
    user_hash.reduce({}) do |memo, (key, val)|
      if val.is_a?(Hash)
        memo.merge!(translate_hash(val, root_key: key))
      else
        translated_field = tf("entities.#{root_key}.fields.#{key}")
        memo[translated_field] = val
      end

      memo
    end
  end
end
