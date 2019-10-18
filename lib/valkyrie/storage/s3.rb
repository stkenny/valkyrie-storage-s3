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

      @client = Aws::S3::Resource.new
      @client.create_bucket(bucket_config)
    end

    # @param file [IO]
    # @param original_filename [String]
    # @param resource [Valkyrie::Resource]
    # @param _extra_arguments [Hash] additional arguments which may be passed to other adapters
    # @return [Valkyrie::StorageAdapter::StreamFile]
    def upload(file:, original_filename:, resource: nil, **_extra_arguments)
      id = "#{resource.id}/#{original_filename}"
      s3_object(id).upload_file(file.path)

      find_by(id: "#{PROTOCOL}#{id}")
    end

    # Return the file associated with the given identifier
    # @param id [Valkyrie::ID]
    # @return [Valkyrie::StorageAdapter::StreamFile]
    # @raise Valkyrie::StorageAdapter::FileNotFound if nothing is found
    def find_by(id:)
      Valkyrie::StorageAdapter::StreamFile.new(id: id, io: s3_object(id).get.body)
    rescue Aws::S3::Errors::NoSuchKey
      raise Valkyrie::StorageAdapter::FileNotFound
    end

    # @param id [Valkyrie::ID]
    # @return [Boolean] true if this adapter can handle this type of identifer
    def handles?(id:)
      id.to_s.start_with?(PROTOCOL)
    end

    # Delete the file associated with the given identifier.
    # @param id [Valkyrie::ID]
    def delete(id:)
      s3_object(id).delete
    end

    private

      def file_key(id)
        id.to_s.gsub(/^s3:\/\//, '')
      end

      def s3_object(id)
        @client.bucket(@bucket).object(file_key(id))
      end
  end
end
