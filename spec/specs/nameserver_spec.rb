# frozen_string_literal: true

require 'spec_helper'

module Dennis

  describe Nameserver do
    include_context 'with client'

    describe '.all' do
      it 'returns an array of all nameservers' do
        VCR.use_cassette('nameserver-all') do
          nameservers = described_class.all(@client)
          expect(nameservers).to be_a Array
        end
      end
    end

    describe '.find_by' do
      it 'can find nameservers by ID' do
        VCR.use_cassette('nameserver-find-by-id') do
          nameserver = described_class.find_by(@client, :id, 2)
          expect(nameserver).to be_a Nameserver
          expect(nameserver).to have_attributes(id: 2, name: 'alex.example.com')
        end
      end

      it 'returns nil if no nameserver is found' do
        VCR.use_cassette('nameserver-find-by-id-missing') do
          nameserver = described_class.find_by(@client, :id, 99_999)
          expect(nameserver).to be nil
        end
      end

      it 'raises an error if another issue arises' do
        VCR.use_cassette('nameserver-find-by-invalid-column') do
          expect { described_class.find_by(@client, :invalid, '') }.to raise_error(RapidAPI::RequestError) do |e|
            expect(e.status).to eq 400
            expect(e.code).to eq 'invalid_argument'
          end
        end
      end
    end

    describe '.create' do
      it 'returns the newly created nameserver' do
        VCR.use_cassette('nameserver-create') do
          nameserver = described_class.create(@client, name: 'jim.example.com', server: 1)
          expect(nameserver).to be_a Nameserver
          expect(nameserver).to have_attributes name: 'jim.example.com', server: 1
        end
      end

      it 'raises a validation error if there is an issue' do
        VCR.use_cassette('nameserver-create-validation-error') do
          expect do
            described_class.create(@client, name: '')
          end.to raise_error ValidationError do |e|
            expect(e.errors).to match array_including(
              having_attributes(attribute: 'name', type: 'blank')
            )
          end
        end
      end
    end

    describe '#update' do
      it 'updates the nameserver' do
        VCR.use_cassette('nameserver-update') do
          nameserver = described_class.find_by(@client, :id, 1)
          nameserver.update(name: 'phil.example.com', server: 2)
          expect(nameserver.name).to eq 'phil.example.com'
          expect(nameserver.server).to eq 2
        end

        # Verify with a new cassette to trigger a new update
        VCR.use_cassette('nameserver-update-after-update-complete') do
          nameserver = described_class.find_by(@client, :id, 1)
          expect(nameserver.name).to eq 'phil.example.com'
          expect(nameserver.server).to eq 2
        end
      end

      it 'raises a validation error if appropriate' do
        VCR.use_cassette('nameserver-update-with-validation-error') do
          nameserver = described_class.find_by(@client, :id, 1)
          expect { nameserver.update(name: '') }.to raise_error ValidationError do |e|
            expect(e.errors).to match array_including(
              having_attributes(attribute: 'name', type: 'blank')
            )
          end
        end
      end
    end

    describe '#delete' do
      it 'deletes the nameserver' do
        nameserver = nil
        VCR.use_cassette('nameserver-create-for-delete') do
          nameserver = described_class.create(@client, name: 'delete-me.example.com', server: 2)
        end

        VCR.use_cassette('nameserver-delete') do
          nameserver = described_class.find_by(@client, :id, nameserver.id)
          nameserver.delete
        end

        VCR.use_cassette('nameserver-delete-verify') do
          nameserver = described_class.find_by(@client, :id, nameserver.id)
          expect(nameserver).to be nil
        end
      end
    end
  end

end
