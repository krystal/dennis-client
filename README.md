# Dennis API Client

This is a Ruby API client for Dennis.

## Installation

Install the gem and add to the application's Gemfile by executing:

```
$ bundle add dennis-client
```

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

## Tests

Run the tests and linting via:

```
bin/rspec spec
bin/rubocop
```

### Updating VCR cassettes

If you are making changes that require updates to VCR cassettes then by default it expects to make requests to: `https://dennis.localhost`.
This is configured in `spec/support/with_client.rb`.

In Caddy you can enable this with:

```
dennis.localhost:80 {
  reverse_proxy 127.0.0.1:5050
}

dennis.localhost:443 {
  tls internal
  reverse_proxy 127.0.0.1:5050
}
```

Restart Caddy for the changes to be applied, if you're using homebrew it's `brew services restart caddy`.

Make sure you have `127.0.0.1 dennis.localhost` declared in /etc/hosts.

### API Token

An unrestricted API token is required, on your local Dennis Rails console run:

```ruby
APIToken.create!(name: 'Unrestricted Token', secret: '1.test', global: true)
```

## Release process

The release process is handled by [Schmersion](https://github.com/krystal/schmersion) which is configured in `.schmersion.yaml`.

Schmersion takes care of versioning the gem, creating a tag and updating the changelog.

### Steps:

1. Make a branch from `main`
2. Make your changes and commit them to Git using [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/) style
3. Open a PR on GitHub for review
4. Once approved, merge the PR into `main`
5. Pull down main locally
6. Run `schmersion pending` to confirm the next version and what will be included in the release
7. Run `schmersion release --dry-run` to verify the release
8. Run `schmersion release` to commit the changes and create the new tag
9. Run `git push --tags origin main` to push the commit and new tag to GitHub
10. GitHub Actions will automatically publish the new gem to RubyGems and Krystal's GitHub Package Registry
