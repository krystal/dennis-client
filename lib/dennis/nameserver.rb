# frozen_string_literal: true

module Dennis
  class Nameserver

    class << self

      def all(client)
        nameservers = client.api.perform(:get, 'nameservers')
        nameservers.hash['nameservers'].map { |hash| new(client, hash) }
      end

      def find_by(client, field, value)
        request = client.api.create_request(:get, 'nameservers/:nameserver')
        request.arguments[:nameserver] = { field => value }
        new(client, request.perform.hash['nameserver'])
      rescue RapidAPI::RequestError => e
        e.code == 'nameserver_not_found' ? nil : raise
      end

      def create(client, name:, server: nil)
        request = client.api.create_request(:post, 'nameservers')
        request.arguments[:properties] = { name: name, server: server }
        new(client, request.perform.hash['nameserver'])
      rescue RapidAPI::RequestError => e
        raise ValidationError, e.detail['errors'] if e.code == 'validation_error'

        raise
      end

    end

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

    def update(properties)
      req = @client.api.create_request(:patch, 'nameservers/:nameserver')
      req.arguments['nameserver'] = { id: id }
      req.arguments['properties'] = properties
      @hash = req.perform.hash['nameserver']
      true
    rescue RapidAPI::RequestError => e
      raise ValidationError, e.detail['errors'] if e.code == 'validation_error'

      raise
    end

    def delete
      req = @client.api.create_request(:delete, 'nameservers/:nameserver')
      req.arguments['nameserver'] = { id: id }
      req.perform
      true
    end

  end
end
