# frozen_string_literal: true

require 'dennis/client'

module Dennis

  class << self

    def new(hostname, api_key)
      Client.new(hostname, api_key)
    end

  end

end
