# frozen_string_literal: true

module SlackApi
  # Validates JSON against an expected schema
  class SpecValidator
    def initialize(schema)
      @schema = schema
    end

    def valid?(json)
      JSON::Validator.validate(@schema, json)
    end
  end
end
