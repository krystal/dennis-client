# frozen_string_literal: true

require 'dennis/validation_error'
require 'dennis/zone_not_found_error'

module Dennis
  class Record

    class << self

      def all(client, zone)
        request = client.api.create_request(:get, 'zones/:zone/records')
        request.arguments[:zone] = zone
        request.perform.hash['records'].map { |hash| new(client, hash) }
      end

      def find_by(client, field, value)
        request = client.api.create_request(:get, 'records/:record')
        request.arguments[:record] = { field => value }
        new(client, request.perform.hash['record'])
      rescue RapidAPI::RequestError => e
        e.code == 'record_not_found' ? nil : raise
      end

      def create(client, zone:, **properties)
        request = client.api.create_request(:post, 'records')
        request.arguments[:zone] = zone
        request.arguments[:properties] = properties_to_argument(properties)
        new(client, request.perform.hash['record'])
      rescue RapidAPI::RequestError => e
        raise ZoneNotFoundError if e.code == 'zone_not_found'
        raise ValidationError, e.detail['errors'] if e.code == 'validation_error'

        raise
      end

      def properties_to_argument(hash, type: nil)
        arguments = {}
        [:name, :type, :ttl, :priority, :external_reference].each do |field_name|
          arguments[field_name] = hash[field_name] if hash.key?(field_name)

          type = hash[field_name] if field_name == :type && hash.key?(field_name)
        end

        if hash.key?(:content)
          if type.nil?
            raise Error, 'Cannot generate record properties without a type'
          end

          arguments[:content] = { type.to_s.upcase => hash[:content] }
        end
        arguments
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

    def full_name
      @hash['full_name']
    end

    def type
      @hash['type']
    end

    def ttl
      @hash['ttl']
    end

    def priority
      @hash['priority']
    end

    def external_reference
      @hash['external_reference']
    end

    def content
      return nil if type.nil?

      @hash.dig('content', type.to_s.upcase)&.transform_keys(&:to_sym)
    end

    def update(properties)
      req = @client.api.create_request(:patch, 'records/:record')
      req.arguments['record'] = { id: id }
      req.arguments['properties'] = self.class.properties_to_argument(properties, type: type)
      @hash = req.perform.hash['record']
      true
    rescue RapidAPI::RequestError => e
      raise ValidationError, e.detail['errors'] if e.code == 'validation_error'

      raise
    end

    def delete
      req = @client.api.create_request(:delete, 'records/:record')
      req.arguments['record'] = { id: id }
      req.perform
      true
    end

  end
end
