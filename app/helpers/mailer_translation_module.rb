module MailerTranslationModule
  extend ActiveSupport::Concern

  included do
    helper_method :tf, :translate_field
  end

  attr_reader :translation_service

  delegate :translate_field, :tf, to: :translation_service

  def init_translation(record)
    lang_id =
        if record.try(:language_id).present?
          record.language_id
        else
          Language.first.id
        end
    @translation_service = TranslatorService.new(lang_id)
  end
end
