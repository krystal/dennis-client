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

# Get pagination details for the groups
zones.pagination.current_page
zones.pagination.total
zones.pagination.per_page
zones.pagination.total_pages

# Get a zone by its ID
zone = client.zone(123)

# Get a zone by its external reference
zone = client.zone('some-ref', field: :external_reference)

# Get all the records for a zone (paginated)
zone.records
zone.records(page: 2)
zone.records(per_page: 50)

# Get specific type of records for a zone
zone.records(type: 'A')

# Get all records matching a given name
zone.records(name: 'www')

# Get all records matching a given query (for any content in name or content)
zone.records(query: 'v=spf')

# Get all records with ANY of the given tags
zone.records(tags: ['tag1'])

# Create a new group
group = client.create_group(name: 'My example group', external_reference: 'some-ref')

# Return an array of nameservers assigned to a group
group.nameservers

# Get all tagged records for a group
group.tagged_records(['tag1'])

# Lookup a zone within a group
group.zone(1)
group.zone('test.com', field: :name)

# Create a new zone
zone = group.create_zone('example.com')

# Create a new record
record = zone.create_record(type: 'A', name: 'www', content: { ip_address: '185.22.208.1' })

# Delete a record
record.delete

# Update a record
record.update(content: { ip_address: '185.22.208.5'} )

# Get all records with any of the given tags
client.tagged_records(['tag1'])

# Get a list of all the types of records that are supported and the attributes
# needed for them. This will return a hash keyed with the name of the type.
client.record_types
client.record_types['A']
```
