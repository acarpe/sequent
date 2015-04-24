require 'active_model'

module Sequent
  module Core
    module Helpers
      # Validates DateTimes
      # Automatically included when using a
      #
      #   attrs value: DateTime
      class DateTimeValidator < ActiveModel::EachValidator
        def validate_each(subject, attribute, value)
          return if value.is_a?(DateTime)
          DateTime.deserialize_from_hash(value)
        rescue
          subject.errors.add attribute, :invalid_date_time
        end
      end
    end
  end
end
