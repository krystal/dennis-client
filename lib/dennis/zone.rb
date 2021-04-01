# frozen_string_literal: true

require 'dennis/validation_error'
require 'dennis/group_not_found_error'
require 'dennis/record'

module Dennis
  class Zone

    class << self

      def all(client)
        groups = client.api.perform(:get, 'zones')
        groups.hash['zones'].map { |hash| new(client, hash) }
      end

      def all_for_group(client, group)
        request = client.api.create_request(:get, 'groups/:group/zones')
        request.arguments[:group] = group
        request.perform.hash['zones'].map { |hash| new(client, hash) }
      end

      def find_by(client, field, value)
        request = client.api.create_request(:get, 'zones/:zone')
        request.arguments[:zone] = { field => value }
        new(client, request.perform.hash['zone'])
      rescue RapidAPI::RequestError => e
        e.code == 'zone_not_found' ? nil : raise
      end

      def create(client,
                 group:,
                 allow_sub_domains_of_zones_in_other_groups: nil,
                 **properties)
        request = client.api.create_request(:post, 'zones')
        request.arguments[:group] = group
        request.arguments[:properties] = properties
        unless allow_sub_domains_of_zones_in_other_groups.nil?
          request.arguments[:allow_sub_domains_of_zones_in_other_groups] = allow_sub_domains_of_zones_in_other_groups
        end
        new(client, request.perform.hash['zone'])
      rescue RapidAPI::RequestError => e
        raise GroupNotFoundError if e.code == 'group_not_found'
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

    def external_reference
      @hash['external_reference']
    end

    def nameservers_verified_at
      parse_time(@hash['nameservers_verified_at'])
    end

    def nameservers_checked_at
      parse_time(@hash['nameservers_checked_at'])
    end

    def nameservers_verified?
      !nameservers_verified_at.nil?
    end

    def default_ttl
      @hash['default_ttl']
    end

    def create_record(**properties)
      Record.create(@client, zone: { id: id }, **properties)
    end

    def records
      Record.all(@client, { id: id })
    end

    def update(properties)
      req = @client.api.create_request(:patch, 'zones/:zone')
      req.arguments['zone'] = { id: id }
      req.arguments['properties'] = properties
      @hash = req.perform.hash['zone']
      true
    rescue RapidAPI::RequestError => e
      raise ValidationError, e.detail['errors'] if e.code == 'validation_error'

      raise
    end

    def delete
      req = @client.api.create_request(:delete, 'zones/:zone')
      req.arguments['zone'] = { id: id }
      req.perform
      true
    end

    private

    def parse_time(time)
      return nil if time.nil?
      return time if time.is_a?(Time)

      Time.at(time.to_i)
    end

  end
end
