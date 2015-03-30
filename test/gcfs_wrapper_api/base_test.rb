require 'helper'
 
describe 'base' do
 
  describe "default attributes" do
 
    it "must include httparty methods" do
      Gcfs::Wrapper::Api::Base.must_include HTTParty
    end
 
    it "must have the base url set to the GCFS API endpoint" do
      Gcfs::Wrapper::Api::Base.base_uri.must_include Gcfs::Wrapper::Api::Configuration::DEFAULT_ENDPOINT
    end
 
  end
 
end