require 'helper'

describe 'inventory' do

  describe 'as administrator' do

    before do
      Gcfs::Wrapper::Api::configure do |config|
        config.key      = 'APIKEY'
        config.secret   = 'APISECRET'
        config.username = 'admin@gcfs.co.id'
        config.password = '12345678'
        # config.debug    = true
      end
      VCR.use_cassette('token/request_token/success') do
        @token = Gcfs::Wrapper::Api::Token.request
      end
    end

    it "list of incoming inventories" do
      VCR.use_cassette('inventory/administrator/list/all/incoming/success') do
        inventories = Gcfs::Wrapper::Api::Inventory.all 'incoming', force: true
        
        inventories.size.must_equal 20
        inventories.total_count.must_equal 4510
        inventories.total_pages.must_equal 226
        inventories.current_page.must_equal 1

        inventories.first.class.must_equal Gcfs::Wrapper::Api::Inventory
        assert inventories.first.kind_of?(Gcfs::Wrapper::Api::Inventory)

        inventories.first.id.must_equal 30027
        inventories.first.type.must_equal 'incoming'
        inventories.first.description.must_equal 'update stock 17/03/2015'
        
        inventories.first.item.class.must_equal Gcfs::Wrapper::Api::Item
        assert inventories.first.item.kind_of?(Gcfs::Wrapper::Api::Item)
        inventories.first.item.id.must_equal 1
        inventories.first.item.sku.must_equal '0101'
        inventories.first.item.name.must_equal 'Job'
        inventories.first.item.category.must_equal 'Giftcard'

        inventories.first.variant.class.must_equal Gcfs::Wrapper::Api::ItemVariant
        assert inventories.first.variant.kind_of?(Gcfs::Wrapper::Api::ItemVariant)
        inventories.first.variant.id.must_equal 1
        inventories.first.variant.sku.must_equal '010101'
        inventories.first.variant.description.must_equal 'Job 50rb'
        inventories.first.variant.nominal.must_equal 50000
        inventories.first.variant.price.must_equal 45000

        inventories.first.quantity.must_equal 10000
      end
    end

    it 'raise errors if token invalid' do
      VCR.use_cassette('inventory/administrator/list/all/incoming/token_invalid') do
        Gcfs::Wrapper::Api.access_token = '1234567890ASDFGHJKLMNBVCX'

        inventories = Gcfs::Wrapper::Api::Inventory.all 'incoming', force: true
        
        inventories.class.must_equal Gcfs::Wrapper::Api::Error
        assert inventories.kind_of?(Gcfs::Wrapper::Api::Error)

        inventories.message.must_equal 'invalid_request'
      end
    end

    it "list of outgoing inventories" do
      VCR.use_cassette('inventory/administrator/list/all/outgoing/success') do
        inventories = Gcfs::Wrapper::Api::Inventory.all 'outgoing', force: true
        
        inventories.size.must_equal 20
        inventories.total_count.must_equal 10250
        inventories.total_pages.must_equal 513
        inventories.current_page.must_equal 1

        inventories.first.class.must_equal Gcfs::Wrapper::Api::Inventory
        assert inventories.first.kind_of?(Gcfs::Wrapper::Api::Inventory)

        inventories.first.id.must_equal 67736
        inventories.first.type.must_equal 'outgoing'
        inventories.first.description.must_equal 'Order #fb7iTIYZc6'
        
        inventories.first.item.class.must_equal Gcfs::Wrapper::Api::Item
        assert inventories.first.item.kind_of?(Gcfs::Wrapper::Api::Item)
        inventories.first.item.id.must_equal 1
        inventories.first.item.sku.must_equal '0101'
        inventories.first.item.name.must_equal 'Job'
        inventories.first.item.category.must_equal 'Giftcard'

        inventories.first.variant.class.must_equal Gcfs::Wrapper::Api::ItemVariant
        assert inventories.first.variant.kind_of?(Gcfs::Wrapper::Api::ItemVariant)
        inventories.first.variant.id.must_equal 21
        inventories.first.variant.sku.must_equal '010121'
        inventories.first.variant.description.must_equal 'Job 150rb'
        inventories.first.variant.nominal.must_equal 150000
        inventories.first.variant.price.must_equal 145000

        inventories.first.quantity.must_equal -3
      end
    end

    it 'raise errors if token invalid' do
      VCR.use_cassette('inventory/administrator/list/all/outgoing/token_invalid') do
        Gcfs::Wrapper::Api.access_token = '1234567890ASDFGHJKLMNBVCX'

        inventories = Gcfs::Wrapper::Api::Inventory.all 'outgoing', force: true
        
        inventories.class.must_equal Gcfs::Wrapper::Api::Error
        assert inventories.kind_of?(Gcfs::Wrapper::Api::Error)

        inventories.message.must_equal 'invalid_request'
      end
    end

    it 'raise errors if type invalid' do
      VCR.use_cassette('inventory/administrator/list/all/type_invalid') do
        inventories = Gcfs::Wrapper::Api::Inventory.all nil
        
        inventories.class.must_equal Gcfs::Wrapper::Api::Error
        assert inventories.kind_of?(Gcfs::Wrapper::Api::Error)

        inventories.message.must_equal 'invalid_type'
      end
    end

    it 'create incoming inventory' do
      VCR.use_cassette('inventory/administrator/list/all/incoming/success') do
        before_inventories = Gcfs::Wrapper::Api::Inventory.all :incoming, force: true

        VCR.use_cassette('inventory/administrator/create/incoming/success') do
          inventory = Gcfs::Wrapper::Api::Inventory.create type: :incoming, description: 'update stock 27/03/2015', item_id: 1, variant_id: 1, quantity: 10, metadata: {"user":{"id": 1,"name": "Admin"}}

          VCR.use_cassette('inventory/administrator/create/incoming/success/all') do
            inventories = Gcfs::Wrapper::Api::Inventory.all :incoming, force: true, sort: {created_at: :desc}

            inventories.size.must_equal 20
            inventories.total_count.must_equal 4511
            inventories.total_pages.must_equal 226
            inventories.current_page.must_equal 1

            inventories.total_count.must_equal (before_inventories.total_count + 1)

            inventory.id.must_equal inventories.first.id
            inventory.description.must_equal inventories.first.description
            inventory.class.must_equal Gcfs::Wrapper::Api::Inventory
            assert inventory.kind_of?(Gcfs::Wrapper::Api::Inventory)

            inventory.id.must_equal 82446
            inventory.type.must_equal 'incoming'
            inventory.description.must_equal 'update stock 27/03/2015'
            
            inventory.item.class.must_equal Gcfs::Wrapper::Api::Item
            assert inventory.item.kind_of?(Gcfs::Wrapper::Api::Item)
            inventory.item.id.must_equal 1
            inventory.item.sku.must_equal '0101'
            inventory.item.name.must_equal 'Job'
            inventory.item.category.must_equal 'Giftcard'

            inventory.variant.class.must_equal Gcfs::Wrapper::Api::ItemVariant
            assert inventory.variant.kind_of?(Gcfs::Wrapper::Api::ItemVariant)
            inventory.variant.id.must_equal 1
            inventory.variant.sku.must_equal '010101'
            inventory.variant.description.must_equal 'Job 50rb'
            inventory.variant.nominal.must_equal 50000
            inventory.variant.price.must_equal 45000

            inventory.quantity.must_equal 10
          end
        end
      end
    end

    it 'raise errors if params not filled when create inventory' do
      VCR.use_cassette('inventory/administrator/create/incoming/success/all') do
        before_inventories = Gcfs::Wrapper::Api::Inventory.all :incoming, force: true, sort: {created_at: :desc}

        VCR.use_cassette('inventory/administrator/create/incoming/failed_params_not_filled') do
          inventory = Gcfs::Wrapper::Api::Inventory.create 

          inventory.class.must_equal Gcfs::Wrapper::Api::Error
          assert inventory.kind_of?(Gcfs::Wrapper::Api::Error)

          inventory.message.must_include('type is missing')
          inventory.message.must_include('type does not have a valid value')
          inventory.message.must_include('description is missing')
          inventory.message.must_include('item_id is missing')
          inventory.message.must_include('item_id does not have a valid value')
          inventory.message.must_include('variant_id is missing')
          inventory.message.must_include('variant_id does not have a valid value')
          inventory.message.must_include('quantity is missing')
          inventory.message.must_include('metadata is missing')
          inventory.message.must_include('metadata[user] is missing')
          inventory.message.must_include('metadata[user][id] is missing')
          inventory.message.must_include('metadata[user][name] is missing')

          VCR.use_cassette('inventory/administrator/create/incoming/failed/all') do
            inventories = Gcfs::Wrapper::Api::Inventory.all :incoming, force: true, sort: {created_at: :desc}

            inventories.size.must_equal 20
            inventories.total_count.must_equal 4511
            inventories.total_pages.must_equal 226
            inventories.current_page.must_equal 1

            inventories.total_count.must_equal before_inventories.total_count
          end
        end
      end

    end

    it 'raise errors if params quantity wrong when create incoming inventory' do
      VCR.use_cassette('inventory/administrator/create/incoming/success/all') do
        before_inventories = Gcfs::Wrapper::Api::Inventory.all :incoming, force: true, sort: {created_at: :desc}

        VCR.use_cassette('inventory/administrator/create/incoming/failed_quantity_wrong') do
          inventory = Gcfs::Wrapper::Api::Inventory.create type: :incoming, description: 'update stock 27/03/2015', item_id: 1, variant_id: 1, quantity: -10, metadata: {"user":{"id": 1,"name": "Admin"}}

          inventory.class.must_equal Gcfs::Wrapper::Api::Error
          assert inventory.kind_of?(Gcfs::Wrapper::Api::Error)

          inventory.message.must_equal 'Quantity must be positive'

          VCR.use_cassette('inventory/administrator/create/incoming/failed/all') do
            inventories = Gcfs::Wrapper::Api::Inventory.all :incoming, force: true, sort: {created_at: :desc}

            inventories.size.must_equal 20
            inventories.total_count.must_equal 4511
            inventories.total_pages.must_equal 226
            inventories.current_page.must_equal 1

            inventories.total_count.must_equal before_inventories.total_count
          end
        end
      end
    end

    it 'create outgoing inventory' do
      VCR.use_cassette('inventory/administrator/list/all/outgoing/success') do
        before_inventories = Gcfs::Wrapper::Api::Inventory.all :outgoing, force: true

        VCR.use_cassette('inventory/administrator/create/outgoing/success') do
          inventory = Gcfs::Wrapper::Api::Inventory.create type: :outgoing, description: 'order voucher', item_id: 1, variant_id: 1, quantity: -10, metadata: {"user":{"id": 1,"name": "Admin"}}

          VCR.use_cassette('inventory/administrator/create/outgoing/success/all') do
            inventories = Gcfs::Wrapper::Api::Inventory.all :outgoing, force: true, sort: {created_at: :desc}

            inventories.size.must_equal 20
            inventories.total_count.must_equal 10251
            inventories.total_pages.must_equal 513
            inventories.current_page.must_equal 1

            inventories.total_count.must_equal (before_inventories.total_count + 1)

            inventory.id.must_equal inventories.first.id
            inventory.description.must_equal inventories.first.description
            inventory.class.must_equal Gcfs::Wrapper::Api::Inventory
            assert inventory.kind_of?(Gcfs::Wrapper::Api::Inventory)

            inventory.id.must_equal 82447
            inventory.type.must_equal 'outgoing'
            inventory.description.must_equal 'order voucher'
            
            inventory.item.class.must_equal Gcfs::Wrapper::Api::Item
            assert inventory.item.kind_of?(Gcfs::Wrapper::Api::Item)
            inventory.item.id.must_equal 1
            inventory.item.sku.must_equal '0101'
            inventory.item.name.must_equal 'Job'
            inventory.item.category.must_equal 'Giftcard'

            inventory.variant.class.must_equal Gcfs::Wrapper::Api::ItemVariant
            assert inventory.variant.kind_of?(Gcfs::Wrapper::Api::ItemVariant)
            inventory.variant.id.must_equal 1
            inventory.variant.sku.must_equal '010101'
            inventory.variant.description.must_equal 'Job 50rb'
            inventory.variant.nominal.must_equal 50000
            inventory.variant.price.must_equal 45000

            inventory.quantity.must_equal -10
          end
        end
      end
    end

    it 'raise errors if params not filled when create inventory' do
      VCR.use_cassette('inventory/administrator/create/outgoing/success/all') do
        before_inventories = Gcfs::Wrapper::Api::Inventory.all :outgoing, force: true, sort: {created_at: :desc}

        VCR.use_cassette('inventory/administrator/create/outgoing/failed_params_not_filled') do
          inventory = Gcfs::Wrapper::Api::Inventory.create 

          inventory.class.must_equal Gcfs::Wrapper::Api::Error
          assert inventory.kind_of?(Gcfs::Wrapper::Api::Error)

          inventory.message.must_include('type is missing')
          inventory.message.must_include('type does not have a valid value')
          inventory.message.must_include('description is missing')
          inventory.message.must_include('item_id is missing')
          inventory.message.must_include('item_id does not have a valid value')
          inventory.message.must_include('variant_id is missing')
          inventory.message.must_include('variant_id does not have a valid value')
          inventory.message.must_include('quantity is missing')
          inventory.message.must_include('metadata is missing')
          inventory.message.must_include('metadata[user] is missing')
          inventory.message.must_include('metadata[user][id] is missing')
          inventory.message.must_include('metadata[user][name] is missing')

          VCR.use_cassette('inventory/administrator/create/outgoing/failed/all') do
            inventories = Gcfs::Wrapper::Api::Inventory.all :outgoing, force: true, sort: {created_at: :desc}

            inventories.size.must_equal 20
            inventories.total_count.must_equal 10251
            inventories.total_pages.must_equal 513
            inventories.current_page.must_equal 1

            inventories.total_count.must_equal before_inventories.total_count
          end
        end
      end

    end

    it 'raise errors if params quantity wrong when create outgoing inventory' do
      VCR.use_cassette('inventory/administrator/create/outgoing/success/all') do
        before_inventories = Gcfs::Wrapper::Api::Inventory.all :outgoing, force: true, sort: {created_at: :desc}

        VCR.use_cassette('inventory/administrator/create/outgoing/failed_quantity_wrong') do
          inventory = Gcfs::Wrapper::Api::Inventory.create type: :outgoing, description: 'order voucher', item_id: 1, variant_id: 1, quantity: 10, metadata: {"user":{"id": 1,"name": "Admin"}}

          inventory.class.must_equal Gcfs::Wrapper::Api::Error
          assert inventory.kind_of?(Gcfs::Wrapper::Api::Error)

          inventory.message.must_equal 'Quantity must be negative'

          VCR.use_cassette('inventory/administrator/create/outgoing/failed/all') do
            inventories = Gcfs::Wrapper::Api::Inventory.all :outgoing, force: true, sort: {created_at: :desc}

            inventories.size.must_equal 20
            inventories.total_count.must_equal 10251
            inventories.total_pages.must_equal 513
            inventories.current_page.must_equal 1

            inventories.total_count.must_equal before_inventories.total_count
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

    it "raise errors when list of incoming inventories" do
      VCR.use_cassette('inventory/developer/list/all/incoming/failed') do
        inventories = Gcfs::Wrapper::Api::Inventory.all 'incoming', force: true
        
        inventories.class.must_equal Gcfs::Wrapper::Api::Error
        assert inventories.kind_of?(Gcfs::Wrapper::Api::Error)

        inventories.message.must_equal 'invalid_request'
      end
    end

    it 'raise errors if token invalid' do
      VCR.use_cassette('inventory/developer/list/all/token_invalid') do
        Gcfs::Wrapper::Api.access_token = '1234567890ASDFGHJKLMNBVCX'

        inventories = Gcfs::Wrapper::Api::Inventory.all :incoming, force: true
        
        inventories.class.must_equal Gcfs::Wrapper::Api::Error
        assert inventories.kind_of?(Gcfs::Wrapper::Api::Error)

        inventories.message.must_equal 'invalid_request'
      end
    end

    it 'raise errors when create incoming inventory' do
      VCR.use_cassette('inventory/developer/create/incoming/failed') do
        inventory = Gcfs::Wrapper::Api::Inventory.create type: :incoming, description: 'update stock 27/03/2015', item_id: 1, variant_id: 1, quantity: 10, metadata: {"user":{"id": 1,"name": "mutouzi@gmail.com"}}

        inventory.class.must_equal Gcfs::Wrapper::Api::Error
        assert inventory.kind_of?(Gcfs::Wrapper::Api::Error)

        inventory.message.must_equal 'invalid_request'
      end
    end

    it 'raise errors when create outgoing inventory' do
      VCR.use_cassette('inventory/developer/create/outgoing/failed') do
        inventory = Gcfs::Wrapper::Api::Inventory.create type: :outgoing, description: 'update stock 27/03/2015', item_id: 1, variant_id: 1, quantity: -10, metadata: {"user":{"id": 1,"name": "mutouzi@gmail.com"}}

        inventory.class.must_equal Gcfs::Wrapper::Api::Error
        assert inventory.kind_of?(Gcfs::Wrapper::Api::Error)

        inventory.message.must_equal 'invalid_request'
      end
    end

  end

end