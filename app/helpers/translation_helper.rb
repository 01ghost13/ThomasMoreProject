module TranslationHelper
  extend ActiveSupport::Concern

  cattr_accessor :translate_fields
  attr_reader :translation_service

  delegate :translate, to: :translation_service

  included do
    before_action :preload_translations
  end

  class << self

    def translations_for_preload(translation_names)
      @translate_fields = translation_names
    end

  end

  def preload_translations
    @translation_service = TranslatorService.new(current_user.lang_id)

    if TranslationHelper.translate_fields.present?
      translation_service.preload(TranslationHelper.translate_fields)
    end
  end
end
