# Dennis API Client

This is a Ruby API client for Dennis.

## Usage

```ruby
# Create an API client with the hostname & API token needed to connect
# and authenticate.
client = Dennis.new('dns-manager.example.com', 'API_TOKEN')

# Find a group with ID 123
group = client.group(123)

# Find a group with an external reference
group = client.group('some-ref', field: :external_reference)

# Get a list of zones within a group
zones = group.zones

# Get a zone by its ID
zone = client.zone(123)

# Get a zone by its external reference
zone = client.zone('some-ref', field: :external_reference)

# Get all the records for a zone
zone.records

# Create a new group
group = client.create_group(name: 'My example group', external_reference: 'some-ref')

# Return an array of nameservers assigned to a group
group.nameservers

# Create a new zone
zone = group.create_zone('example.com')

# Create a new record
record = zone.create_record(type: 'A', name: 'www', content: { ip_address: '185.22.208.1' })

# Delete a record
record.delete

# Update a record
record.update(content: { ip_address: '185.22.208.5'} )
```
