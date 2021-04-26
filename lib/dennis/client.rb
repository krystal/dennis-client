# frozen_string_literal: true

require 'rapid_api'
require 'dennis/group'
require 'dennis/zone'
require 'dennis/nameserver'
require 'dennis/record'
require 'dennis/record_type'

module Dennis
  class Client

    attr_reader :hostname
    attr_reader :api_key
    attr_reader :api

    def initialize(hostname, api_key, **options)
      @hostname = hostname
      @api_key = api_key

      @api = RapidAPI.load(hostname, namespace: 'api/v1', **options)
      @api.headers['Authorization'] = "Bearer #{api_key}"
    end

    def record_types
      RecordType.all(self)
    end

    def groups(**opts)
      Group.all(self, **opts)
    end

    def group(id, field: :id)
      Group.find_by(self, field, id)
    end

    def create_group(**opts)
      Group.create(self, **opts)
    end

    def zones(**opts)
      Zone.all(self, **opts)
    end

    def zone(id, field: :id)
      Zone.find_by(self, field, id)
    end

    def record(id, field: :id)
      Record.find_by(self, field, id)
    end

    def tagged_records(tags, group: nil)
      Record.all_by_tag(self, tags, group: group)
    end

    def nameservers
      Nameserver.all(self)
    end

    def nameserver(id, field: :id)
      Nameserver.find_by(self, field, id)
    end

    def create_nameserver(**opts)
      Nameserver.create(self, **opts)
    end

  end
end
