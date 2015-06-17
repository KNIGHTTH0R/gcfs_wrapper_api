require 'helper'

describe 'dtcell' do

  describe 'as administrator' do

    before do
      Gcfs::Wrapper::Api::configure do |config|
        config.key      = 'DQI5DqcwA2fuEARnciMWl5oHroU'
        config.secret   = 'vH6urcUIjh20aq4qLKQYXTLIUIw'
        config.username = 'derri@giftcard.co.id'
        config.password = '12345678'
      end
      VCR.use_cassette('token/request_token/success2') do
        @token = Gcfs::Wrapper::Api::Token.request
      end
    end

    it "list of dtcells" do
      VCR.use_cassette('dtcell/administrator/list/all/success') do
        products = Gcfs::Wrapper::Api::Dtcell.all 
        
        products.size.must_equal 20
        products.total_count.must_equal 79
        products.total_pages.must_equal 4
        products.current_page.must_equal 1

        VCR.use_cassette('dtcell/administrator/show/'+products.first.id.to_s+'/success') do
          products.first.as_hash.must_equal Gcfs::Wrapper::Api::Dtcell.find(products.first.id).as_hash
        end
        
        products.first.class.must_equal Gcfs::Wrapper::Api::Dtcell
        assert products.first.kind_of?(Gcfs::Wrapper::Api::Dtcell)

        products.first.id.must_equal 1
        products.first.operator.must_equal 'INDOSAT'
        products.first.operator_code.must_equal 'IR.10'
        products.first.description.must_equal 'Indosat Reguler 10000'
        products.first.nominal.must_equal 0
        products.first.price.must_equal 0
      end
    end

    it 'raise errors if token invalid' do
      VCR.use_cassette('dtcell/administrator/list/all/token_invalid') do
        Gcfs::Wrapper::Api.access_token = '1234567890ASDFGHJKLMNBVCX'

        products = Gcfs::Wrapper::Api::Dtcell.all
        
        products.class.must_equal Gcfs::Wrapper::Api::Error
        assert products.kind_of?(Gcfs::Wrapper::Api::Error)

        products.message.must_equal 'invalid_request'
      end
    end

    it 'create dtcell' do
      VCR.use_cassette('dtcell/administrator/list/all/success') do
        before_dtcells = Gcfs::Wrapper::Api::Dtcell.all

        VCR.use_cassette('dtcell/administrator/create/success') do
          params = {
            "operator": "Indosat",
            "operator_code": "IR.500",
            "description": "Pulsa Telkomsel 500,000",
            "nominal": 500000,
            "price": 500000
          }
          dtcell = Gcfs::Wrapper::Api::Dtcell.create params

          VCR.use_cassette('dtcell/administrator/create/success/all') do
            dtcells = Gcfs::Wrapper::Api::Dtcell.all page: 4

            dtcells.size.must_equal 20
            dtcells.total_count.must_equal 80
            dtcells.total_pages.must_equal 4
            dtcells.current_page.must_equal 4

            dtcells.total_count.must_equal (before_dtcells.total_count + 1)

            dtcell.id.must_equal dtcells.last.id
            dtcell.operator.must_equal dtcells.last.operator
            dtcell.operator_code.must_equal dtcells.last.operator_code
            dtcell.description.must_equal dtcells.last.description
            dtcell.nominal.must_equal dtcells.last.nominal
            dtcell.price.must_equal dtcells.last.price
            dtcell.class.must_equal Gcfs::Wrapper::Api::Dtcell
            assert dtcell.kind_of?(Gcfs::Wrapper::Api::Dtcell)

            dtcell.id.must_equal 95
            dtcell.operator.must_equal "Indosat"
            dtcell.operator_code.must_equal "IR.500"
            dtcell.description.must_equal "Pulsa Telkomsel 500,000"
            dtcell.nominal.must_equal 500000
            dtcell.price.must_equal 500000
          end
        end

      end
    end

    it 'raise errors if params not filled when create dtcell' do
      VCR.use_cassette('dtcell/administrator/create/success/all') do
        before_dtcells = Gcfs::Wrapper::Api::Dtcell.all force: true, page: 4

          VCR.use_cassette('dtcell/administrator/create/params_not_filled') do
            dtcell = Gcfs::Wrapper::Api::Dtcell.create 

            dtcell.message.must_include('operator is missing')
            dtcell.message.must_include('operator_code is missing')
            dtcell.message.must_include('nominal is missing')
            dtcell.message.must_include('price is missing')

            VCR.use_cassette('dtcell/administrator/create/failed/all') do
              dtcells = Gcfs::Wrapper::Api::Dtcell.all page: 4

              dtcells.size.must_equal 20
              dtcells.total_count.must_equal 80
              dtcells.total_pages.must_equal 4
              dtcells.current_page.must_equal 4

              dtcells.total_count.must_equal before_dtcells.total_count
            end
          end

      end
    end

    it 'edit dtcell' do
      VCR.use_cassette('dtcell/administrator/create/success/all') do
        before_dtcells = Gcfs::Wrapper::Api::Dtcell.all force: true, page: 4
        VCR.use_cassette('dtcell/administrator/update/success') do
          dtcell = Gcfs::Wrapper::Api::Dtcell.update before_dtcells.last.id, operator: 'Telkomsel', operator_code: "TEL.1", description: "Telsomsel 1,000", nominal: 1000, price: 1200

          VCR.use_cassette('dtcell/administrator/update/success/all') do
            dtcells = Gcfs::Wrapper::Api::Dtcell.all page: 4

            dtcell.id.must_equal dtcells.last.id
            dtcell.operator.must_equal dtcells.last.operator
            dtcell.operator_code.must_equal dtcells.last.operator_code
            dtcell.description.must_equal dtcells.last.description
            dtcell.nominal.must_equal dtcells.last.nominal
            dtcell.price.must_equal dtcells.last.price
            dtcell.class.must_equal Gcfs::Wrapper::Api::Dtcell
            assert dtcell.kind_of?(Gcfs::Wrapper::Api::Dtcell)

            dtcells.size.must_equal 20
            dtcells.total_count.must_equal 80
            dtcells.total_pages.must_equal 4
            dtcells.current_page.must_equal 4

            dtcells.total_count.must_equal before_dtcells.total_count
          end
        end
      end
    end

    it 'edit dtcell with params only operator' do
      VCR.use_cassette('dtcell/administrator/update/success/all') do
        before_dtcells = Gcfs::Wrapper::Api::Dtcell.all page: 4

        VCR.use_cassette('dtcell/administrator/update/operator/success') do
          dtcell = Gcfs::Wrapper::Api::Dtcell.update before_dtcells.last.id, operator: 'XL', operator_code: "TEL.1", description: "Telsomsel 1,000", nominal: 1000, price: 1200

          VCR.use_cassette('dtcell/administrator/update/operator/success/all') do
            dtcells = Gcfs::Wrapper::Api::Dtcell.all page: 4
            dtcell.id.must_equal dtcells.last.id
            dtcell.operator.must_equal dtcells.last.operator
            dtcell.operator_code.must_equal dtcells.last.operator_code
            dtcell.description.must_equal dtcells.last.description
            dtcell.nominal.must_equal dtcells.last.nominal
            dtcell.price.must_equal dtcells.last.price
          end
        end
      end
    end

    it 'edit dtcell with params only operator code' do
      VCR.use_cassette('dtcell/administrator/update/success/all') do
        before_dtcells = Gcfs::Wrapper::Api::Dtcell.all page: 4

        VCR.use_cassette('dtcell/administrator/update/operator_code/success') do
          dtcell = Gcfs::Wrapper::Api::Dtcell.update before_dtcells.last.id, operator: 'Telkomsel', operator_code: "TEL.1K", description: "Telsomsel 1,000", nominal: 1000, price: 1200

          VCR.use_cassette('dtcell/administrator/update/operator_code/success/all') do
            dtcells = Gcfs::Wrapper::Api::Dtcell.all page: 4
            dtcell.id.must_equal dtcells.last.id
            dtcell.operator.must_equal dtcells.last.operator
            dtcell.operator_code.must_equal dtcells.last.operator_code
            dtcell.description.must_equal dtcells.last.description
            dtcell.nominal.must_equal dtcells.last.nominal
            dtcell.price.must_equal dtcells.last.price
          end
        end
      end
    end

    it 'edit dtcell with params only nominal' do
      VCR.use_cassette('dtcell/administrator/update/success/all') do
        before_dtcells = Gcfs::Wrapper::Api::Dtcell.all page: 4

        VCR.use_cassette('dtcell/administrator/update/nominal/success') do
          dtcell = Gcfs::Wrapper::Api::Dtcell.update before_dtcells.last.id, operator: 'Telkomsel', operator_code: "TEL.1", description: "Telsomsel 1,000", nominal: 1500, price: 1200

          VCR.use_cassette('dtcell/administrator/update/nominal/success/all') do
            dtcells = Gcfs::Wrapper::Api::Dtcell.all page: 4
            dtcell.id.must_equal dtcells.last.id
            dtcell.operator.must_equal dtcells.last.operator
            dtcell.operator_code.must_equal dtcells.last.operator_code
            dtcell.description.must_equal dtcells.last.description
            dtcell.nominal.must_equal dtcells.last.nominal
            dtcell.price.must_equal dtcells.last.price
          end
        end
      end
    end

    it 'edit dtcell with params only price' do
      VCR.use_cassette('dtcell/administrator/update/success/all') do
        before_dtcells = Gcfs::Wrapper::Api::Dtcell.all page: 4

        VCR.use_cassette('dtcell/administrator/update/price/success') do
          dtcell = Gcfs::Wrapper::Api::Dtcell.update before_dtcells.last.id, operator: 'Telkomsel', operator_code: "TEL.1", description: "Telsomsel 1,000", nominal: 1000, price: 1500

          VCR.use_cassette('dtcell/administrator/update/price/success/all') do
            dtcells = Gcfs::Wrapper::Api::Dtcell.all page: 4
            dtcell.id.must_equal dtcells.last.id
            dtcell.operator.must_equal dtcells.last.operator
            dtcell.operator_code.must_equal dtcells.last.operator_code
            dtcell.description.must_equal dtcells.last.description
            dtcell.nominal.must_equal dtcells.last.nominal
            dtcell.price.must_equal dtcells.last.price
          end
        end
      end
    end

    it 'raise errors if params not filled when edit dtcell' do
      VCR.use_cassette('dtcell/administrator/update/price/success/all') do
        before_dtcells = Gcfs::Wrapper::Api::Dtcell.all force: true, page: 4

          VCR.use_cassette('dtcell/administrator/update/params_not_filled') do
            dtcell = Gcfs::Wrapper::Api::Dtcell.update before_dtcells.last.id

            dtcell.message.must_include('operator is missing, operator_code is missing, nominal is missing, price is missing')
            VCR.use_cassette('dtcell/administrator/update/failed/all') do
              dtcells = Gcfs::Wrapper::Api::Dtcell.all page: 4

              dtcells.size.must_equal 20
              dtcells.total_count.must_equal 80
              dtcells.total_pages.must_equal 4
              dtcells.current_page.must_equal 4

              dtcells.total_count.must_equal before_dtcells.total_count
            end
          end
      end
    end

    it 'show dtcell' do
      VCR.use_cassette('dtcell/administrator/update/price/success/all') do
        dtcells = Gcfs::Wrapper::Api::Dtcell.all page: 4

        VCR.use_cassette('dtcell/administrator/show/'+dtcells.last.id.to_s+'/success') do
          dtcell = Gcfs::Wrapper::Api::Dtcell.find(dtcells.last.id)
          dtcells.last.as_hash.must_equal dtcell.as_hash

          dtcell.id.must_equal dtcells.last.id
          dtcell.operator.must_equal "Telkomsel"
          dtcell.operator_code.must_equal "TEL.1"
          dtcell.description.must_equal dtcells.last.description
          dtcell.nominal.must_equal dtcells.last.nominal
          dtcell.price.must_equal dtcells.last.price
        end

      end
    end

    it "raise errors if dtcell id doesn't valid when show dtcell" do
      VCR.use_cassette('dtcell/administrator/update/price/success/all') do
        dtcells = Gcfs::Wrapper::Api::Dtcell.all page: 4

        VCR.use_cassette('dtcell/administrator/show/'+(dtcells.last.id + 1).to_s+'/failed') do
          dtcell = Gcfs::Wrapper::Api::Dtcell.find(dtcells.last.id + 1)

          dtcell.message.must_include('Product doesn\'t Exist')
        end

      end
    end

    it 'delete dtcell' do
      VCR.use_cassette('dtcell/administrator/update/price/success/all') do
        before_dtcells = Gcfs::Wrapper::Api::Dtcell.all page: 4

        VCR.use_cassette('dtcell/administrator/destroy/success') do
          dtcell = Gcfs::Wrapper::Api::Dtcell.destroy before_dtcells.last.id

          VCR.use_cassette('dtcell/administrator/destroy/success/all') do
            dtcells = Gcfs::Wrapper::Api::Dtcell.all page: 4


            dtcell.id.must_equal before_dtcells.last.id
            dtcell.operator.must_equal "Telkomsel"
            dtcell.operator_code.must_equal "TEL.1"
            dtcell.description.must_equal before_dtcells.last.description
            dtcell.nominal.must_equal before_dtcells.last.nominal
            dtcell.price.must_equal before_dtcells.last.price

            dtcells.size.must_equal 19
            dtcells.total_count.must_equal 79
            dtcells.total_pages.must_equal 4
            dtcells.current_page.must_equal 4

            dtcells.total_count.must_equal (before_dtcells.total_count - 1)
          end
        end
      end
    end

    it "raise errors if dtcell id doesn't valid when delete dtcell" do
      VCR.use_cassette('dtcell/administrator/destroy/success/all') do
        before_dtcells = Gcfs::Wrapper::Api::Dtcell.all page: 4

        VCR.use_cassette('dtcell/administrator/destroy/failed') do
          dtcell = Gcfs::Wrapper::Api::Dtcell.destroy (before_dtcells.last.id + 1)

          dtcell.message.must_include('Product doesn\'t Exist')

          VCR.use_cassette('dtcell/administrator/destroy/success/failed') do
            dtcells = Gcfs::Wrapper::Api::Dtcell.all force: true, page: 4
            dtcells.size.must_equal 19
            dtcells.total_count.must_equal 79
            dtcells.total_pages.must_equal 4
            dtcells.current_page.must_equal 4

            dtcells.total_count.must_equal before_dtcells.total_count
          end
        end
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
      VCR.use_cassette('token/request_token/developer/success2') do
        @token = Gcfs::Wrapper::Api::Token.request
      end
    end

    it "list of dtcells" do
      VCR.use_cassette('dtcell/developer/list/all/success') do
        dtcells = Gcfs::Wrapper::Api::Dtcell.all

          dtcells.size.must_equal 20
          dtcells.total_count.must_equal 79
          dtcells.total_pages.must_equal 4
          dtcells.current_page.must_equal 1

        VCR.use_cassette('dtcell/developer/show/'+dtcells.last.id.to_s+'/success') do
          dtcells.last.as_hash.must_equal Gcfs::Wrapper::Api::Dtcell.find(dtcells.last.id).as_hash
        end
        dtcells.last.class.must_equal Gcfs::Wrapper::Api::Dtcell
        assert dtcells.last.kind_of?(Gcfs::Wrapper::Api::Dtcell)

        dtcells.last.id.must_equal 21
        dtcells.last.operator.must_equal 'XL'
        dtcells.last.operator_code.must_equal 'XL.10'
        dtcells.last.description.must_equal 'XL Bebas 10000'
        dtcells.last.nominal.must_equal 0
        dtcells.last.price.must_equal 0
      end
    end

    it 'raise errors if token invalid' do
      VCR.use_cassette('dtcell/developer/list/all/token_invalid') do
        Gcfs::Wrapper::Api.access_token = '1234567890ASDFGHJKLMNBVCX'

        dtcells = Gcfs::Wrapper::Api::Dtcell.all
        
        dtcells.class.must_equal Gcfs::Wrapper::Api::Error
        assert dtcells.kind_of?(Gcfs::Wrapper::Api::Error)

        dtcells.message.must_equal 'invalid_request'
      end
    end

    it 'raise errors when create dtcell' do
      VCR.use_cassette('dtcell/developer/create/failed') do
        dtcell = Gcfs::Wrapper::Api::Dtcell.create operator: 'Telkomsel', operator_code: "TEL.1", description: "Telsomsel 1,000", nominal: 1000, price: 1500

        dtcell.class.must_equal Gcfs::Wrapper::Api::Error
        assert dtcell.kind_of?(Gcfs::Wrapper::Api::Error)

        dtcell.message.must_equal 'invalid_request'
      end
    end

    it 'raise errors when edit dtcell' do
      VCR.use_cassette('dtcell/developer/list/all/success') do
        dtcells = Gcfs::Wrapper::Api::Dtcell.all

        VCR.use_cassette('dtcell/developer/update/failed') do
          dtcell = Gcfs::Wrapper::Api::Dtcell.update dtcells.last.id, operator: 'XL'

          dtcell.class.must_equal Gcfs::Wrapper::Api::Error
          assert dtcell.kind_of?(Gcfs::Wrapper::Api::Error)

          dtcell.message.must_equal 'invalid_request'
        end
      end
    end

    it 'show dtcell' do
      VCR.use_cassette('dtcell/developer/list/all/success') do
        dtcells = Gcfs::Wrapper::Api::Dtcell.all
        VCR.use_cassette('dtcell/developer/show/'+dtcells.last.id.to_s+'/success') do
          dtcell = Gcfs::Wrapper::Api::Dtcell.find(dtcells.last.id)
          dtcells.last.as_hash.must_equal dtcell.as_hash

          dtcells.last.id.must_equal 21
          dtcells.last.operator.must_equal 'XL'
          dtcells.last.operator_code.must_equal 'XL.10'
          dtcells.last.description.must_equal 'XL Bebas 10000'
          dtcells.last.nominal.must_equal 0
          dtcells.last.price.must_equal 0
        end
      end
    end

    it 'raise errors when delete dtcell' do
      VCR.use_cassette('dtcell/developer/list/all/success') do
        dtcells = Gcfs::Wrapper::Api::Dtcell.all

        VCR.use_cassette('dtcell/developer/destroy/failed') do
          dtcell = Gcfs::Wrapper::Api::Dtcell.destroy dtcells.last.id

          dtcell.class.must_equal Gcfs::Wrapper::Api::Error
          assert dtcell.kind_of?(Gcfs::Wrapper::Api::Error)

          dtcell.message.must_equal 'invalid_request'
        end
      end
    end
  end
end