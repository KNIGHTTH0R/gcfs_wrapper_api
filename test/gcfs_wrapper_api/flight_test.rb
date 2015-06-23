
require 'helper'

describe 'flight' do

  describe 'as administrator' do

    before do
      Gcfs::Wrapper::Api::configure do |config|
        config.key      = 'DQI5DqcwA2fuEARnciMWl5oHroU'
        config.secret   = 'vH6urcUIjh20aq4qLKQYXTLIUIw'
        config.username = 'derri@giftcard.co.id'
        config.password = '12345678'
      end
      VCR.use_cassette('token/request_token/success_flight') do
        @token = Gcfs::Wrapper::Api::Token.request
      end
    end

    it "search and list flight" do
      VCR.use_cassette('flight/administrator/search/success') do
        params = {
                    "d":"CGK",
                    "a":"DPS",
                    "date":"2015-07-29",
                    "ret_date":"2015-07-30",
                    "adult":"1",
                    "child":"0",
                    "infant":"0",
                    "sort":"priceasc",
                    "metadata":{
                        "user":{
                            "id": 1, #Your App current_user's id
                            "name": "derri@giftcard.co.id" #Your App current_user's email
                        }
                    }
                }


        search = Gcfs::Wrapper::Api::Flight.search params
        search['departures']['result'].sample['flight_id'].empty?.must_equal false
        search['returns']['result'].sample['flight_id'].empty?.must_equal false
      end
    end

    it "response error message, when search and list flight with invalid params" do
      VCR.use_cassette('flight/administrator/search/invalid') do
        params = {
                    "d":"CGK",
                    "a":"DPS",
                    "date":"2015-07-28",
                    "ret_date":"2015-07-30",
                    "sort":"priceasc",
                    "metadata":{
                        "user":{
                            "id": 1, #Your App current_user's id
                            "name": "derri@giftcard.co.id" #Your App current_user's email
                        }
                    }
                }


        search = Gcfs::Wrapper::Api::Flight.search params
        search.message.must_equal "adult is missing"
      end
    end

    it "get airport list" do
      VCR.use_cassette('flight/administrator/airports/success') do
        params = {
                  metadata: {
                    user: {
                      id: 1,
                      name: "windiana@giftcard.co.id"
                    }
                  }
                }


        airports = Gcfs::Wrapper::Api::Flight.airports params
        airports['airport'].count.must_equal 242
        
      end
    end

    it "response, when create flight order" do
      VCR.use_cassette('flight/administrator/order/success') do
        firstname = "Inez"
        lastname = "erika"
        salutation = "Ms"

        params = {
                    "flight_id": "960685",
                    "ret_flight_id": "144355",
                    "date": "2015-08-09",
                    "adult": 1,
                    "conSalutation": salutation,
                    "conFirstName": firstname,
                    "conLastName": lastname,
                    "conPhone": "6287880182218",
                    "conEmailAddress": "jess@kim.com",
                    "firstnamea1": firstname,
                    "lastnamea1": lastname,
                    "birthdatea1": "1988-02-02",
                    "ida1": "1234567890",
                    "titlea1": salutation,
                    "conOtherPhone": "6287880182236",
                    "passportnoa1": "A37365",
                    "passportExpiryDatea1": "2017-07-30",
                    "passportissueddatea1": "2012-07-30",
                    "passportissuinga1": "id",
                    "passportnationalitya1": "id",
                    "dcheckinbaggagea11": 0,
                    "rcheckinbaggagea11": 20,
                    "recepient": {
                      "name": "Scarlett",
                      "email": "windiana88@hotmail.com",
                      "phone_number": "08155566945"
                    },
                    "metadata": {
                      "user": {
                        "id": 1,
                        "name": "windiana@giftcard.co.id"
                      }
                    }
                  }


        order = Gcfs::Wrapper::Api::Flight.process_order params
        order.id.must_equal 102
        order.transaction_id.must_equal "et5q7H4K9F"
        order.recepient.name.must_equal "Scarlett"

      end
    end

  end

  describe 'as developer' do

    before do
      Gcfs::Wrapper::Api::configure do |config|
        config.key      = 'DQI5DqcwA2fuEARnciMWl5oHroU'
        config.secret   = 'vH6urcUIjh20aq4qLKQYXTLIUIw'
        config.username = 'derri@giftcard.co.id'
        config.password = '12345678'
      end
      VCR.use_cassette('token/request_token/success_flight') do
        @token = Gcfs::Wrapper::Api::Token.request
      end
    end

    it "search and list flight" do
      VCR.use_cassette('flight/developer/search/success') do
        startdates = "2012-07-21"
        enddates = "2012-07-22"
        params = {
                    "d":"CGK",
                    "a":"DPS",
                    "date":"2015-07-29",
                    "ret_date":"2015-07-30",
                    "adult":"1",
                    "child":"0",
                    "infant":"0",
                    "sort":"priceasc",
                    "metadata":{
                        "user":{
                            "id": 1, #Your App current_user's id
                            "name": "derri@giftcard.co.id" #Your App current_user's email
                        }
                    }
                }


        search = Gcfs::Wrapper::Api::Flight.search params
        search['departures']['result'].sample['flight_id'].empty?.must_equal false
        search['returns']['result'].sample['flight_id'].empty?.must_equal false
      end
    end

    it "response error message, when search and list flight with invalid params" do
      VCR.use_cassette('flight/developer/search/invalid') do
        startdates = "2012-07-21"
        enddates = "2012-07-22"
        params = {
                    "d":"CGK",
                    "a":"DPS",
                    "date":"2015-07-28",
                    "ret_date":"2015-07-30",
                    "sort":"priceasc",
                    "metadata":{
                        "user":{
                            "id": 1, #Your App current_user's id
                            "name": "derri@giftcard.co.id" #Your App current_user's email
                        }
                    }
                }


        search = Gcfs::Wrapper::Api::Flight.search params
        search.message.must_equal "adult is missing"
      end
    end

    it "get airport list" do
      VCR.use_cassette('flight/developer/airports/success') do
        startdates = "2012-07-21"
        enddates = "2012-07-22"
        params = {
                  metadata: {
                    user: {
                      id: 1,
                      name: "windiana@giftcard.co.id"
                    }
                  }
                }


        airports = Gcfs::Wrapper::Api::Flight.airports params
        airports['airport'].count.must_equal 242
        
      end
    end

    it "response, when create flight order" do
      VCR.use_cassette('flight/developer/order/success') do
        firstname = "Alexander"
        lastname = "Emilianengko"
        salutation = "Mr"

        params = {
                    "flight_id": "960685",
                    "ret_flight_id": "144355",
                    "date": "2015-08-09",
                    "adult": 1,
                    "conSalutation": salutation,
                    "conFirstName": firstname,
                    "conLastName": lastname,
                    "conPhone": "6287880182218",
                    "conEmailAddress": "jess@kim.com",
                    "firstnamea1": firstname,
                    "lastnamea1": lastname,
                    "birthdatea1": "1988-02-02",
                    "ida1": "1234567890",
                    "titlea1": salutation,
                    "conOtherPhone": "6287880182236",
                    "passportnoa1": "A37365",
                    "passportExpiryDatea1": "2017-07-30",
                    "passportissueddatea1": "2012-07-30",
                    "passportissuinga1": "id",
                    "passportnationalitya1": "id",
                    "dcheckinbaggagea11": 0,
                    "rcheckinbaggagea11": 20,
                    "recepient": {
                      "name": "Scarlett",
                      "email": "windiana88@hotmail.com",
                      "phone_number": "08155566945"
                    },
                    "metadata": {
                      "user": {
                        "id": 1,
                        "name": "windiana@giftcard.co.id"
                      }
                    }
                  }


        order = Gcfs::Wrapper::Api::Flight.process_order params
        order.id.must_equal 103
        order.transaction_id.must_equal "Va9vx2kyq3"
        order.recepient.name.must_equal "Scarlett"

      end
    end

  end
  
end