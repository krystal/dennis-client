# frozen_string_literal: true

module Dennis
  class Pagination

    def initialize(hash)
      @hash = hash
    end

    def current_page
      @hash['current_page']
    end

    def total_pages
      @hash['total_pages']
    end

    def total
      @hash['total']
    end

    def per_page
      @hash['per_page']
    end

    def large_set?
      @hash['large_set']
    end

  end
end
