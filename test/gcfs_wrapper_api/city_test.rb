require 'helper'

describe 'city' do

  describe 'as administrator' do

    before do
      Gcfs::Wrapper::Api::configure do |config|
        config.key      = 'DQI5DqcwA2fuEARnciMWl5oHroU'
        config.secret   = 'vH6urcUIjh20aq4qLKQYXTLIUIw'
        config.username = 'derri@giftcard.co.id'
        config.password = '12345678'
      end
      VCR.use_cassette('token/request_token/success') do
        @token = Gcfs::Wrapper::Api::Token.request
      end
    end

    it "list of city" do
      VCR.use_cassette('city/administrator/list/all/success') do
        cities = Gcfs::Wrapper::Api::City.all
        
        cities.size.must_equal 20
        cities.total_count.must_equal 167
        cities.total_pages.must_equal 9
        cities.current_page.must_equal 1

        cities.first.class.must_equal Gcfs::Wrapper::Api::City
        assert cities.first.kind_of?(Gcfs::Wrapper::Api::City)

        cities.first.id.must_equal 1
        cities.first.name.must_equal 'banda aceh'
        cities.first.price.must_equal 38500
      end
    end

    it 'raise errors if token invalid' do
      VCR.use_cassette('city/administrator/list/all/token_invalid') do
        Gcfs::Wrapper::Api.access_token = '1234567890ASDFGHJKLMNBVCX'

        cities = Gcfs::Wrapper::Api::City.all
        
        cities.class.must_equal Gcfs::Wrapper::Api::Error
        assert cities.kind_of?(Gcfs::Wrapper::Api::Error)

        cities.message.must_equal 'invalid_request'
      end
    end

  end

  describe 'as developer' do

    before do
      Gcfs::Wrapper::Api::configure do |config|
        config.key      = 'JeXM4bSqiUs-TKvY0_1YOHeqvVA'
        config.secret   = '0eTL6Mb4nQl0cD8p-HZOu-s7cJk'
        config.username = 'mutouzi@gmail.com'
        config.password = '12345678'
      end
      VCR.use_cassette('token/request_token/developer/success') do
        @token = Gcfs::Wrapper::Api::Token.request
      end
    end

    it "list of cities" do
      VCR.use_cassette('city/developer/list/all/success') do
        cities = Gcfs::Wrapper::Api::City.all
        
        cities.size.must_equal 20
        cities.total_count.must_equal 167
        cities.total_pages.must_equal 9
        cities.current_page.must_equal 1

        cities.first.class.must_equal Gcfs::Wrapper::Api::City
        assert cities.first.kind_of?(Gcfs::Wrapper::Api::City)

        cities.first.id.must_equal 1
        cities.first.name.must_equal 'banda aceh'
        cities.first.price.must_equal 38500
      end
    end

    it 'raise errors if token invalid' do
      VCR.use_cassette('city/developer/list/all/token_invalid') do
        Gcfs::Wrapper::Api.access_token = '1234567890ASDFGHJKLMNBVCX'

        cities = Gcfs::Wrapper::Api::City.all
        
        cities.class.must_equal Gcfs::Wrapper::Api::Error
        assert cities.kind_of?(Gcfs::Wrapper::Api::Error)

        cities.message.must_equal 'invalid_request'
      end
    end

  end

end