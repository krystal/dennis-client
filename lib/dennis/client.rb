# frozen_string_literal: true

require 'rapid_api'
require 'dennis/group'

module Dennis
  class Client

    attr_reader :hostname
    attr_reader :api_key
    attr_reader :api

    def initialize(hostname, api_key)
      @hostname = hostname
      @api_key = api_key

      @api = RapidAPI.load(hostname, namespace: 'api/v1')
      @api.headers['Authorization'] = "Bearer #{api_key}"
    end

    def groups
      Group.all(self)
    end

    def group(id, field: :id)
      Group.find_by(self, field, id)
    end

    def create_group(**opts)
      Group.create(self, **opts)
    end

  end
end
