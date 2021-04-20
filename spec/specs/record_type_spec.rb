# frozen_string_literal: true

require 'spec_helper'

module Dennis

  describe RecordType do
    include_context 'with client'

    describe '.all' do
      it 'returns all the record types' do
        VCR.use_cassette('record-types') do
          types = described_class.all(@client)
          expect(types).to be_a Hash
          expect(types).to match hash_including(
            'A' => have_attributes(
              name: 'A',
              requires_priority?: false,
              exposed?: true,
              managed_only?: false,
              content_attributes: [
                have_attributes(
                  name: 'ip_address',
                  type: 'text',
                  options: []
                )
              ]
            ),
            'SOA' => have_attributes(
              name: 'SOA',
              requires_priority?: false,
              exposed?: true,
              managed_only?: true,
              content_attributes: []
            ),
            'MX' => have_attributes(
              name: 'MX',
              requires_priority?: true,
              exposed?: true,
              managed_only?: false,
              content_attributes: [
                have_attributes(
                  name: 'hostname',
                  type: 'text',
                  options: []
                )
              ]
            ),
            'IPS' => have_attributes(
              exposed?: false
            ),
            'CAA' => have_attributes(
              name: 'CAA',
              exposed?: true,
              requires_priority?: false,
              managed_only?: false,
              content_attributes: [
                have_attributes(
                  name: 'flag',
                  type: 'text',
                  options: []
                ),
                have_attributes(
                  name: 'tag',
                  type: 'options',
                  options: [
                    have_attributes(label: 'issue', value: 'issue'),
                    have_attributes(label: 'issuewild', value: 'issuewild'),
                    have_attributes(label: 'iodef', value: 'iodef'),
                    have_attributes(label: 'contactemail', value: 'contactemail'),
                    have_attributes(label: 'contactphone', value: 'contactphone')
                  ]
                ),
                have_attributes(
                  name: 'value',
                  type: 'text',
                  options: []
                )
              ]
            )
          )
        end
      end
    end
  end

end
