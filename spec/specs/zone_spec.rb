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
          expect { described_class.find_by(@client, :invalid, '') }.to raise_error(RapidAPI::RequestError) do |e|
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

    describe '#update' do
      it 'updates the zone' do
        VCR.use_cassette('zone-update') do
          zone = described_class.find_by(@client, :id, 5)
          zone.update(name: 'raspberries.com', external_reference: 'rasps')
          expect(zone.name).to eq 'raspberries.com'
          expect(zone.external_reference).to eq 'rasps'
        end

        # Verify with a new cassette to trigger a new update
        VCR.use_cassette('zone-update-after-update-complete') do
          zone = described_class.find_by(@client, :id, 5)
          expect(zone.name).to eq 'raspberries.com'
          expect(zone.external_reference).to eq 'rasps'
        end
      end

      it 'raises a validation error if appropriate' do
        VCR.use_cassette('zone-update-with-validation-error') do
          zone = described_class.find_by(@client, :id, 5)
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
          zone = described_class.find_by(@client, :id, 6)
          zone.delete
        end

        VCR.use_cassette('zone-delete-verify') do
          zone = described_class.find_by(@client, :id, 6)
          expect(zone).to be nil
        end
      end
    end
  end

end
