# frozen_string_literal: true

require 'spec_helper'

module Dennis

  describe Zone do
    include_context 'with client'

    describe '.all' do
      it 'returns an array of all zones' do
        VCR.use_cassette('zone-all') do
          zones = described_class.all(@client)
          expect(zones).to be_a Array
        end
      end

      it 'returns an array of zones matching a query' do
        VCR.use_cassette('zone-all-with-query') do
          zones = described_class.all(@client, query: 'example')
          expect(zones).to be_a Array
          expect(zones.size).to eq 1
          expect(zones[0].name).to eq 'example.com'
        end
      end

      it 'returns an array of zones with the given tags' do
        VCR.use_cassette('zone-all-with-tags') do
          zones = described_class.all(@client, tags: ['colors'])
          expect(zones).to be_a Array
          expect(zones.size).to eq 2
          expect(zones).to match array_including(
            have_attributes(name: 'red.com'),
            have_attributes(name: 'blue.com')
          )
        end
      end

      it 'returns a pagination information' do
        VCR.use_cassette('zone-all') do
          zones = described_class.all(@client)
          expect(zones.pagination.current_page).to eq 1
          expect(zones.pagination.per_page).to eq 30
          expect(zones.pagination.total_pages).to eq 1
        end
      end

      it 'returns can control the number of items per page' do
        VCR.use_cassette('zone-all-per-page') do
          zones = described_class.all(@client, per_page: 2)
          expect(zones.pagination.current_page).to eq 1
          expect(zones.pagination.per_page).to eq 2
          expect(zones.pagination.total_pages).to be > 1
        end
      end

      it 'returns can control which page is returned' do
        VCR.use_cassette('zone-all-page') do
          zones = described_class.all(@client, per_page: 2, page: 2)
          expect(zones.pagination.current_page).to eq 2
          expect(zones.pagination.per_page).to eq 2
          expect(zones.pagination.total_pages).to be > 1
        end
      end
    end

    describe '.find_by' do
      it 'can find zones by ID' do
        VCR.use_cassette('zone-find-by-id') do
          zone = described_class.find_by(@client, :id, 1)
          expect(zone).to be_a Zone
          expect(zone).to have_attributes(id: 1, name: 'example.com')
        end
      end

      it 'can find zones by external reference' do
        VCR.use_cassette('zone-find-by-ext-ref') do
          zone = described_class.find_by(@client, :external_reference, 'bananas')
          expect(zone).to be_a Zone
          expect(zone).to have_attributes(id: 2, name: 'bananas.com', external_reference: 'bananas')
        end
      end

      it 'returns nil if no zone is found' do
        VCR.use_cassette('zone-find-by-id-missing') do
          zone = described_class.find_by(@client, :id, 99_999)
          expect(zone).to be nil
        end
      end

      it 'raises an error if another issue arises' do
        VCR.use_cassette('zone-find-by-invalid-column') do
          expect { described_class.find_by(@client, :invalid, '') }.to raise_error(ApiaClient::RequestError) do |e|
            expect(e.status).to eq 400
            expect(e.code).to eq 'invalid_argument'
          end
        end
      end
    end

    describe '.create' do
      it 'returns the newly created zone' do
        VCR.use_cassette('zone-create') do
          zone = described_class.create(@client, group: { id: 1 }, name: 'potatos.com')
          expect(zone).to be_a Zone
          expect(zone).to have_attributes name: 'potatos.com'
        end
      end

      it 'raises a group not found error if no group is found' do
        VCR.use_cassette('zone-create-missing-group') do
          expect do
            described_class.create(@client, group: { id: 99_999 }, name: 'example.com')
          end.to raise_error GroupNotFoundError
        end
      end

      it 'raises a validation error if there is an issue' do
        VCR.use_cassette('zone-create-validation-error') do
          expect do
            described_class.create(@client, group: { id: 1 }, name: '')
          end.to raise_error ValidationError do |e|
            expect(e.errors).to match array_including(
              having_attributes(attribute: 'name', type: 'blank')
            )
          end
        end
      end
    end

    describe '#record' do
      it 'returns a record if it exists in the zone' do
        VCR.use_cassette('zone-record-lookup') do
          zone = described_class.find_by(@client, :id, 1)
          record = zone.record(6)
          expect(record).to be_a Dennis::Record
          expect(record.id).to eq 6
        end
      end

      it 'returns nil if the record does not exist in the zone' do
        VCR.use_cassette('zone-record-lookup-not-in-zone') do
          zone = described_class.find_by(@client, :id, 1)
          record = zone.record(20)
          expect(record).to be_nil
        end
      end

      it 'returns nil if a record exists but not within the zone' do
        VCR.use_cassette('zone-record-lookup-not-present') do
          zone = described_class.find_by(@client, :id, 1)
          record = zone.record(20_000_000)
          expect(record).to be_nil
        end
      end
    end

    describe '#update' do
      it 'updates the zone' do
        VCR.use_cassette('zone-update') do
          zone = described_class.find_by(@client, :name, 'edit-me.com')
          zone.update(name: 'raspberries.com', external_reference: 'rasps')
          expect(zone.name).to eq 'raspberries.com'
          expect(zone.external_reference).to eq 'rasps'
        end

        # Verify with a new cassette to trigger a new update
        VCR.use_cassette('zone-update-after-update-complete') do
          zone = described_class.find_by(@client, :name, 'raspberries.com')
          expect(zone.name).to eq 'raspberries.com'
          expect(zone.external_reference).to eq 'rasps'
        end
      end

      it 'raises a validation error if appropriate' do
        VCR.use_cassette('zone-update-with-validation-error') do
          zone = described_class.find_by(@client, :name, 'example.com')
          expect { zone.update(name: '') }.to raise_error ValidationError do |e|
            expect(e.errors).to match array_including(
              having_attributes(attribute: 'name', type: 'blank')
            )
          end
        end
      end
    end

    describe '#delete' do
      it 'deletes the zone' do
        VCR.use_cassette('zone-delete') do
          zone = described_class.find_by(@client, :name, 'delete-me.com')
          zone.delete
        end

        VCR.use_cassette('zone-delete-verify') do
          zone = described_class.find_by(@client, :name, 'delete-me.com')
          expect(zone).to be nil
        end
      end
    end

    describe '#verify' do
      it 'returns true if zone is already verified' do
        VCR.use_cassette('zone-verify-already-verified') do
          zone = described_class.find_by(@client, :id, 1)
          expect(zone.verified?).to be true
          expect(zone.verify).to be true
        end
      end

      it 'returns false if zone cannot be verified' do
        VCR.use_cassette('zone-verify-cannot-verify') do
          zone = described_class.find_by(@client, :id, 2)
          expect(zone.verified?).to be false
          expect(zone.verify).to be false
        end
      end
    end

    describe '#txt_record_verification_token' do
      it 'exists for zones' do
        VCR.use_cassette('zone-txt-record-token') do
          zone = described_class.find_by(@client, :id, 1)
          expect(zone.txt_record_verification_token).to be_a String
        end
      end
    end

    describe '#verified_at' do
      it 'is present when the zone is verified' do
        VCR.use_cassette('zone-verified') do
          zone = described_class.find_by(@client, :id, 3)
          expect(zone.verified_at).not_to be nil
        end
      end

      it 'is not present when the zone is not verified' do
        VCR.use_cassette('zone-verify-cannot-verify') do
          zone = described_class.find_by(@client, :id, 2)
          expect(zone.verified_at).to be nil
        end
      end
    end

    describe '#create_record' do
      it 'creates a zone' do
        VCR.use_cassette('zone-find-by-id') do
          group = described_class.find_by(@client, :id, 1)
          expect(Record).to receive(:create) do |_, options|
            expect(options[:zone]).to eq({ id: 1 })
            expect(options[:name]).to eq ''
            expect(options[:type]).to eq 'CNAME'
            expect(options[:content]).to eq({ hostname: 'example.com' })
          end
          group.create_record(name: '', type: 'CNAME', content: { hostname: 'example.com' })
        end
      end
    end

    describe '#records' do
      it 'returns an array of all records for a zone' do
        VCR.use_cassette('zone-find-by-id') do
          zone = described_class.find_by(@client, :id, 1)
          expect(Record).to receive(:all) do |_, z|
            expect(z).to eq({ id: 1 })
          end
          zone.records
        end
      end
    end

    describe '.all_for_group' do
      it 'returns an array of zones for the given group' do
        VCR.use_cassette('zone-all-for-group') do
          zones = described_class.all_for_group(@client, { id: 1 })
          expect(zones).to be_a Array
        end
      end

      it 'returns an array of zones for a given group and query' do
        VCR.use_cassette('zone-all-for-group-with-query') do
          zones = described_class.all_for_group(@client, { id: 1 }, query: 'ample')
          expect(zones).to be_a Array
          expect(zones.size).to eq 1
          expect(zones[0].name).to eq 'example.com'
        end
      end

      it 'returns a pagination information' do
        VCR.use_cassette('zone-all-for-group') do
          zones = described_class.all_for_group(@client, { id: 1 })
          expect(zones.pagination.current_page).to eq 1
          expect(zones.pagination.per_page).to eq 30
          expect(zones.pagination.total_pages).to eq 1
        end
      end

      it 'returns an array of zones with the givne tags' do
        VCR.use_cassette('zone-all-for-group-with-tags') do
          zones = described_class.all_for_group(@client, { id: 4 }, tags: ['colors'])
          expect(zones).to be_a Array
          expect(zones.size).to eq 2
          expect(zones).to match array_including(
            have_attributes(name: 'red.com'),
            have_attributes(name: 'blue.com')
          )
        end
      end

      it 'returns can control the number of items per page' do
        VCR.use_cassette('zone-all-for-group-per-page') do
          zones = described_class.all_for_group(@client, { id: 1 }, per_page: 2)
          expect(zones.pagination.current_page).to eq 1
          expect(zones.pagination.per_page).to eq 2
          expect(zones.pagination.total_pages).to be > 1
        end
      end

      it 'returns can control which page is returned' do
        VCR.use_cassette('zone-all-for-group-page') do
          zones = described_class.all_for_group(@client, { id: 1 }, per_page: 2, page: 2)
          expect(zones.pagination.current_page).to eq 2
          expect(zones.pagination.per_page).to eq 2
          expect(zones.pagination.total_pages).to be > 1
        end
      end
    end

    describe '.create_or_update' do
      it 'raises an error if no external reference is provided' do
        expect do
          described_class.create_or_update(@client, group: { id: 1 }, name: 'example.com')
        end.to raise_error Dennis::ExternalReferenceRequiredError
      end

      it 'creates a new record if none exists' do
        VCR.use_cassette('zone-create-or-update-create') do
          existing = described_class.find_by(@client, :external_reference, 'cou-zone-1')
          expect(existing).to be nil

          result = described_class.create_or_update(@client, group: { id: 1 },
                                                    name: 'cou1.com',
                                                    external_reference: 'cou-zone-1')
          expect(result).to be_a Dennis::Zone
        end

        VCR.use_cassette('zone-create-or-update-create-verify') do
          existing = described_class.find_by(@client, :external_reference, 'cou-zone-1')
          expect(existing).to be_a Dennis::Zone
          expect(existing.name).to eq 'cou1.com'
        end
      end

      it 'updates an existing zone if there is one' do
        VCR.use_cassette('zone-create-or-update-update') do
          existing = described_class.find_by(@client, :external_reference, 'cou-zone-1')
          expect(existing).to be_a Dennis::Zone
          expect(existing.name).to eq 'cou1.com'

          result = described_class.create_or_update(@client, group: { id: 1 },
                                                    name: 'cou2.com',
                                                    external_reference: 'cou-zone-1')
          expect(result).to be_a Dennis::Zone
        end

        VCR.use_cassette('zone-create-or-update-update-verify') do
          existing = described_class.find_by(@client, :external_reference, 'cou-zone-1')
          expect(existing).to be_a Dennis::Zone
          expect(existing.name).to eq 'cou2.com'
        end
      end
    end
  end

end
