# frozen_string_literal: true

require 'dennis/pagination'

module Dennis
  class PaginatedArray < Array

    attr_accessor :pagination

    class << self

      def create(result, key, &block)
        result_hash = result[key]
        array = new(result_hash.map(&block))
        array.pagination = Pagination.new(result['pagination'])
        array
      end

    end

  end
end
