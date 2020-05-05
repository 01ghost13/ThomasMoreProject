class TranslationIndex
  attr_reader :languages

  def initialize
    preload_languages
    preload_schema
    preload_translated_columns
  end

  def grouped
    @grouped ||= @languages.map do |language|
      translations = prepare_literal_translations(language)

      translated_columns = prepare_translated_columns(language)

      OpenStruct.new id: language.id,
                     name: language.name,
                     this: language,
                     translations: translations,
                     translated_columns: translated_columns
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
       .includes(:translations, :translated_columns)
    end

    def preload_schema
      trans_path_path = Rails.root.join('config/translations.yml')
      translations = YAML::load(File.open(trans_path_path))
      @translation_hash = create_hash_translations(translations)
    end

    def preload_translated_columns
      trans_path_path = Rails.root.join('config/translated_columns.yml')
      @translated_columns = YAML::load(File.open(trans_path_path))['entity']
    end

    def prepare_literal_translations(language)
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
    end

    def prepare_translated_columns(language)
      grouped_translations = language
        .translated_columns
        .reduce({}) { |memo, translation| memo[translation.field_name] = translation; memo }
      trans_wrapped = []

      @translated_columns.reduce(trans_wrapped) do |memo, (table_name, columns)|
        table_class = table_name.singularize.titleize.constantize
        table_class_ids = table_class.all.select(:id, *columns)

        table_class_ids.each do |record|
          columns.each do |column|

            field = "#{table_name}.#{record.id}.#{column}"

            existed = grouped_translations[field] ||
              TranslatedColumn.new(
                language_id: language.id,
                translatable_type: table_class.to_s,
                translatable_id: record.id,
                target_column: column,
                translation: ''
              )

            memo << OpenStruct.new(
              field: field,
              this: existed,
              id: existed.id,
              value: existed.translation,
              value_en: record[column],
              text_area?: existed.translation.length > 100
            )
          end
        end

        memo
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
    end
end
