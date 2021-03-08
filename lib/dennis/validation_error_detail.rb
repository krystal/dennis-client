# frozen_string_literal: true

module Dennis
  class ValidationErrorDetail

    def initialize(hash)
      @hash = hash
    end

    def attribute
      @hash['attribute']
    end

    def type
      @hash['type']
    end

    def message
      @hash['message']
    end

  end
end
