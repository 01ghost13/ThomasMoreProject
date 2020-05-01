class TranslatorService
  attr_reader :cache, :lang_id

  def initialize(lang_id)
    @cache = {}
    @lang_id = lang_id
  end

  def preload(translation_names)
    translation_scope(translation_names)
      .each do |t|
        save_cache!(t)
      end
  end

  def translate_field(translation_name, options: nil)
    translated_value =
      if cache.has_key?(translation_name)
        cache[translation_name]
      else
        tt = translation_scope(translation_name).last

        if tt.blank?
          error = "translation #{translation_name} not found"
          Rails.logger.error(error)
          return error
        end

        save_cache!(tt)
      end

    if options.present?
      translated_value % options
    else
      translated_value
    end
  end
  alias :tf :translate_field

  private

    def translation_scope(translation_names)
      Translation
        .where(language_id: lang_id)
        .where('translations.field': translation_names)
    end

    def save_cache!(t)
      @cache[t.field] = t.value
    end
end
