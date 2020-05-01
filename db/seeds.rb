# Translation schema

def create_hash_translations(hash)
  hash.reduce({}) do |memo, (trans_id, translation)|

    if translation.is_a?(Hash)
      memo.merge!(create_hash_translations(translation).transform_keys! { |key| "#{trans_id}.#{key}" })
    else
      memo[trans_id] = translation
    end

    memo
  end
end
langs = {
  EN: 'config/translations.yml',
  RU: 'config/ru_t.yml',
}

langs.each do |lang, path|
  cur_lang = Language.find_by(name: lang)

  if cur_lang.blank?
    cur_lang = Language.create!(name: lang)
  end

  trans_path_path = Rails.root.join(path)
  translations = YAML::load(File.open(trans_path_path))
  translation_hash = create_hash_translations(translations)

  translation_hash.each do |field_name, translation|
    Translation.find_or_create_by!(field: field_name, value: translation, language_id: cur_lang.id)
  end
end
