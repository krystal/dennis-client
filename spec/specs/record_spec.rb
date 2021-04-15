# frozen_string_literal: true

require 'spec_helper'

module Dennis

  describe Record do
    include_context 'with client'

    describe '.all' do
      it 'returns an array of all records within a zone' do
        VCR.use_cassette('record-all') do
          records = described_class.all(@client, { id: 1 })
          expect(records).to be_a Array
        end
      end

      it 'returns an array of all records of a specific type' do
        VCR.use_cassette('record-all-with-type') do
          records = described_class.all(@client, { id: 1 }, type: 'CNAME')
          expect(records).to be_a Array
          expect(records.size).to eq 3
          expect(records.map(&:type)).to all eq 'CNAME'
        end
      end

      it 'returns an array of all records of a specific name' do
        VCR.use_cassette('record-all-with-name') do
          records = described_class.all(@client, { id: 1 }, name: 'helpdesk')
          expect(records).to be_a Array
          expect(records.size).to eq 1
          expect(records[0].content[:hostname]).to eq 'sirportly.com'
        end
      end
      # rubocop:disable Layout/LineLength
      it 'returns an array of all records of a specific type and name' do
        VCR.use_cassette('record-all-with-name-and-type') do
          records = described_class.all(@client, { id: 1 }, type: 'TXT', name: 'cm._domainkey')
          expect(records).to be_a Array
          expect(records.size).to eq 1
          expect(records[0].content[:content]).to eq 'k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCsJyYnv48KsqIS/yLiU1YGjpo+KPTkKAtJEq7RW7dMEM8IzOx96Qa3S0NYDMPr9QJOJoAomLl51YFe5Xu3WlR5f8uNjH/7UujGL9RpT+Gaa23W85qhrWuQpZnBqFczLdxf3R/OP4Sm5KisVvCP+gain4h0yxFFM4UZT4893bl6QwIDAQAB'
        end
      end

      it 'returns an array of all records with a query' do
        VCR.use_cassette('record-all-with-query') do
          records = described_class.all(@client, { id: 1 }, query: '_domainkey')
          expect(records).to be_a Array
          expect(records.size).to eq 1
          expect(records[0].content[:content]).to eq 'k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCsJyYnv48KsqIS/yLiU1YGjpo+KPTkKAtJEq7RW7dMEM8IzOx96Qa3S0NYDMPr9QJOJoAomLl51YFe5Xu3WlR5f8uNjH/7UujGL9RpT+Gaa23W85qhrWuQpZnBqFczLdxf3R/OP4Sm5KisVvCP+gain4h0yxFFM4UZT4893bl6QwIDAQAB'
        end
      end

      it 'returns an array of all records with a root query' do
        VCR.use_cassette('record-all-with-query') do
          records = described_class.all(@client, { id: 1 }, query: '_domainkey')
          expect(records).to be_a Array
          expect(records.size).to eq 1
          expect(records[0].content[:content]).to eq 'k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCsJyYnv48KsqIS/yLiU1YGjpo+KPTkKAtJEq7RW7dMEM8IzOx96Qa3S0NYDMPr9QJOJoAomLl51YFe5Xu3WlR5f8uNjH/7UujGL9RpT+Gaa23W85qhrWuQpZnBqFczLdxf3R/OP4Sm5KisVvCP+gain4h0yxFFM4UZT4893bl6QwIDAQAB'
        end
      end
      # rubocop:enable Layout/LineLength

      it 'returns an array of all records with any of the given tags' do
        VCR.use_cassette('record-all-with-tags') do
          records = described_class.all(@client, { id: 1 }, tags: ['tag2'])
          expect(records).to be_a Array
          expect(records.size).to eq 2
          expect(records).to match array_including(
            have_attributes(content: { ip_address: '185.22.211.61' }),
            have_attributes(content: { ip_address: '2a00:67a0:a:1::1' })
          )
        end
      end

      it 'returns a pagination information' do
        VCR.use_cassette('record-all') do
          zones = described_class.all(@client, { id: 1 })
          expect(zones.pagination.current_page).to eq 1
          expect(zones.pagination.per_page).to eq 30
          expect(zones.pagination.total_pages).to eq 1
        end
      end

      it 'returns can control the number of items per page' do
        VCR.use_cassette('record-all-per-page') do
          zones = described_class.all(@client, { id: 1 }, per_page: 2)
          expect(zones.pagination.current_page).to eq 1
          expect(zones.pagination.per_page).to eq 2
          expect(zones.pagination.total_pages).to be > 1
        end
      end

      it 'returns can control which page is returned' do
        VCR.use_cassette('record-all-page') do
          zones = described_class.all(@client, { id: 1 }, per_page: 2, page: 2)
          expect(zones.pagination.current_page).to eq 2
          expect(zones.pagination.per_page).to eq 2
          expect(zones.pagination.total_pages).to be > 1
        end
      end
    end

    describe '.all_by_tag' do
      it 'returns an array of all records with any of the given tags in any zone' do
        VCR.use_cassette('record-all-by-tag') do
          records = described_class.all_by_tag(@client, ['tag2'])
          expect(records).to be_a Array
          expect(records.size).to eq 3
          expect(records).to match array_including(
            have_attributes(content: { ip_address: '185.22.211.61' }, zone: have_attributes(name: 'example.com')),
            have_attributes(content: { ip_address: '2a00:67a0:a:1::1' }, zone: have_attributes(name: 'example.com')),
            have_attributes(content: { ip_address: '185.22.211.55' }, zone: have_attributes(name: 'bananas.com'))
          )
        end
      end
    end

    describe '.find_by' do
      it 'can find record by ID' do
        VCR.use_cassette('record-find-by-id') do
          record = described_class.find_by(@client, :id, 6)
          expect(record).to be_a Record
          expect(record).to have_attributes(id: 6,
                                            name: nil,
                                            full_name: 'example.com',
                                            type: 'A',
                                            content: { ip_address: '185.22.211.61' })
        end
      end

      it 'can find records by external reference' do
        VCR.use_cassette('record-find-by-ext-ref') do
          record = described_class.find_by(@client, :external_reference, 'www-cname-example')
          expect(record).to be_a Record
          expect(record).to have_attributes(id: 8,
                                            name: 'www',
                                            full_name: 'www.example.com',
                                            type: 'CNAME',
                                            external_reference: 'www-cname-example',
                                            content: { hostname: 'example.com' })
        end
      end

      it 'returns nil if no record is found' do
        VCR.use_cassette('record-find-by-id-missing') do
          record = described_class.find_by(@client, :id, 99_999)
          expect(record).to be nil
        end
      end

      it 'raises an error if another issue arises' do
        VCR.use_cassette('record-find-by-invalid-column') do
          expect { described_class.find_by(@client, :invalid, '') }.to raise_error(RapidAPI::RequestError) do |e|
            expect(e.status).to eq 400
            expect(e.code).to eq 'invalid_argument'
          end
        end
      end
    end

    describe '.create' do
      it 'returns the newly created record' do
        VCR.use_cassette('record-create') do
          zone = described_class.create(@client, zone: { id: 1 }, name: 'test1234', type: 'A',
                                                 content: { ip_address: '10.5.5.5' })
          expect(zone).to be_a Record
          expect(zone).to have_attributes name: 'test1234',
                                          full_name: 'test1234.example.com',
                                          type: 'A',
                                          content: { ip_address: '10.5.5.5' }
        end
      end

      it 'raises a zone not found error if no zone is found' do
        VCR.use_cassette('record-create-missing-zone') do
          expect do
            described_class.create(@client, zone: { id: 99_999 }, name: 'example.com')
          end.to raise_error ZoneNotFoundError
        end
      end

      it 'raises a validation error if there is an issue' do
        VCR.use_cassette('record-create-validation-error') do
          expect do
            described_class.create(@client, zone: { id: 1 })
          end.to raise_error ValidationError do |e|
            expect(e.errors).to match array_including(
              having_attributes(attribute: 'type', type: 'blank')
            )
          end
        end
      end
    end

    describe '.create_or_update' do
      it 'raises an error if no external reference is provided' do
        expect do
          described_class.create_or_update(@client, 1, name: 'A')
        end.to raise_error Dennis::ExternalReferenceRequiredError
      end

      it 'creates a new record if none exists' do
        VCR.use_cassette('record-create-or-update-create') do
          existing = described_class.find_by(@client, :external_reference, 'cou-1')
          expect(existing).to be nil

          result = described_class.create_or_update(@client, 1,
                                                    name: 'cou-1', type: 'A', external_reference: 'cou-1',
                                                    content: { ip_address: '1.1.1.1' })
          expect(result).to be_a Dennis::Record
        end

        VCR.use_cassette('record-create-or-update-create-verify') do
          existing = described_class.find_by(@client, :external_reference, 'cou-1')
          expect(existing).to be_a Dennis::Record
        end
      end

      it 'updates an existing record if there is one' do
        VCR.use_cassette('record-create-or-update-update') do
          existing = described_class.find_by(@client, :external_reference, 'cou-1')
          expect(existing).to be_a Dennis::Record

          result = described_class.create_or_update(@client, 1,
                                                    name: 'cou-1', type: 'A', external_reference: 'cou-1',
                                                    content: { ip_address: '2.2.2.2' })
          expect(result).to be_a Dennis::Record
        end

        VCR.use_cassette('record-create-or-update-update-verify') do
          existing = described_class.find_by(@client, :external_reference, 'cou-1')
          expect(existing).to be_a Dennis::Record
          expect(existing.content[:ip_address]).to eq '2.2.2.2'
        end
      end
    end

    describe '#update' do
      it 'updates the record' do
        VCR.use_cassette('record-update') do
          record = described_class.find_by(@client, :id, 11)
          record.update(name: 'cm._domainkey.renamed', content: { content: 'new txt value' })
          expect(record.name).to eq 'cm._domainkey.renamed'
          expect(record.content[:content]).to eq 'new txt value'
        end

        # Verify with a new cassette to trigger a new update
        VCR.use_cassette('record-update-after-update-complete') do
          record = described_class.find_by(@client, :id, 11)
          expect(record.name).to eq 'cm._domainkey.renamed'
          expect(record.content[:content]).to eq 'new txt value'
        end
      end

      it 'ensures that only updated attributes in a content has are updated' do
        VCR.use_cassette('record-update-specific-content-attrs') do
          record = described_class.find_by(@client, :id, 16)
          original_fingerprint_type = record.content[:fingerprint_type]
          original_algorithm = record.content[:algorithm]
          record.update(content: { fingerprint: 'abcdef1234' })
          expect(record.content[:fingerprint]).to eq 'abcdef1234'
          expect(record.content[:fingerprint_type]).to eq original_fingerprint_type
          expect(record.content[:algorithm]).to eq original_algorithm
        end
      end

      it 'raises a validation error if appropriate' do
        VCR.use_cassette('record-update-with-validation-error') do
          record = described_class.find_by(@client, :id, 11)
          expect { record.update(type: 'A', content: { ip_address: 'invalid' }) }.to raise_error ValidationError do |e|
            expect(e.errors).to match array_including(
              having_attributes(attribute: 'content.ip_address', type: 'invalid_ipv4_address')
            )
          end
        end
      end
    end

    describe '#delete' do
      it 'deletes the record' do
        VCR.use_cassette('record-delete') do
          record = described_class.find_by(@client, :id, 12)
          record.delete
        end

        VCR.use_cassette('record-delete-verify') do
          record = described_class.find_by(@client, :id, 12)
          expect(record).to be nil
        end
      end
    end
  end

end
