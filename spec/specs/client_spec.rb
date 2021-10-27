# frozen_string_literal: true

require 'spec_helper'

module Dennis

  describe Client do
    it 'initializes a Apia API' do
      VCR.use_cassette('client') do
        client = described_class.new(ENV['DENNIS_HOSTNAME'] || 'dennis.localhost', ENV['DENNIS_API_KEY'] || '1.test')
        expect(client.api).to be_a ApiaClient::API
        expect(client.api.schema).to be_a ApiaSchemaParser::Schema
      end
    end
  end

end
