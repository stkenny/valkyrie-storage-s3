# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'
include ActionDispatch::TestProcess

RSpec.describe Valkyrie::Storage::S3 do
  it_behaves_like "a Valkyrie::StorageAdapter"

  aws_config = {
    region: 'us-east-1',
    endpoint: "http://127.0.0.1:4572",
    credentials: Aws::Credentials.new('anything', 'anything'),
    force_path_style: true
  }
  let(:storage_adapter) { described_class.new(bucket_config: { bucket: 'test' }, aws_config: aws_config) }
  let(:file) { fixture_file_upload('files/example.tif', 'image/tiff') }
end
