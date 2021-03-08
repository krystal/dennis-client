# frozen_string_literal: true

module Dennis
  class Nameserver

    def initialize(client, hash)
      @client = client
      @hash = hash
    end

    def id
      @hash['id']
    end

    def name
      @hash['name']
    end

    def server
      @hash['server']
    end

  end
end
