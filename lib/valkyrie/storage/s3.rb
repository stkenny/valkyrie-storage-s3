# frozen_string_literal: true
require 'aws-sdk-s3'

module Valkyrie::Storage
  # Implements the DataMapper Pattern to store binary data in AWS S3
  #
  class S3
    PROTOCOL = 's3://'

    def initialize(bucket_config:, aws_config: {})
      @bucket = bucket_config[:bucket]
      Aws.config.update(aws_config)

      @client = Aws::S3::Client.new
      @client.create_bucket(bucket_config)
    end

    # @param file [IO]
    # @param original_filename [String]
    # @param resource [Valkyrie::Resource]
    # @return [Valkyrie::StorageAdapter::StreamFile]
    def upload(file:, original_filename:, resource: nil)
      @client.put_object(
        bucket: @bucket,
        body: ::File.open(file.path),
        key: "#{resource.id}/#{original_filename}"
      )

      find_by(id: "#{PROTOCOL}#{resource.id}/#{original_filename}")
    end

    # Return the file associated with the given identifier
    # @param id [Valkyrie::ID]
    # @return [Valkyrie::StorageAdapter::StreamFile]
    # @raise Valkyrie::StorageAdapter::FileNotFound if nothing is found
    def find_by(id:)
      resp = @client.get_object(bucket: @bucket, key: file_key(id))
      Valkyrie::StorageAdapter::StreamFile.new(id: id, io: resp.body)
    rescue Aws::S3::Errors::NoSuchKey
      raise Valkyrie::StorageAdapter::FileNotFound
    end

    # @param id [Valkyrie::ID]
    # @return [Boolean] true if this adapter can handle this type of identifer
    def handles?(id:)
      id.to_s.start_with?(PROTOCOL)
    end

    def file_key(id)
      id.to_s.gsub(/^s3:\/\//, '')
    end

    # Delete the file on disk associated with the given identifier.
    # @param id [Valkyrie::ID]
    def delete(id:)
      @client.delete_object(
        bucket: @bucket,
        key: file_key(id)
      )
    end
  end
end
