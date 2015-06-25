require 'helper'

describe 'hotel' do

  describe 'as administrator' do

    before do
      Gcfs::Wrapper::Api::configure do |config|
        config.key      = 'DQI5DqcwA2fuEARnciMWl5oHroU'
        config.secret   = 'vH6urcUIjh20aq4qLKQYXTLIUIw'
        config.username = 'derri@giftcard.co.id'
        config.password = '12345678'
      end
      VCR.use_cassette('token/request_token/success_hotel') do
        @token = Gcfs::Wrapper::Api::Token.request
      end
    end

    it "search and list hotels" do
      VCR.use_cassette('hotel/administrator/search/success') do
        startdates = "2012-07-21"
        enddates = "2012-07-22"
        options = {
                    :q => "legian", 
                    :startdate => startdates , 
                    :enddate => enddates, 
                    :night =>"1", 
                    :room => "1", 
                    :adult => "2", 
                    :child =>"0",
                    :metadata=> {:user=>{ :id=>1,:name=>'derri@giftcard.co.id'}}
                }


        hotels =Gcfs::Wrapper::Api::Hotel.search options
        hotels['results']['result'].count.must_equal 20
        hotels['diagnostic']['status'].must_equal 200
      end
    end

    it "raise error if :q parameter or :uid parameter missing" do
      VCR.use_cassette('hotel/administrator/search/failed_q_or_uid_missing') do
        startdates = "2012-07-21"
        enddates = "2012-07-22"
        options = {
                    :startdate => startdates , 
                    :enddate => enddates, 
                    :night =>"1", 
                    :room => "1", 
                    :adult => "2", 
                    :child =>"0",
                    :metadata=> {:user=>{ :id=>1,:name=>'derri@giftcard.co.id'}}
                }


        hotels =Gcfs::Wrapper::Api::Hotel.search options
        hotels.message.must_equal "q, uid are missing, at least one parameter must be provided"
      end
    end

    it "retrieve list of city if use autocomplete with keyword city only" do
      VCR.use_cassette('hotel/administrator/search_autocomplete/success') do
        startdates = "2012-07-21"
        enddates = "2012-07-22"
        options = {
                    :q => "Bali",
                    :startdate => startdates , 
                    :enddate => enddates, 
                    :night =>"1", 
                    :room => "1", 
                    :adult => "2", 
                    :child =>"0",
                    :metadata=> {:user=>{ :id=>1,:name=>'derri@giftcard.co.id'}}
                }


        hotels =Gcfs::Wrapper::Api::Hotel.search_autocomplete options
        hotels['results']['result'].count.must_equal 5
        hotels['results']['result'].first['tipe'].must_equal "business_id"
      end
    end

    it "retrieve area with valid parameter ex uid=city:178" do
      VCR.use_cassette('hotel/administrator/search_area/success') do
        options = {
                    :uid => "city:178",
                    :metadata=> {:user=>{ :id=>1,:name=>'derri@giftcard.co.id'}}
                }


        area =Gcfs::Wrapper::Api::Hotel.search_area options
        area['results']['result'].count.must_equal 10
        area['results']['result'].sample['uid'].empty?.must_equal false
      end
    end

    it "return empty result array if invalid parameter" do
      VCR.use_cassette('hotel/administrator/search_area/failed_invalid_par1') do
        options = {
                    :uid => "city:12178",
                    :metadata=> {:user=>{ :id=>1,:name=>'derri@giftcard.co.id'}}
                }


        area =Gcfs::Wrapper::Api::Hotel.search_area options
        area['results']['result'].count.must_equal 0
  
      end
    end

    it "retrieve detail of hotel, with parameter hotel_id ex:12453 legian-paradiso-hotel, with 4 rooms" do
      VCR.use_cassette('hotel/administrator/view_detail/success') do
        options = {
                    :hotel_id => 12453,
                    :metadata=> {:user=>{ :id=>1,:name=>'derri@giftcard.co.id'}}
                }


        hotel_detail =Gcfs::Wrapper::Api::Hotel.view_detail options
        hotel_detail['results']['result'].sample['room_id'].empty?.must_equal false
        hotel_detail['results']['result'].count.must_equal 4
        # area['results']['result'].sample['uid'].empty?.must_equal false
      end
    end

    it "raise error message , view detail hotel with invalid parameter ex:invalid hotel_id" do
      VCR.use_cassette('hotel/administrator/view_detail/failed') do
        options = {
                    :hotel_id => 121111453,
                    :metadata=> {:user=>{ :id=>1,:name=>'derri@giftcard.co.id'}}
                }


        hotel_detail =Gcfs::Wrapper::Api::Hotel.view_detail options
        hotel_detail.message.must_equal "Hotel not found, please search other hotel"
        
      end
    end

    it "retrieve , when do process order with valid room_id" do
      VCR.use_cassette('hotel/administrator/search/success') do
        VCR.use_cassette('hotel/administrator/view_detail/success') do
          VCR.use_cassette('hotel/administrator/process_order/success') do
            
            startdates = "2012-07-21"
            enddates = "2012-07-22"
            options = {
                        :q => "legian", 
                        :startdate => startdates , 
                        :enddate => enddates, 
                        :night =>"1", 
                        :room => "1", 
                        :adult => "2", 
                        :child =>"0",
                        :metadata=> {:user=>{ :id=>1,:name=>'derri@giftcard.co.id'}}
                    }


            hotels =Gcfs::Wrapper::Api::Hotel.search options
            hotel_id = hotels['results']['result'].first['hotel_id']

            options = {
                    :hotel_id => hotel_id,
                    :metadata=> {:user=>{ :id=>1,:name=>'derri@giftcard.co.id'}}
                }
            hotel_detail =Gcfs::Wrapper::Api::Hotel.view_detail options
            room_id = hotel_detail['results']['result'].first['room_id']

            @customer_data = {
                          :room_id => room_id,
                          :salutation => "Mr", 
                          :firstName => "Julian", 
                          :lastName => "Stephen", 
                          :phone => "08562969660", 
                          :conSalutation => "Mr", 
                          :conFirstName => "Julian", 
                          :conLastName => "Stephen", 
                          :conEmailAddress => "bima@giftcard.co.id", 
                          :conPhone => "08562969660", 
                          :country => "ID", 
                          :emailAddress => "bima@giftcard.co.id",
                          :recepient=> {:name=>'Bima',:email=>'bima@giftcard.co.id',:phone_number=>'08562969660'},
                          :metadata=> {:user=>{ :id=>1,:name=>'derri@giftcard.co.id'}}
                  }


            orders =Gcfs::Wrapper::Api::Hotel.process_order @customer_data

          end
        end
      end
    end

    it "retrieve error message, when do process order with invalid room_id" do
      VCR.use_cassette('hotel/administrator/process_order/invalid_room_id') do
        @customer_data = {
                      :room_id => @room_id,
                      :salutation => "Mr", 
                      :firstName => "Julian", 
                      :lastName => "Stephen", 
                      :phone => "08562969660", 
                      :conSalutation => "Mr", 
                      :conFirstName => "Julian", 
                      :conLastName => "Stephen", 
                      :conEmailAddress => "bima@giftcard.co.id", 
                      :conPhone => "08562969660", 
                      :country => "ID", 
                      :emailAddress => "bima@giftcard.co.id",
                      :recepient=> {:name=>'Bima',:email=>'bima@giftcard.co.id',:phone_number=>'08562969660'},
                      :metadata=> {:user=>{ :id=>1,:name=>'derri@giftcard.co.id'}}
              }


        orders =Gcfs::Wrapper::Api::Hotel.process_order @customer_data
        orders.message.must_equal "room_id is missing"
      end
    end

  end

  describe 'as developer' do

    before do
      Gcfs::Wrapper::Api::configure do |config|
        config.key      = 'DQI5DqcwA2fuEARnciMWl5oHroU'
        config.secret   = 'vH6urcUIjh20aq4qLKQYXTLIUIw'
        config.username = 'windiana@giftcard.co.id'
        config.password = '12345678'
      end
      VCR.use_cassette('token/request_token/success_hotel') do
        @token = Gcfs::Wrapper::Api::Token.request
      end
    end

    it "search and list hotels" do
      VCR.use_cassette('hotel/developer/search/success') do
        startdates = "2012-07-21"
        enddates = "2012-07-22"
        options = {
                    :q => "legian", 
                    :startdate => startdates , 
                    :enddate => enddates, 
                    :night =>"1", 
                    :room => "1", 
                    :adult => "2", 
                    :child =>"0",
                    :metadata=> {:user=>{ :id=>1,:name=>'derri@giftcard.co.id'}}
                }


        hotels =Gcfs::Wrapper::Api::Hotel.search options
        hotels['results']['result'].count.must_equal 20
        hotels['diagnostic']['status'].must_equal 200
      end
    end

    it "raise error if :q parameter or :uid parameter missing" do
      VCR.use_cassette('hotel/developer/search/failed_q_or_uid_missing') do
        startdates = "2012-07-21"
        enddates = "2012-07-22"
        options = {
                    :startdate => startdates , 
                    :enddate => enddates, 
                    :night =>"1", 
                    :room => "1", 
                    :adult => "2", 
                    :child =>"0",
                    :metadata=> {:user=>{ :id=>1,:name=>'derri@giftcard.co.id'}}
                }


        hotels =Gcfs::Wrapper::Api::Hotel.search options
        hotels.message.must_equal "q, uid are missing, at least one parameter must be provided"
      end
    end

    it "retrieve list of city if use autocomplete with keyword city only" do
      VCR.use_cassette('hotel/developer/search_autocomplete/success') do
        startdates = "2012-07-21"
        enddates = "2012-07-22"
        options = {
                    :q => "Bali",
                    :startdate => startdates , 
                    :enddate => enddates, 
                    :night =>"1", 
                    :room => "1", 
                    :adult => "2", 
                    :child =>"0",
                    :metadata=> {:user=>{ :id=>1,:name=>'derri@giftcard.co.id'}}
                }


        hotels =Gcfs::Wrapper::Api::Hotel.search_autocomplete options
        hotels['results']['result'].count.must_equal 5
        hotels['results']['result'].first['tipe'].must_equal "business_id"
      end
    end

    it "retrieve area with valid parameter ex udi=city:178" do
      VCR.use_cassette('hotel/developer/search_area/success') do
        options = {
                    :uid => "city:178",
                    :metadata=> {:user=>{ :id=>1,:name=>'derri@giftcard.co.id'}}
                }


        area =Gcfs::Wrapper::Api::Hotel.search_area options
        area['results']['result'].count.must_equal 10
        area['results']['result'].sample['uid'].empty?.must_equal false
      end
    end

    it "return empty result array if invalid parameter" do
      VCR.use_cassette('hotel/developer/search_area/failed_invalid_par1') do
        options = {
                    :uid => "city:12178",
                    :metadata=> {:user=>{ :id=>1,:name=>'derri@giftcard.co.id'}}
                }


        area =Gcfs::Wrapper::Api::Hotel.search_area options
        area['results']['result'].count.must_equal 0
  
      end
    end

    it "retrieve detail of hotel, with parameter hotel_id ex:12453 legian-paradiso-hotel, with 4 rooms" do
      VCR.use_cassette('hotel/developer/view_detail/success') do
        options = {
                    :hotel_id => 12453,
                    :metadata=> {:user=>{ :id=>1,:name=>'derri@giftcard.co.id'}}
                }


        hotel_detail =Gcfs::Wrapper::Api::Hotel.view_detail options
        hotel_detail['results']['result'].sample['room_id'].empty?.must_equal false
        hotel_detail['results']['result'].count.must_equal 4
        # area['results']['result'].sample['uid'].empty?.must_equal false
      end
    end

    it "retrieve  , with invalid parameter ex:invalid hotel_id" do
      VCR.use_cassette('hotel/developer/view_detail/failed') do
        options = {
                    :hotel_id => 121111453,
                    :metadata=> {:user=>{ :id=>1,:name=>'derri@giftcard.co.id'}}
                }


        hotel_detail =Gcfs::Wrapper::Api::Hotel.view_detail options
        hotel_detail.message.must_equal "Hotel not found, please search other hotel"
        
      end
    end

    it "retrieve , when do process order with valid room_id" do
      VCR.use_cassette('hotel/developer/search/success') do
        VCR.use_cassette('hotel/developer/view_detail/success') do
          VCR.use_cassette('hotel/developer/process_order/success') do
            
            startdates = "2012-07-21"
            enddates = "2012-07-22"
            options = {
                        :q => "legian", 
                        :startdate => startdates , 
                        :enddate => enddates, 
                        :night =>"1", 
                        :room => "1", 
                        :adult => "2", 
                        :child =>"0",
                        :metadata=> {:user=>{ :id=>1,:name=>'derri@giftcard.co.id'}}
                    }


            hotels =Gcfs::Wrapper::Api::Hotel.search options
            hotel_id = hotels['results']['result'].first['hotel_id']

            options = {
                    :hotel_id => hotel_id,
                    :metadata=> {:user=>{ :id=>1,:name=>'derri@giftcard.co.id'}}
                }
            hotel_detail =Gcfs::Wrapper::Api::Hotel.view_detail options
            room_id = hotel_detail['results']['result'].first['room_id']

            @customer_data = {
                          :room_id => room_id,
                          :salutation => "Mr", 
                          :firstName => "Julian", 
                          :lastName => "Stephen", 
                          :phone => "08562969660", 
                          :conSalutation => "Mr", 
                          :conFirstName => "Julian", 
                          :conLastName => "Stephen", 
                          :conEmailAddress => "bima@giftcard.co.id", 
                          :conPhone => "08562969660", 
                          :country => "ID", 
                          :emailAddress => "bima@giftcard.co.id",
                          :recepient=> {:name=>'Bima',:email=>'bima@giftcard.co.id',:phone_number=>'08562969660'},
                          :metadata=> {:user=>{ :id=>1,:name=>'derri@giftcard.co.id'}}
                  }


            # orders =Gcfs::Wrapper::Api::Hotel.process_order @customer_data

          end
        end
      end
    end

    it "retrieve error message, when do process order with invalid room_id" do
      VCR.use_cassette('hotel/developer/process_order/invalid_room_id') do
        @customer_data = {
                      :room_id => @room_id,
                      :salutation => "Mr", 
                      :firstName => "Julian", 
                      :lastName => "Stephen", 
                      :phone => "08562969660", 
                      :conSalutation => "Mr", 
                      :conFirstName => "Julian", 
                      :conLastName => "Stephen", 
                      :conEmailAddress => "bima@giftcard.co.id", 
                      :conPhone => "08562969660", 
                      :country => "ID", 
                      :emailAddress => "bima@giftcard.co.id",
                      :recepient=> {:name=>'Bima',:email=>'bima@giftcard.co.id',:phone_number=>'08562969660'},
                      :metadata=> {:user=>{ :id=>1,:name=>'derri@giftcard.co.id'}}
              }


        orders =Gcfs::Wrapper::Api::Hotel.process_order @customer_data
        orders.message.must_equal "room_id is missing"
      end
    end


  end
  
end