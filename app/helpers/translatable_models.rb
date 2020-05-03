module TranslatableModels
  extend ActiveSupport::Concern

  included do
    class_attribute :translate_fields

    attr_accessor :language_id

    delegate :translate_field, :tf, :cache_json, to: :translation_service

    class << self
      attr_reader :translate_fields

      def translations_for_preload(translation_names)
        @translate_fields ||= []
        @translate_fields += translation_names
      end

    end
  end

  def preload_translations
    lang_id =
        if language_id.present?
          language_id
        else
          Language.first.id
        end
    @translation_service = TranslatorService.new(lang_id)

    if translate_fields.present?
      translation_service.preload(translate_fields)
    end
  end

  def translation_service
    preload_translations if @translation_service.blank?
    @translation_service
  end
end
