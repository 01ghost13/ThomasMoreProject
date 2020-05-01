class TranslationIndex
  attr_reader :languages

  def initialize
    preload_languages
    preload_schema
  end

  def grouped
    @grouped ||= @languages.map do |language|

      grouped_translations = language
        .translations
        .reduce({}) { |memo, translation| memo[translation.field] = translation; memo }

      trans_wrapped = @translation_hash.map do |field, translation|
        existed = grouped_translations[field] || Translation.new(language_id: language.id, field: field)
        OpenStruct.new field: field,
                       this: existed,
                       id: existed.id,
                       value: existed.value,
                       value_en: translation,
                       text_area?: translation.length > 100
      end

      trans_wrapped.sort! do |a, b|
        if a.value.blank? && b.value.blank?
          a.value_en <=> b.value_en
        elsif a.value.blank?
          -1
        elsif b.value.blank?
          1
        else
          a.value_en <=> b.value_en
        end
      end

      OpenStruct.new id: language.id,
                     name: language.name,
                     this: language,
                     translations: trans_wrapped
    end
  end

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

  private
    def preload_languages
      @languages = Language
       .all
       .where.not(name: 'EN')
       .includes(:translations)
    end

    def preload_schema
      trans_path_path = Rails.root.join('config/translations.yml')
      translations = YAML::load(File.open(trans_path_path))
      @translation_hash = create_hash_translations(translations)
    end
end
