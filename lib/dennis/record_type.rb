# frozen_string_literal: true

module Dennis
  class RecordType

    class << self

      def all(client)
        request = client.api.create_request(:get, 'record_types')
        request.perform.hash['record_types'].each_with_object({}) do |rt, hash|
          type = new(rt)
          hash[type.name] = type
        end
      end

    end

    def initialize(hash)
      @hash = hash
    end

    def name
      @hash['name']
    end

    def requires_priority?
      @hash['requires_priority'] == true
    end

    def managed_only?
      @hash['managed_only'] == true
    end

    def exposed?
      @hash['exposed'] == true
    end

    def content_attributes
      @hash['content_attributes'].map do |hash|
        ContentAttribute.new(hash)
      end
    end

    class ContentAttribute

      def initialize(hash)
        @hash = hash
      end

      def name
        @hash['name']
      end

      def label
        @hash['label']
      end

      def type
        @hash['type']
      end

      def options
        return [] if @hash['options'].nil?

        @hash['options'].map do |hash|
          ContentAttributeOption.new(hash)
        end
      end

    end

    class ContentAttributeOption

      def initialize(hash)
        @hash = hash
      end

      def label
        @hash['label']
      end

      def value
        @hash['value']
      end

    end

  end
end
