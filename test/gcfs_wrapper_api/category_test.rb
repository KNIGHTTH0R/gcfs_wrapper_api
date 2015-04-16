require 'helper'

describe 'category' do

  describe 'as administrator' do

    before do
      Gcfs::Wrapper::Api::configure do |config|
        config.key      = 'APIKEY'
        config.secret   = 'APISECRET'
        config.username = 'admin@gcfs.co.id'
        config.password = '12345678'
      end
      VCR.use_cassette('token/request_token/success') do
        @token = Gcfs::Wrapper::Api::Token.request
      end
    end

    it "list of categories" do
      VCR.use_cassette('category/administrator/list/all/success') do
        categories = Gcfs::Wrapper::Api::Category.all
        
        categories.size.must_equal 7
        categories.total_count.must_equal 7
        categories.current_page.must_equal 1
        VCR.use_cassette('category/administrator/show/1/success') do
          categories.first.as_hash.must_equal Gcfs::Wrapper::Api::Category.find(1).as_hash
        end
        categories.first.class.must_equal Gcfs::Wrapper::Api::Category
        assert categories.first.kind_of?(Gcfs::Wrapper::Api::Category)

        categories.first.id.must_equal 1
        categories.first.name.must_equal 'Giftcard'
      end
    end

    it 'raise errors if token invalid' do
      VCR.use_cassette('category/administrator/list/all/token_invalid') do
        Gcfs::Wrapper::Api.access_token = '1234567890ASDFGHJKLMNBVCX'

        categories = Gcfs::Wrapper::Api::Category.all
        
        categories.class.must_equal Gcfs::Wrapper::Api::Error
        assert categories.kind_of?(Gcfs::Wrapper::Api::Error)

        categories.message.must_equal 'invalid_request'
      end
    end

    it 'create category' do
      VCR.use_cassette('category/administrator/create/success') do
        category = Gcfs::Wrapper::Api::Category.create name: 'Resto'

        VCR.use_cassette('category/administrator/create/success/all') do
          categories = Gcfs::Wrapper::Api::Category.all

          categories.size.must_equal 8
          categories.total_count.must_equal 8

          category.id.must_equal categories.last.id
          category.name.must_equal categories.last.name
        end
      end
    end

    it 'raise errors if params not filled when create category' do
      VCR.use_cassette('category/administrator/create/failed') do
        category = Gcfs::Wrapper::Api::Category.create

        category.class.must_equal Gcfs::Wrapper::Api::Error
        assert category.kind_of?(Gcfs::Wrapper::Api::Error)

        category.message.must_equal 'name is missing'
      end
    end

    it 'edit category' do
      VCR.use_cassette('category/administrator/update/success') do
        category = Gcfs::Wrapper::Api::Category.update 8, name: 'Restaurant'

        VCR.use_cassette('category/administrator/update/success/all') do
          categories = Gcfs::Wrapper::Api::Category.all

          categories.size.must_equal 8
          categories.total_count.must_equal 8

          category.id.must_equal categories.last.id
          category.name.must_equal categories.last.name
          category.name.must_equal 'Restaurant'
        end
      end
    end

    it 'raise errors if params not filled when edit category' do
      VCR.use_cassette('category/administrator/show/1/success') do
        category = Gcfs::Wrapper::Api::Category.find(1)

        VCR.use_cassette('category/administrator/update/failed') do
          category = Gcfs::Wrapper::Api::Category.update 1

          category.class.must_equal Gcfs::Wrapper::Api::Error
          assert category.kind_of?(Gcfs::Wrapper::Api::Error)

          category.message.must_equal 'name is missing'
        end
      end
    end

    it 'delete category' do
      VCR.use_cassette('category/administrator/update/success/all') do
        before_destroy_categories = Gcfs::Wrapper::Api::Category.all
        before_destroy_categories.size.must_equal 8
        before_destroy_categories.total_count.must_equal 8

        VCR.use_cassette('category/administrator/destroy/success') do
          category = Gcfs::Wrapper::Api::Category.destroy 8

          category.id.must_equal before_destroy_categories.last.id
          category.name.must_equal before_destroy_categories.last.name
          category.name.must_equal 'Restaurant'

          VCR.use_cassette('category/administrator/destroy/success/all') do
            categories = Gcfs::Wrapper::Api::Category.all
            categories.size.must_equal 7
            categories.total_count.must_equal 7

            categories.size.must_equal (before_destroy_categories.size - 1)
          end
        end
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

    it "list of categories" do
      VCR.use_cassette('category/developer/list/all/success') do
        categories = Gcfs::Wrapper::Api::Category.all

        categories.size.must_equal 3
        categories.total_count.must_equal 3
        categories.current_page.must_equal 1
        VCR.use_cassette('category/developer/show/1/success') do
          categories.first.as_hash.must_equal Gcfs::Wrapper::Api::Category.find(1).as_hash
        end
        categories.first.class.must_equal Gcfs::Wrapper::Api::Category
        assert categories.first.kind_of?(Gcfs::Wrapper::Api::Category)

        categories.first.id.must_equal 1
        categories.first.name.must_equal 'Giftcard'
      end
    end

    it 'raise errors if token invalid' do
      VCR.use_cassette('category/developer/list/all/token_invalid') do
        Gcfs::Wrapper::Api.access_token = '1234567890ASDFGHJKLMNBVCX'

        categories = Gcfs::Wrapper::Api::Category.all
        
        categories.class.must_equal Gcfs::Wrapper::Api::Error
        assert categories.kind_of?(Gcfs::Wrapper::Api::Error)

        categories.message.must_equal 'invalid_request'
      end
    end

    it 'raise errors when create category' do
      VCR.use_cassette('category/developer/create/failed') do
        category = Gcfs::Wrapper::Api::Category.create name: 'Resto'

        category.class.must_equal Gcfs::Wrapper::Api::Error
        assert category.kind_of?(Gcfs::Wrapper::Api::Error)

        category.message.must_equal 'invalid_request'
      end
    end

    it 'raise errors if params not filled when create category' do
      VCR.use_cassette('category/developer/create/failed_params_not_filled') do
        category = Gcfs::Wrapper::Api::Category.create

        category.class.must_equal Gcfs::Wrapper::Api::Error
        assert category.kind_of?(Gcfs::Wrapper::Api::Error)

        category.message.must_equal 'invalid_request'
      end
    end

    it 'raise errors when edit category' do
      VCR.use_cassette('category/developer/update/failed') do
        category = Gcfs::Wrapper::Api::Category.update 1, name: 'Restaurant'

        category.class.must_equal Gcfs::Wrapper::Api::Error
        assert category.kind_of?(Gcfs::Wrapper::Api::Error)

        category.message.must_equal 'invalid_request'
      end
    end

    it 'raise errors if params not filled when edit category' do
      VCR.use_cassette('category/developer/update/failed_params_not_filled') do
        category = Gcfs::Wrapper::Api::Category.update 1, name: 'Restaurant'

        category.class.must_equal Gcfs::Wrapper::Api::Error
        assert category.kind_of?(Gcfs::Wrapper::Api::Error)

        category.message.must_equal 'invalid_request'
      end
    end

    it 'delete category' do
      VCR.use_cassette('category/developer/list/all/success') do
        before_destroy_categories = Gcfs::Wrapper::Api::Category.all

        before_destroy_categories.size.must_equal 3
        before_destroy_categories.total_count.must_equal 3

        VCR.use_cassette('category/developer/destroy/failed') do
          category = Gcfs::Wrapper::Api::Category.destroy before_destroy_categories.last.id

          category.class.must_equal Gcfs::Wrapper::Api::Error
          assert category.kind_of?(Gcfs::Wrapper::Api::Error)

          category.message.must_equal 'invalid_request'

          VCR.use_cassette('category/developer/destroy/failed/all') do
            categories = Gcfs::Wrapper::Api::Category.all
            categories.size.must_equal 3
            categories.total_count.must_equal 3

            categories.size.must_equal before_destroy_categories.size
          end
        end
      end
    end

  end

end