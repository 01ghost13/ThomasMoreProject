class ErrorsTranslator
  class << self
    def translate_errors(error_details, entity_name, translation_service)
      field_literal = translation_service.tf('errors.field')

      error_details.reduce([]) do |translated_errors, (field, errors)|
        field_name = translation_service.tf("entities.#{entity_name}.fields.#{field}")

        errors.each do |error_hash|
          error_id = error_hash[:error]
          error_translation = translation_service.tf("errors.#{error_id}")

          ff =
            if nested?(field)
              # TODO Will not work for nesting more than 2
              nested_chain = field.to_s.split('.')
              nested_entity_name = nested_chain.first.pluralize
              nested_field_name = nested_chain.second
              translation_service.tf("entities.#{nested_entity_name}.fields.#{nested_field_name}")
            else
              field_name
            end

          translated_errors << "#{field_literal} '#{ff}' #{error_translation}"
        end

        translated_errors
      end
    end

    private
      def nested?(error_id)
        error_id.to_s.split('.').length > 1
      end
  end
end
