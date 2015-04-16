require 'helper'

describe 'token' do

  it "it will fail" do
    Gcfs::Wrapper::Api.reset

    VCR.use_cassette('token/request_token/failed/when_config_default') do
      token = Gcfs::Wrapper::Api::Token.request

      token.class.must_equal Gcfs::Wrapper::Api::Error
      assert token.kind_of?(Gcfs::Wrapper::Api::Error)

      token.message.must_equal 'invalid_client'
    end
  end

  it "it will fail when config invalid" do
    Gcfs::Wrapper::Api::configure do |config|
      config.key      = '1234567890'
      config.secret   = 'POIUYTREWQ'
      config.username = 'williamson.kasey@renner.biz'
      config.password = '012a6dcc5d09dc318b63296be6b512e1'
    end

    VCR.use_cassette('token/request_token/failed/when_config_invalid') do
      token = Gcfs::Wrapper::Api::Token.request

      token.class.must_equal Gcfs::Wrapper::Api::Error
      assert token.kind_of?(Gcfs::Wrapper::Api::Error)

      token.message.must_equal 'invalid_client'
    end
  end

  it "it will fail when config invalid" do
    Gcfs::Wrapper::Api::configure do |config|
      config.key      = 'APIKEY'
      config.secret   = 'APISECRET'
      config.username = 'williamson.kasey@renner.biz'
      config.password = '012a6dcc5d09dc318b63296be6b512e1'
    end

    VCR.use_cassette('token/request_token/failed/when_user_not_registered') do
      token = Gcfs::Wrapper::Api::Token.request

      token.class.must_equal Gcfs::Wrapper::Api::Error
      assert token.kind_of?(Gcfs::Wrapper::Api::Error)

      token.message.must_equal 'invalid_request'
    end
  end

  it "must generate token" do
    Gcfs::Wrapper::Api::configure do |config|
      config.key      = 'APIKEY'
      config.secret   = 'APISECRET'
      config.username = 'admin@gcfs.co.id'
      config.password = '12345678'
    end
    VCR.use_cassette('token/request_token/success') do
      token = Gcfs::Wrapper::Api::Token.request
      token.must_equal Gcfs::Wrapper::Api.options[:token]
      token.must_equal Gcfs::Wrapper::Api.token
      token.class.must_equal Gcfs::Wrapper::Api::Token
      assert token.kind_of?(Gcfs::Wrapper::Api::Token)

      token.access_token.must_equal '22bf2c808c2f71e656dadcdd6103e202'
      assert token.expires_in >= 0
    end
  end

end