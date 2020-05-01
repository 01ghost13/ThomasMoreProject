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
# lang = 'RU'
lang = 'EN'
en_lang = Language.find_by(name: lang)

if en_lang.blank?
  en_lang = Language.create!(name: lang)
end

trans_path_path = Rails.root.join('config/translations.yml')
# trans_path_path = Rails.root.join('config/ru_t.yml')
translations = YAML::load(File.open(trans_path_path))
translation_hash = create_hash_translations(translations)

Translation.where(language_id: en_lang.id).destroy_all

translation_hash.each do |field_name, translation|
  Translation.create!(field: field_name, value: translation, language_id: en_lang.id)
end
