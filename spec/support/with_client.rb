# frozen_string_literal: true

RSpec.shared_context 'with client' do
  before do
    VCR.use_cassette('client') do
      @client = Dennis::Client.new(ENV['DENNIS_HOSTNAME'] || 'dennis.localhost', ENV['DENNIS_API_KEY'] || 'test')
    end
  end
end
