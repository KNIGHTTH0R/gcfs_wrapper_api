require 'gcfs_wrapper_api'
require 'minitest/spec'
require 'minitest/autorun'
require 'webmock/minitest'
require 'vcr'
require 'faker'
require 'test_helper'

VCR.configure do |c|
  c.cassette_library_dir = "test/fixtures"
  c.hook_into :webmock
end