require 'helper'
 
describe 'configuration' do
  before do
    Gcfs::Wrapper::Api.reset
  end

  after do
    Gcfs::Wrapper::Api.reset
  end

  describe '.endpoint' do
    it 'should return default end point' do
      Gcfs::Wrapper::Api.endpoint.must_equal Gcfs::Wrapper::Api::Configuration::DEFAULT_ENDPOINT
    end
  end

  describe '.grant_type' do
    it 'should return default grant_type' do
      Gcfs::Wrapper::Api.grant_type.must_equal Gcfs::Wrapper::Api::Configuration::DEFAULT_GRANT_TYPE
    end
  end

  describe '.scope' do
    it 'should return default scope' do
      Gcfs::Wrapper::Api.scope.must_equal Gcfs::Wrapper::Api::Configuration::DEFAULT_SCOPE
    end
  end

  describe '.key' do
    it 'should return default key' do
      Gcfs::Wrapper::Api.key.must_equal Gcfs::Wrapper::Api::Configuration::DEFAULT_KEY
    end
  end

  describe '.secret' do
    it 'should return default secret' do
      Gcfs::Wrapper::Api.secret.must_equal Gcfs::Wrapper::Api::Configuration::DEFAULT_SECRET
    end
  end

  describe '.access_token' do
    it 'should return default access_token' do
      Gcfs::Wrapper::Api.access_token.must_equal Gcfs::Wrapper::Api::Configuration::DEFAULT_Bearer
    end
  end

  describe '.debug' do
    it 'should return default debug' do
      Gcfs::Wrapper::Api.debug.must_equal Gcfs::Wrapper::Api::Configuration::DEFAULT_DEBUG
    end
  end

  Gcfs::Wrapper::Api::Configuration::VALID_CONFIG_KEYS.each do |key|
    it "should set the #{key}" do
      Gcfs::Wrapper::Api::configure do |config|
        config.send("#{key}=", key)
        Gcfs::Wrapper::Api.send(key).must_equal key
      end
    end
  end
 
end