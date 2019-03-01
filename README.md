# ValkyrieStorageS3

An S3 storage adapter for [Valkyrie](https://github.com/samvera-labs/valkyrie)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'valkyrie-storage-s3'
```

## Usage

Follow the Valkyrie README to get a development or production environment up and running. 

To enable S3 storage support, add the following to your application's ```config/initializers/valkyrie.rb```:

```ruby
    Valkyrie::StorageAdapter.register(
      Valkyrie::Storage::S3.new(
        bucket_config: { bucket: 'test' },
        aws_config: {
          region: 'us-east-1',
          endpoint: "http://127.0.0.1:4572",
          credentials: Aws::Credentials.new('anything', 'anything'),
          force_path_style: true
        }
      ),
      :s3
    )
```
You can then use `:s3` as a storage adapter value in `config/valkyrie.yml`

## Testing

The tests require an S3 endpoint. LocalStack can be used for this.

```
pip3 install localstack
SERVICES=s3 localstack start
```

Alternatively if you have `docker`, `docker-compose`, and `docker-machine` installed:

```
rake docker:spec
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/stkenny/valkyrie-storage-s3/.

## License

`ValkyrieStorageS3` is available under [the Apache 2.0 license](LICENSE).
