module TranslationModule
  extend ActiveSupport::Concern

  included do
    before_action :preload_translations

    helper_method :tf,
                  :translate_field,
                  :translate_errors,
                  :cache_json,
                  :wrap_language

    class_attribute :translate_fields

    class << self
      attr_reader :translate_fields

      def translations_for_preload(translation_names)
        @translate_fields ||= []
        @translate_fields += translation_names
      end

    end
  end

  attr_reader :translation_service

  delegate :translate_field, :tf, :cache_json, to: :translation_service

  def preload_translations
    lang_id =
      if current_user.present?
        current_user.language_id
      else
        Language.first.id
      end
    @translation_service = TranslatorService.new(lang_id)

    if translate_fields.present?
      translation_service.preload(translate_fields)
    end
  end

  def translate_errors(errors, entity)
    entity_name = entity.class.to_s.pluralize.downcase
    ErrorsTranslator.translate_errors(errors.details, entity_name, translation_service)
  end

  def wrap_language(array)
    Translatable.wrap_language(array, current_user.language_id)
  end
end
