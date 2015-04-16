require 'helper'

describe 'item_variant' do

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

    it "list of item_variants" do
      VCR.use_cassette('item/administrator/list/all/success') do
        items = Gcfs::Wrapper::Api::Item.all force: true

        item = items.first

        VCR.use_cassette('item_variant/administrator/list/all/success') do
          item_variants = Gcfs::Wrapper::Api::ItemVariant.all item.id.to_s, force: true
          
          item_variants.size.must_equal 5
          item_variants.total_count.must_equal 5
          item_variants.total_pages.must_equal 1
          item_variants.current_page.must_equal 1
          VCR.use_cassette('item_variant/administrator/show/'+item_variants.first.id.to_s+'/success') do
            item_variants.first.as_hash.must_equal Gcfs::Wrapper::Api::ItemVariant.find(item.id.to_s, item_variants.first.id).as_hash
          end
          item_variants.first.class.must_equal Gcfs::Wrapper::Api::ItemVariant
          assert item_variants.first.kind_of?(Gcfs::Wrapper::Api::ItemVariant)

          item_variants.first.id.must_equal 1
          item_variants.first.sku.must_equal '010101'
          item_variants.first.description.must_equal 'Job 50rb'
          item_variants.first.nominal.must_equal 50000
          item_variants.first.price.must_equal 45000
        end
      end
    end

    it 'raise errors if token invalid' do
      VCR.use_cassette('item/administrator/list/all/success') do
        items = Gcfs::Wrapper::Api::Item.all force: true

        item = items.first
        VCR.use_cassette('item_variant/administrator/list/all/token_invalid') do
          Gcfs::Wrapper::Api.access_token = '1234567890ASDFGHJKLMNBVCX'

          item_variants = Gcfs::Wrapper::Api::ItemVariant.all item.id.to_s
          
          item_variants.class.must_equal Gcfs::Wrapper::Api::Error
          assert item_variants.kind_of?(Gcfs::Wrapper::Api::Error)

          item_variants.message.must_equal 'invalid_request'
        end
      end
    end

    it 'create item_variant' do
      VCR.use_cassette('item/administrator/list/all/success') do
        items = Gcfs::Wrapper::Api::Item.all force: true

        item = items.first

        VCR.use_cassette('item_variant/administrator/list/all/success') do
          before_item_variants = Gcfs::Wrapper::Api::ItemVariant.all item.id.to_s, force: true

          VCR.use_cassette('item_variant/administrator/create/success') do
            item_variant = Gcfs::Wrapper::Api::ItemVariant.create item.id.to_s, description: "Voucher nominal 500rb", nominal: 500000, price: 500000

            VCR.use_cassette('item_variant/administrator/create/success/all') do
              item_variants = Gcfs::Wrapper::Api::ItemVariant.all item.id.to_s, force: true

              item_variants.size.must_equal 6
              item_variants.total_count.must_equal 6
              item_variants.total_pages.must_equal 1
              item_variants.current_page.must_equal 1

              item_variants.total_count.must_equal (before_item_variants.total_count + 1)

              item_variant.id.must_equal item_variants.last.id
              item_variant.sku.must_equal item_variants.last.sku
              item_variant.description.must_equal item_variants.last.description
              item_variant.nominal.must_equal item_variants.last.nominal
              item_variant.price.must_equal item_variants.last.price
              item_variant.as_hash.must_equal item_variants.last.as_hash
              item_variant.class.must_equal Gcfs::Wrapper::Api::ItemVariant
              assert item_variant.kind_of?(Gcfs::Wrapper::Api::ItemVariant)

              item_variant.id.must_equal 65
              item_variant.sku.must_equal '010165'
              item_variant.description.must_equal 'Voucher nominal 500rb'
              item_variant.nominal.must_equal 500000
              item_variant.price.must_equal 500000
              item_variant.as_hash.must_equal item_variants.last.as_hash
              
            end
          end

        end

      end
    end

    it 'raise errors if params not filled when create item_variant' do
      VCR.use_cassette('item/administrator/list/all/success') do
        items = Gcfs::Wrapper::Api::Item.all force: true

        item = items.first

        VCR.use_cassette('item_variant/administrator/create/success/all') do
          before_item_variants = Gcfs::Wrapper::Api::ItemVariant.all item.id.to_s, force: true

          VCR.use_cassette('item_variant/administrator/create/failed_params_not_filled') do
            item_variant = Gcfs::Wrapper::Api::ItemVariant.create item.id.to_s

            item_variant.message.must_include('description is missing')
            item_variant.message.must_include('nominal is missing')
            item_variant.message.must_include('price is missing')

            VCR.use_cassette('item_variant/administrator/create/failed/all') do
              item_variants = Gcfs::Wrapper::Api::ItemVariant.all item.id.to_s, force: true

              item_variants.size.must_equal 6
              item_variants.total_count.must_equal 6
              item_variants.total_pages.must_equal 1
              item_variants.current_page.must_equal 1

              item_variants.total_count.must_equal before_item_variants.total_count
            end
          end

        end

      end
    end

    it 'edit item_variant' do
      VCR.use_cassette('item/administrator/list/all/success') do
        items = Gcfs::Wrapper::Api::Item.all force: true

        item = items.first

        VCR.use_cassette('item_variant/administrator/create/success/all') do
          before_item_variants = Gcfs::Wrapper::Api::ItemVariant.all item.id.to_s, force: true

          VCR.use_cassette('item_variant/administrator/update/success') do
            item_variant = Gcfs::Wrapper::Api::ItemVariant.update item.id.to_s, before_item_variants.last.id, description: "Voucher nominal 600rb", nominal: 600000, price: 600000

            VCR.use_cassette('item_variant/administrator/update/success/all') do
              item_variants = Gcfs::Wrapper::Api::ItemVariant.all item.id.to_s, force: true

              item_variant.id.must_equal item_variants.last.id
              item_variant.description.must_equal item_variants.last.description
              item_variant.description.must_equal 'Voucher nominal 600rb'
              item_variant.nominal.must_equal item_variants.last.nominal
              item_variant.nominal.must_equal 600000
              item_variant.price.must_equal item_variants.last.price
              item_variant.price.must_equal 600000

              item_variants.size.must_equal 6
              item_variants.total_count.must_equal 6
              item_variants.total_pages.must_equal 1
              item_variants.current_page.must_equal 1

              item_variants.total_count.must_equal before_item_variants.total_count
            end
          end

        end

      end
    end

    it 'edit item_variant with params only description' do
      VCR.use_cassette('item/administrator/list/all/success') do
        items = Gcfs::Wrapper::Api::Item.all force: true

        item = items.first

        VCR.use_cassette('item_variant/administrator/update/success/all') do
          before_item_variants = Gcfs::Wrapper::Api::ItemVariant.all item.id.to_s, force: true

          VCR.use_cassette('item_variant/administrator/update/description/success') do
            item_variant = Gcfs::Wrapper::Api::ItemVariant.update item.id.to_s, before_item_variants.last.id, description: 'Voucher nominal 600.000'

            VCR.use_cassette('item_variant/administrator/update/description/success/all') do
              item_variants = Gcfs::Wrapper::Api::ItemVariant.all item.id.to_s, force: true

              item_variant.id.must_equal item_variants.last.id
              item_variant.description.must_equal item_variants.last.description
              item_variant.description.must_equal 'Voucher nominal 600.000'
              item_variant.nominal.must_equal item_variants.last.nominal
              item_variant.nominal.must_equal 600000
              item_variant.price.must_equal item_variants.last.price
              item_variant.price.must_equal 600000

            end
          end

        end

      end
    end

    it 'edit item_variant with params only nominal' do
      VCR.use_cassette('item/administrator/list/all/success') do
        items = Gcfs::Wrapper::Api::Item.all force: true

        item = items.first

        VCR.use_cassette('item_variant/administrator/update/description/success/all') do
          before_item_variants = Gcfs::Wrapper::Api::ItemVariant.all item.id.to_s, force: true

          VCR.use_cassette('item_variant/administrator/update/nominal/success') do
            item_variant = Gcfs::Wrapper::Api::ItemVariant.update item.id.to_s, before_item_variants.last.id, nominal: 650000

            VCR.use_cassette('item_variant/administrator/update/nominal/success/all') do
              item_variants = Gcfs::Wrapper::Api::ItemVariant.all item.id.to_s, force: true

              item_variant.id.must_equal item_variants.last.id
              item_variant.description.must_equal item_variants.last.description
              item_variant.description.must_equal 'Voucher nominal 600.000'
              item_variant.nominal.must_equal item_variants.last.nominal
              item_variant.nominal.must_equal 650000
              item_variant.price.must_equal item_variants.last.price
              item_variant.price.must_equal 600000

            end
          end

        end

      end
    end

    it 'edit item_variant with params only price' do
      VCR.use_cassette('item/administrator/list/all/success') do
        items = Gcfs::Wrapper::Api::Item.all force: true

        item = items.first

        VCR.use_cassette('item_variant/administrator/update/nominal/success/all') do
          before_item_variants = Gcfs::Wrapper::Api::ItemVariant.all item.id.to_s, force: true

          VCR.use_cassette('item_variant/administrator/update/price/success') do
            item_variant = Gcfs::Wrapper::Api::ItemVariant.update item.id.to_s, before_item_variants.last.id, price: 650000

            VCR.use_cassette('item_variant/administrator/update/price/success/all') do
              item_variants = Gcfs::Wrapper::Api::ItemVariant.all item.id.to_s, force: true

              item_variant.id.must_equal item_variants.last.id
              item_variant.description.must_equal item_variants.last.description
              item_variant.description.must_equal 'Voucher nominal 600.000'
              item_variant.nominal.must_equal item_variants.last.nominal
              item_variant.nominal.must_equal 650000
              item_variant.price.must_equal item_variants.last.price
              item_variant.price.must_equal 650000

            end
          end

        end

      end
    end

    it 'raise errors if params not filled when edit item_variant' do
      VCR.use_cassette('item/administrator/list/all/success') do
        items = Gcfs::Wrapper::Api::Item.all force: true

        item = items.first

        VCR.use_cassette('item_variant/administrator/update/price/success/all') do
          before_item_variants = Gcfs::Wrapper::Api::ItemVariant.all item.id.to_s, force: true

          VCR.use_cassette('item_variant/administrator/update/failed_params_not_filled') do
            item_variant = Gcfs::Wrapper::Api::ItemVariant.update item.id.to_s, before_item_variants.last.id

            item_variant.message.must_include('description, nominal, price are missing')
            item_variant.message.must_include('at least one parameter must be provided')

            VCR.use_cassette('item_variant/administrator/update/failed/all') do
              item_variants = Gcfs::Wrapper::Api::ItemVariant.all item.id.to_s, force: true

              item_variants.size.must_equal 6
              item_variants.total_count.must_equal 6
              item_variants.total_pages.must_equal 1
              item_variants.current_page.must_equal 1

              item_variants.total_count.must_equal before_item_variants.total_count
            end
          end

        end

      end
    end

    it 'show item_variant' do
      VCR.use_cassette('item/administrator/list/all/success') do
        items = Gcfs::Wrapper::Api::Item.all force: true

        item = items.first

        VCR.use_cassette('item_variant/administrator/update/price/success/all') do
          item_variants = Gcfs::Wrapper::Api::ItemVariant.all item.id.to_s, force: true

          VCR.use_cassette('item_variant/administrator/show/'+item_variants.last.id.to_s+'/success') do
            item_variant = Gcfs::Wrapper::Api::ItemVariant.find(item.id.to_s, item_variants.last.id)
            item_variants.last.as_hash.must_equal item_variant.as_hash

            item_variant.id.must_equal item_variants.last.id
            item_variant.description.must_equal item_variants.last.description
            item_variant.description.must_equal 'Voucher nominal 600.000'
            item_variant.nominal.must_equal item_variants.last.nominal
            item_variant.nominal.must_equal 650000
            item_variant.price.must_equal item_variants.last.price
            item_variant.price.must_equal 650000

          end

        end
      end
    end

    it "raise errors if item_variant id doesn't valid when show item_variant" do
      VCR.use_cassette('item/administrator/list/all/success') do
        items = Gcfs::Wrapper::Api::Item.all force: true

        item = items.first

        VCR.use_cassette('item_variant/administrator/update/price/success/all') do
          item_variants = Gcfs::Wrapper::Api::ItemVariant.all item.id.to_s, force: true

          VCR.use_cassette('item_variant/administrator/show/'+(item_variants.last.id + 1).to_s+'/failed') do
            item_variant = Gcfs::Wrapper::Api::ItemVariant.find(item.id.to_s, item_variants.last.id + 1)

            item_variant.message.must_include("Item Variant doesn't Exist")

          end

        end
      end
    end

    it 'delete item_variant' do
      VCR.use_cassette('item/administrator/list/all/success') do
        items = Gcfs::Wrapper::Api::Item.all force: true

        item = items.first

        VCR.use_cassette('item_variant/administrator/update/price/success/all') do
          before_item_variants = Gcfs::Wrapper::Api::ItemVariant.all item.id.to_s, force: true

          VCR.use_cassette('item_variant/administrator/destroy/success') do
            item_variant = Gcfs::Wrapper::Api::ItemVariant.destroy item.id.to_s, before_item_variants.last.id

            VCR.use_cassette('item_variant/administrator/destroy/success/all') do
              item_variants = Gcfs::Wrapper::Api::ItemVariant.all item.id.to_s, force: true

              item_variant.id.must_equal before_item_variants.last.id
              item_variant.description.must_equal before_item_variants.last.description
              item_variant.description.must_equal 'Voucher nominal 600.000'
              item_variant.nominal.must_equal before_item_variants.last.nominal
              item_variant.nominal.must_equal 650000
              item_variant.price.must_equal before_item_variants.last.price
              item_variant.price.must_equal 650000

              item_variants.size.must_equal 5
              item_variants.total_count.must_equal 5
              item_variants.total_pages.must_equal 1
              item_variants.current_page.must_equal 1

              item_variants.total_count.must_equal (before_item_variants.total_count - 1)
            end
          end

        end

      end
    end

    it "raise errors if item_variant id doesn't valid when delete item_variant" do
      VCR.use_cassette('item/administrator/list/all/success') do
        items = Gcfs::Wrapper::Api::Item.all force: true

        item = items.first

        VCR.use_cassette('item_variant/administrator/destroy/success/all') do
          before_item_variants = Gcfs::Wrapper::Api::ItemVariant.all item.id.to_s, force: true

          VCR.use_cassette('item_variant/administrator/destroy/failed') do
            item_variant = Gcfs::Wrapper::Api::ItemVariant.destroy item.id.to_s, (before_item_variants.last.id + 1)

            item_variant.message.must_include("Item Variant doesn't Exist")

            VCR.use_cassette('item_variant/administrator/destroy/success/failed') do
              item_variants = Gcfs::Wrapper::Api::ItemVariant.all item.id.to_s, force: true

              item_variants.size.must_equal 5
              item_variants.total_count.must_equal 5
              item_variants.total_pages.must_equal 1
              item_variants.current_page.must_equal 1

              item_variants.total_count.must_equal before_item_variants.total_count
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

    it "list of item_variants" do
      VCR.use_cassette('item/developer/list/all/success') do
        items = Gcfs::Wrapper::Api::Item.all force: true

        item = items.first

        VCR.use_cassette('item_variant/developer/list/all/success') do
          item_variants = Gcfs::Wrapper::Api::ItemVariant.all item.id.to_s, force: true

          item_variants.size.must_equal 5
          item_variants.total_count.must_equal 5
          item_variants.total_pages.must_equal 1
          item_variants.current_page.must_equal 1
          VCR.use_cassette('item_variant/developer/show/'+item_variants.first.id.to_s+'/success') do
            item_variants.first.as_hash.must_equal Gcfs::Wrapper::Api::ItemVariant.find(item.id.to_s, item_variants.first.id).as_hash
          end
          item_variants.first.class.must_equal Gcfs::Wrapper::Api::ItemVariant
          assert item_variants.first.kind_of?(Gcfs::Wrapper::Api::ItemVariant)

          item_variants.first.id.must_equal 1
          item_variants.first.sku.must_equal '010101'
          item_variants.first.description.must_equal 'Job 50rb'
          item_variants.first.nominal.must_equal 50000
          item_variants.first.price.must_equal 45000
        end
      end
    end

    it 'raise errors if token invalid' do
      VCR.use_cassette('item/developer/list/all/success') do
        items = Gcfs::Wrapper::Api::Item.all force: true

        item = items.first
        VCR.use_cassette('item_variant/developer/list/all/token_invalid') do
          Gcfs::Wrapper::Api.access_token = '1234567890ASDFGHJKLMNBVCX'

          item_variants = Gcfs::Wrapper::Api::ItemVariant.all item.id.to_s

          item_variants.class.must_equal Gcfs::Wrapper::Api::Error
          assert item_variants.kind_of?(Gcfs::Wrapper::Api::Error)

          item_variants.message.must_equal 'invalid_request'
        end
      end
    end

    it 'raise errors when create item_variant' do
      VCR.use_cassette('item/developer/list/all/success') do
        items = Gcfs::Wrapper::Api::Item.all force: true

        item = items.first

        VCR.use_cassette('item_variant/developer/create/failed') do
          item_variant = Gcfs::Wrapper::Api::ItemVariant.create item.id.to_s, description: "Voucher nominal 500rb", nominal: 500000, price: 500000

          item_variant.class.must_equal Gcfs::Wrapper::Api::Error
          assert item_variant.kind_of?(Gcfs::Wrapper::Api::Error)

          item_variant.message.must_equal 'invalid_request'
        end

      end
    end

    it 'raise errors when edit item_variant' do
      VCR.use_cassette('item/developer/list/all/success') do
        items = Gcfs::Wrapper::Api::Item.all force: true

        item = items.first

        VCR.use_cassette('item_variant/developer/create/success/all') do
          before_item_variants = Gcfs::Wrapper::Api::ItemVariant.all item.id.to_s, force: true

          VCR.use_cassette('item_variant/developer/update/failed') do
            item_variant = Gcfs::Wrapper::Api::ItemVariant.update item.id.to_s, before_item_variants.last.id, description: "Voucher nominal 600rb", nominal: 600000, price: 600000

            item_variant.class.must_equal Gcfs::Wrapper::Api::Error
            assert item_variant.kind_of?(Gcfs::Wrapper::Api::Error)

            item_variant.message.must_equal 'invalid_request'
          end

        end

      end
    end

    it 'show item_variant' do
      VCR.use_cassette('item/developer/list/all/success') do
        items = Gcfs::Wrapper::Api::Item.all force: true

        item = items.first

        VCR.use_cassette('item_variant/developer/list/all/success') do
          item_variants = Gcfs::Wrapper::Api::ItemVariant.all item.id.to_s, force: true

          VCR.use_cassette('item_variant/developer/show/'+item_variants.first.id.to_s+'/success') do
            item_variant = Gcfs::Wrapper::Api::ItemVariant.find(item.id.to_s, item_variants.first.id)
            item_variants.first.as_hash.must_equal item_variant.as_hash

            item_variants.first.id.must_equal 1
            item_variants.first.sku.must_equal '010101'
            item_variants.first.description.must_equal 'Job 50rb'
            item_variants.first.nominal.must_equal 50000
            item_variants.first.price.must_equal 45000

          end

        end
      end
    end

    it "raise errors if item_variant id doesn't valid when show item_variant" do
      VCR.use_cassette('item/developer/list/all/success') do
        items = Gcfs::Wrapper::Api::Item.all force: true

        item = items.first

        VCR.use_cassette('item_variant/developer/list/all/success') do
          item_variants = Gcfs::Wrapper::Api::ItemVariant.all item.id.to_s, force: true

          VCR.use_cassette('item_variant/developer/show/'+(item_variants.last.id + 1).to_s+'/failed') do
            item_variant = Gcfs::Wrapper::Api::ItemVariant.find(item.id.to_s, item_variants.last.id + 1)

            item_variant.message.must_include("Item Variant doesn't Exist")

          end

        end
      end
    end

    it 'raise errors when delete item_variant' do
      VCR.use_cassette('item/developer/list/all/success') do
        items = Gcfs::Wrapper::Api::Item.all force: true

        item = items.first

        VCR.use_cassette('item_variant/developer/list/all/success') do
          before_item_variants = Gcfs::Wrapper::Api::ItemVariant.all item.id.to_s, force: true

          VCR.use_cassette('item_variant/developer/destroy/failed') do
            item_variant = Gcfs::Wrapper::Api::ItemVariant.destroy item.id.to_s, before_item_variants.last.id

            item_variant.class.must_equal Gcfs::Wrapper::Api::Error
            assert item_variant.kind_of?(Gcfs::Wrapper::Api::Error)

            item_variant.message.must_equal 'invalid_request'
          end

        end

      end
    end

  end

end