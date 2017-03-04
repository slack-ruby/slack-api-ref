module SlackApi
  class SpecValidator

    def initialize(schema)
      @schema = schema
    end

    def valid?(json)
      JSON::Validator.validate(@schema, json)
    end
  end
end
