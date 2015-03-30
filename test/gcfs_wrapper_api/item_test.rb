require 'helper'

describe 'item' do

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

    it "list of items" do
      VCR.use_cassette('item/administrator/list/all/success') do
        items = Gcfs::Wrapper::Api::Item.all force: true
        
        items.size.must_equal 20
        items.total_count.must_equal 22
        items.total_pages.must_equal 2
        items.current_page.must_equal 1
        VCR.use_cassette('item/administrator/show/'+items.first.id.to_s+'/success') do
          items.first.as_hash.must_equal Gcfs::Wrapper::Api::Item.find(items.first.id).as_hash
        end
        items.first.class.must_equal Gcfs::Wrapper::Api::Item
        assert items.first.kind_of?(Gcfs::Wrapper::Api::Item)

        items.first.id.must_equal 1
        items.first.sku.must_equal '0101'
        items.first.name.must_equal 'Job'
        items.first.category.must_equal 'Giftcard'

        items.each do |item|
          item.variants.each do |variant|
            VCR.use_cassette('item_variant/administrator/show/'+variant.id.to_s+'/success') do
              variant.as_hash.must_equal Gcfs::Wrapper::Api::ItemVariant.find(item.id, variant.id).as_hash
            end
          end
        end
      end
    end

    it 'raise errors if token invalid' do
      VCR.use_cassette('item/administrator/list/all/token_invalid') do
        Gcfs::Wrapper::Api.access_token = '1234567890ASDFGHJKLMNBVCX'

        items = Gcfs::Wrapper::Api::Item.all
        
        items.class.must_equal Gcfs::Wrapper::Api::Error
        assert items.kind_of?(Gcfs::Wrapper::Api::Error)

        items.message.must_equal 'invalid_request'
      end
    end

    it 'create item' do
      VCR.use_cassette('item/administrator/list/all/success') do
        before_items = Gcfs::Wrapper::Api::Item.all force: true

        VCR.use_cassette('category/administrator/list/all/success') do
          categories = Gcfs::Wrapper::Api::Category.all

          VCR.use_cassette('item/administrator/create/success') do
            item = Gcfs::Wrapper::Api::Item.create name: "Voucher A", category: categories.first.name, image: File.open(File.join(Rails.root, 'app', 'assets', 'images', 'rails.png')), variants: [{ description: "Voucher nominal 50rb", nominal: 50000, price: 45000 }]

            VCR.use_cassette('item/administrator/create/success/all') do
              items = Gcfs::Wrapper::Api::Item.all force: true, page: 2

              items.size.must_equal 3
              items.total_count.must_equal 23
              items.total_pages.must_equal 2
              items.current_page.must_equal 2

              items.total_count.must_equal (before_items.total_count + 1)

              item.id.must_equal items.last.id
              item.sku.must_equal items.last.sku
              item.name.must_equal items.last.name
              item.category.must_equal items.last.category
              item.category.must_equal categories.first.name
              item.as_hash.must_equal items.last.as_hash
              item.class.must_equal Gcfs::Wrapper::Api::Item
              assert item.kind_of?(Gcfs::Wrapper::Api::Item)

              item.id.must_equal 29
              item.sku.must_equal '0129'
              item.name.must_equal 'Voucher A'
              item.category.must_equal categories.first.name
              item.as_hash.must_equal items.last.as_hash
              
              item.variants.first.class.must_equal Gcfs::Wrapper::Api::ItemVariant
              assert item.variants.first.kind_of?(Gcfs::Wrapper::Api::ItemVariant)
              item.variants.first.id.must_equal 63
              item.variants.first.sku.must_equal '012963'
              item.variants.first.description.must_equal 'Voucher nominal 50rb'
              item.variants.first.nominal.must_equal 50000
              item.variants.first.price.must_equal 45000
            end
          end

        end

      end
    end

    it 'raise errors if params not filled when create item' do
      VCR.use_cassette('item/administrator/create/success/all') do
        before_items = Gcfs::Wrapper::Api::Item.all force: true, page: 2

        VCR.use_cassette('category/administrator/list/all/success') do
          categories = Gcfs::Wrapper::Api::Category.all

          VCR.use_cassette('item/administrator/create/failed_params_not_filled') do
            item = Gcfs::Wrapper::Api::Item.create 

            item.message.must_include('name is missing')
            item.message.must_include('category is missing')
            item.message.must_include('category does not have a valid value')
            item.message.must_include('image is missing')
            item.message.must_include('variants is missing')

            VCR.use_cassette('item/administrator/create/failed/all') do
              items = Gcfs::Wrapper::Api::Item.all force: true, page: 2

              items.size.must_equal 3
              items.total_count.must_equal 23
              items.total_pages.must_equal 2
              items.current_page.must_equal 2

              items.total_count.must_equal before_items.total_count
            end
          end

        end

      end
    end

    it 'edit item' do
      VCR.use_cassette('item/administrator/create/success/all') do
        before_items = Gcfs::Wrapper::Api::Item.all force: true, page: 2

        VCR.use_cassette('category/administrator/list/all/success') do
          categories = Gcfs::Wrapper::Api::Category.all

          VCR.use_cassette('item/administrator/update/success') do
            item = Gcfs::Wrapper::Api::Item.update before_items.last.id, name: 'Voucher B', category: categories.last.name, image: File.open(File.join(Rails.root, 'app', 'assets', 'images', 'rails.png'))

            VCR.use_cassette('item/administrator/update/success/all') do
              items = Gcfs::Wrapper::Api::Item.all force: true, page: 2

              item.id.must_equal items.last.id
              item.name.must_equal items.last.name
              item.name.must_equal 'Voucher B'
              item.category.must_equal categories.last.name

              VCR.use_cassette('item/administrator/update/success/image') do
                uri = URI.parse(File.join(Gcfs::Wrapper::Api::Item.base_uri, item.image))
                response = Net::HTTP.get_response(uri)

                tempfile = Tempfile.new("fileupload")
                tempfile.binmode
                tempfile.write(response.body)
                tempfile.rewind

                image = Tempfile.new("fileupload")
                image.binmode
                image.write(File.open(File.join(Rails.root, 'app', 'assets', 'images', 'rails.png')).read)
                image.rewind

                tempfile.read.must_equal image.read
              end

              items.size.must_equal 3
              items.total_count.must_equal 23
              items.total_pages.must_equal 2
              items.current_page.must_equal 2

              items.total_count.must_equal before_items.total_count
            end
          end

        end

      end
    end

    it 'edit item with params only name' do
      VCR.use_cassette('item/administrator/update/success/all') do
        before_items = Gcfs::Wrapper::Api::Item.all force: true, page: 2

        VCR.use_cassette('category/administrator/list/all/success') do
          categories = Gcfs::Wrapper::Api::Category.all

          VCR.use_cassette('item/administrator/update/name/success') do
            item = Gcfs::Wrapper::Api::Item.update before_items.last.id, name: 'Voucher C'

            VCR.use_cassette('item/administrator/update/name/success/all') do
              items = Gcfs::Wrapper::Api::Item.all force: true, page: 2

              item.id.must_equal items.last.id
              item.name.must_equal items.last.name
              item.name.must_equal 'Voucher C'
              item.category.must_equal categories.last.name

            end
          end

        end

      end
    end

    it 'edit item with params only category' do
      VCR.use_cassette('item/administrator/update/name/success/all') do
        before_items = Gcfs::Wrapper::Api::Item.all force: true, page: 2

        VCR.use_cassette('category/administrator/list/all/success') do
          categories = Gcfs::Wrapper::Api::Category.all

          VCR.use_cassette('item/administrator/update/category/success') do
            item = Gcfs::Wrapper::Api::Item.update before_items.last.id, category: categories.third.name

            VCR.use_cassette('item/administrator/update/category/success/all') do
              items = Gcfs::Wrapper::Api::Item.all force: true, page: 2

              item.id.must_equal items.last.id
              item.name.must_equal items.last.name
              item.name.must_equal 'Voucher C'
              item.category.must_equal categories.third.name

            end
          end

        end

      end
    end

    it 'edit item with params only image' do
      VCR.use_cassette('item/administrator/update/category/success/all') do
        before_items = Gcfs::Wrapper::Api::Item.all force: true, page: 2

        VCR.use_cassette('category/administrator/list/all/success') do
          categories = Gcfs::Wrapper::Api::Category.all

          VCR.use_cassette('item/administrator/update/image/success') do
            item = Gcfs::Wrapper::Api::Item.update before_items.last.id, image: File.open(File.join(Rails.root, 'app', 'assets', 'images', 'rails.png'))

            VCR.use_cassette('item/administrator/update/image/success/all') do
              items = Gcfs::Wrapper::Api::Item.all force: true, page: 2

              item.id.must_equal items.last.id
              item.name.must_equal items.last.name
              item.name.must_equal 'Voucher C'
              item.category.must_equal categories.third.name

              VCR.use_cassette('item/administrator/update/image/success/image') do
                uri = URI.parse(File.join(Gcfs::Wrapper::Api::Item.base_uri, item.image))
                response = Net::HTTP.get_response(uri)

                tempfile = Tempfile.new("fileupload")
                tempfile.binmode
                tempfile.write(response.body)
                tempfile.rewind

                image = Tempfile.new("fileupload")
                image.binmode
                image.write(File.open(File.join(Rails.root, 'app', 'assets', 'images', 'rails.png')).read)
                image.rewind

                tempfile.read.must_equal image.read
              end

            end
          end

        end

      end
    end

    it 'raise errors if params not filled when edit item' do
      VCR.use_cassette('item/administrator/update/image/success/all') do
        before_items = Gcfs::Wrapper::Api::Item.all force: true, page: 2

        VCR.use_cassette('category/administrator/list/all/success') do
          categories = Gcfs::Wrapper::Api::Category.all

          VCR.use_cassette('item/administrator/update/failed_params_not_filled') do
            item = Gcfs::Wrapper::Api::Item.update before_items.last.id

            item.message.must_include('name, category, image are missing')
            item.message.must_include('at least one parameter must be provided')

            VCR.use_cassette('item/administrator/update/failed/all') do
              items = Gcfs::Wrapper::Api::Item.all force: true, page: 2

              items.size.must_equal 3
              items.total_count.must_equal 23
              items.total_pages.must_equal 2
              items.current_page.must_equal 2

              items.total_count.must_equal before_items.total_count
            end
          end

        end

      end
    end

    it 'show item' do
      VCR.use_cassette('item/administrator/update/image/success/all') do
        items = Gcfs::Wrapper::Api::Item.all force: true, page: 2

        VCR.use_cassette('category/administrator/list/all/success') do
          categories = Gcfs::Wrapper::Api::Category.all

          VCR.use_cassette('item/administrator/show/'+items.last.id.to_s+'/success') do
            item = Gcfs::Wrapper::Api::Item.find(items.last.id)
            items.last.as_hash.must_equal item.as_hash

            item.id.must_equal items.last.id
            item.name.must_equal items.last.name
            item.name.must_equal 'Voucher C'
            item.category.must_equal categories.third.name

            VCR.use_cassette('item/administrator/update/image/success/image') do
              uri = URI.parse(File.join(Gcfs::Wrapper::Api::Item.base_uri, item.image))
              response = Net::HTTP.get_response(uri)

              tempfile = Tempfile.new("fileupload")
              tempfile.binmode
              tempfile.write(response.body)
              tempfile.rewind

              image = Tempfile.new("fileupload")
              image.binmode
              image.write(File.open(File.join(Rails.root, 'app', 'assets', 'images', 'rails.png')).read)
              image.rewind

              tempfile.read.must_equal image.read
            end

          end

        end
      end
    end

    it "raise errors if item id doesn't valid when show item" do
      VCR.use_cassette('item/administrator/update/image/success/all') do
        items = Gcfs::Wrapper::Api::Item.all force: true, page: 2

        VCR.use_cassette('category/administrator/list/all/success') do
          categories = Gcfs::Wrapper::Api::Category.all

          VCR.use_cassette('item/administrator/show/'+(items.last.id + 1).to_s+'/failed') do
            item = Gcfs::Wrapper::Api::Item.find(items.last.id + 1)

            item.message.must_include('id does not have a valid value')

          end

        end
      end
    end

    it 'delete item' do
      VCR.use_cassette('item/administrator/update/image/success/all') do
        before_items = Gcfs::Wrapper::Api::Item.all force: true, page: 2

        VCR.use_cassette('category/administrator/list/all/success') do
          categories = Gcfs::Wrapper::Api::Category.all

          VCR.use_cassette('item/administrator/destroy/success') do
            item = Gcfs::Wrapper::Api::Item.destroy before_items.last.id

            VCR.use_cassette('item/administrator/destroy/success/all') do
              items = Gcfs::Wrapper::Api::Item.all force: true, page: 2

              item.id.must_equal before_items.last.id
              item.name.must_equal before_items.last.name
              item.name.must_equal 'Voucher C'
              item.category.must_equal categories.third.name

              items.size.must_equal 2
              items.total_count.must_equal 22
              items.total_pages.must_equal 2
              items.current_page.must_equal 2

              items.total_count.must_equal (before_items.total_count - 1)
            end
          end

        end

      end
    end

    it "raise errors if item id doesn't valid when delete item" do
      VCR.use_cassette('item/administrator/destroy/success/all') do
        before_items = Gcfs::Wrapper::Api::Item.all force: true, page: 2

        VCR.use_cassette('category/administrator/list/all/success') do
          categories = Gcfs::Wrapper::Api::Category.all

          VCR.use_cassette('item/administrator/destroy/failed') do
            item = Gcfs::Wrapper::Api::Item.destroy (before_items.last.id + 1)

            item.message.must_include('id does not have a valid value')

            VCR.use_cassette('item/administrator/destroy/success/failed') do
              items = Gcfs::Wrapper::Api::Item.all force: true, page: 2

              items.size.must_equal 2
              items.total_count.must_equal 22
              items.total_pages.must_equal 2
              items.current_page.must_equal 2

              items.total_count.must_equal before_items.total_count
            end
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

    it "list of items" do
      VCR.use_cassette('item/developer/list/all/success') do
        items = Gcfs::Wrapper::Api::Item.all force: true

        items.size.must_equal 6
        items.total_count.must_equal 6
        items.total_pages.must_equal 1
        items.current_page.must_equal 1

        VCR.use_cassette('item/developer/show/'+items.last.id.to_s+'/success') do
          items.last.as_hash.must_equal Gcfs::Wrapper::Api::Item.find(items.last.id).as_hash
        end
        items.last.class.must_equal Gcfs::Wrapper::Api::Item
        assert items.last.kind_of?(Gcfs::Wrapper::Api::Item)

        items.last.id.must_equal 10
        items.last.sku.must_equal '0510'
        items.last.name.must_equal 'Bigtax'
        items.last.category.must_equal 'Gadgets'

        items.each do |item|
          item.variants do |variant|
            VCR.use_cassette('item_variant/developer/show/'+variant.id.to_s+'/success') do
              variant.as_hash.must_equal Gcfs::Wrapper::Api::ItemVariant.find(item.id, variant.id).as_hash
            end
          end
        end
      end
    end

    it 'raise errors if token invalid' do
      VCR.use_cassette('item/developer/list/all/token_invalid') do
        Gcfs::Wrapper::Api.access_token = '1234567890ASDFGHJKLMNBVCX'

        items = Gcfs::Wrapper::Api::Item.all
        
        items.class.must_equal Gcfs::Wrapper::Api::Error
        assert items.kind_of?(Gcfs::Wrapper::Api::Error)

        items.message.must_equal 'invalid_request'
      end
    end

    it 'raise errors when create item' do
      VCR.use_cassette('category/developer/list/all/success') do
        categories = Gcfs::Wrapper::Api::Category.all

        VCR.use_cassette('item/developer/create/failed') do
          item = Gcfs::Wrapper::Api::Item.create name: "Voucher A", category: categories.first.name, image: File.open(File.join(Rails.root, 'app', 'assets', 'images', 'rails.png')), variants: [{ description: "Voucher nominal 50rb", nominal: 50000, price: 45000 }]

          item.class.must_equal Gcfs::Wrapper::Api::Error
          assert item.kind_of?(Gcfs::Wrapper::Api::Error)

          item.message.must_equal 'invalid_request'
        end
      end
    end

    it 'raise errors when edit item' do
      VCR.use_cassette('item/developer/list/all/success') do
        items = Gcfs::Wrapper::Api::Item.all force: true

        VCR.use_cassette('item/developer/update/failed') do
          item = Gcfs::Wrapper::Api::Item.update items.last.id, name: 'Voucher X'

          item.class.must_equal Gcfs::Wrapper::Api::Error
          assert item.kind_of?(Gcfs::Wrapper::Api::Error)

          item.message.must_equal 'invalid_request'
        end
      end
    end

    it 'show item' do
      VCR.use_cassette('item/developer/list/all/success') do
        items = Gcfs::Wrapper::Api::Item.all force: true

        VCR.use_cassette('category/developer/list/all/success') do
          categories = Gcfs::Wrapper::Api::Category.all

          VCR.use_cassette('item/developer/show/'+items.last.id.to_s+'/success') do
            item = Gcfs::Wrapper::Api::Item.find(items.last.id)
            items.last.as_hash.must_equal item.as_hash

            item.id.must_equal items.last.id
            item.name.must_equal items.last.name
            item.name.must_equal 'Bigtax'
            item.category.must_equal categories.last.name

          end

        end
      end
    end

    it 'raise errors when delete item' do
      VCR.use_cassette('item/developer/list/all/success') do
        items = Gcfs::Wrapper::Api::Item.all force: true

        VCR.use_cassette('item/developer/destroy/failed') do
          item = Gcfs::Wrapper::Api::Item.destroy items.last.id

          item.class.must_equal Gcfs::Wrapper::Api::Error
          assert item.kind_of?(Gcfs::Wrapper::Api::Error)

          item.message.must_equal 'invalid_request'
        end
      end
    end

  end

end