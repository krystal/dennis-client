# frozen_string_literal: true

require 'dennis/error'
require 'dennis/validation_error'
require 'dennis/zone_not_found_error'

module Dennis
  class Record

    class << self

      def all(client, zone, type: nil, name: nil, query: nil, tags: nil)
        request = client.api.create_request(:get, 'zones/:zone/records')
        request.arguments[:zone] = zone
        request.arguments[:name] = name if name
        request.arguments[:type] = type if type
        request.arguments[:query] = query if query
        request.arguments[:tags] = tags if tags
        request.perform.hash['records'].map { |hash| new(client, hash) }
      end

      def all_by_tag(client, tags, group: nil)
        request = client.api.create_request(:get, 'records/tagged')
        request.arguments[:tags] = tags
        request.arguments[:group] = group if group
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

      def create_or_update(client, zone_id, **properties)
        if properties[:external_reference].nil?
          raise Dennis::ExternalReferenceRequiredError, 'An external_reference must be provided to use create_or_update'
        end

        record = find_by(client, :external_reference, properties[:external_reference])
        if record.nil?
          create(client, zone: { id: zone_id }, **properties)
        else
          record.update(properties)
          record
        end
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

    def managed?
      @hash['managed']
    end

    def created_at
      return nil if @hash['created_at'].nil?
      return @hash['created_at'] if @hash['created_at'].is_a?(Time)

      Time.at(@hash['created_at'])
    end

    def updated_at
      return nil if @hash['updated_at'].nil?
      return @hash['updated_at'] if @hash['updated_at'].is_a?(Time)

      Time.at(@hash['updated_at'])
    end

    def zone
      return @zone if @zone
      return nil unless @hash['zone']

      @zone = Zone.new(@client, @hash['zone'])
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
