# frozen_string_literal: true

require 'dennis/error'
require 'dennis/validation_error_detail'

module Dennis
  class ValidationError < Error

    attr_reader :errors

    def initialize(errors)
      super
      @errors = errors.map { |e| ValidationErrorDetail.new(e) }
    end

    def to_s
      "Validation error: #{errors.map(&:message).join(', ')}"
    end

  end
end
