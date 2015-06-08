require 'helper'

describe 'order' do

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

    it "list of orders" do
      VCR.use_cassette('order/administrator/list/all/success') do
        orders = Gcfs::Wrapper::Api::Order.all force: true, page: 6

        orders.size.must_equal 3
        orders.total_count.must_equal 103
        orders.total_pages.must_equal 6
        orders.current_page.must_equal 6

        orders.last.class.must_equal Gcfs::Wrapper::Api::Order
        assert orders.last.kind_of?(Gcfs::Wrapper::Api::Order)

        orders.last.id.must_equal 103
        orders.last.transaction_id.must_equal 'PTS4E7hfOg'
        orders.last.invoice_number.must_equal '3543737041'
        orders.last.description.must_equal 'Hic rerum et quae aut adipisci maiores eos.'

        orders.last.client.class.must_equal Gcfs::Wrapper::Api::Client
        orders.last.client.name.must_equal 'Giftcard'
        orders.last.client.address.must_equal 'giftcard.co.id'
        orders.last.client.billing_address.must_equal 'giftcard.co.id'

        orders.last.recepient.class.must_equal Gcfs::Wrapper::Api::Recepient
        orders.last.recepient.name.must_equal 'Garett Balistreri'
        orders.last.recepient.email.must_equal 'balistreri_garett@ferryschuppe.biz'
        orders.last.recepient.phone_number.must_equal '1-523-943-6628'
        orders.last.recepient.address.must_equal '3283 Murray Plaza Rickystad BANDUNG 84671'
        orders.last.recepient.city.must_equal 'BANDUNG'
        orders.last.recepient.zip_code.must_equal '84671'
        orders.last.recepient.notes.must_equal "Atque consequatur dolorem architecto. Sint culpa qui ipsum."
        
        orders.last.items.each do |item|
          item.class.must_equal Gcfs::Wrapper::Api::OrderItem
          assert item.kind_of?(Gcfs::Wrapper::Api::OrderItem)
        end

        orders.last.items.first.id.must_equal 1
        orders.last.items.first.sku.must_equal '0101'
        orders.last.items.first.name.must_equal 'Fintone'
        
        orders.last.items.first.variants.each do |variant|
          variant.class.must_equal Gcfs::Wrapper::Api::OrderItemVariant
          assert variant.kind_of?(Gcfs::Wrapper::Api::OrderItemVariant)
        end

        orders.last.items.first.variants.first.id.must_equal 1
        orders.last.items.first.variants.first.sku.must_equal '010101'
        orders.last.items.first.variants.first.description.must_equal 'Fintone 50rb'
        orders.last.items.first.variants.first.quantity.must_equal 10
        orders.last.items.first.variants.first.price.must_equal 45000
        orders.last.items.first.variants.first.nominal.must_equal 50000
        orders.last.items.first.variants.first.subtotal.must_equal 450000

        orders.last.histories.each do |history|
          history.class.must_equal Gcfs::Wrapper::Api::OrderHistory
          assert history.kind_of?(Gcfs::Wrapper::Api::OrderHistory)
        end

        orders.last.histories.first.id.must_equal 116
        orders.last.histories.first.status.must_equal 'received'
        orders.last.histories.first.description.must_equal 'Received by Maye Effertz at 2015-04-24 10:10:08'
        metadata = {"user"=>{"id"=>1, "name"=>"derri@giftcard.co.id"}}
        orders.last.histories.first.metadata.must_equal metadata

        total = 0
        orders.last.items.each do |item|
          item.variants.each do |variant|
            total += variant.subtotal
          end
        end

        orders.last.total.must_equal total
        orders.last.shipping_fee.must_equal 12500
        orders.last.total_with_shipping.must_equal total + 12500
        orders.last.status.must_equal orders.last.histories.first.status
        orders.last.status.must_equal 'received'
        orders.last.payment_status.must_equal 'payment received'
        orders.last.delivery.class.must_equal Gcfs::Wrapper::Api::OrderDelivery
          assert orders.last.delivery.kind_of?(Gcfs::Wrapper::Api::OrderDelivery)
        orders.last.delivery.courier_name.must_equal 'JNE'
        orders.last.delivery.receipt_number.must_equal 'CGKS301072156314'
        orders.last.receive.class.must_equal Gcfs::Wrapper::Api::OrderReceive
          assert orders.last.receive.kind_of?(Gcfs::Wrapper::Api::OrderReceive)
        orders.last.receive.receiver.must_equal 'Maye Effertz'
        orders.last.receive.received_at.must_equal Time.zone.parse('2015-04-24 10:10:08' + ' ' + Gcfs::Wrapper::Api.options[:timezone])
      end
    end

    it 'raise errors if token invalid' do
      VCR.use_cassette('order/administrator/list/all/token_invalid') do
        Gcfs::Wrapper::Api.access_token = '1234567890ASDFGHJKLMNBVCX'

        orders = Gcfs::Wrapper::Api::Order.all force: true, page: 253
        
        orders.class.must_equal Gcfs::Wrapper::Api::Error
        assert orders.kind_of?(Gcfs::Wrapper::Api::Error)

        orders.message.must_equal 'invalid_request'
      end
    end

    it 'create order' do
      VCR.use_cassette('order/administrator/list/all/success') do
        before_orders = Gcfs::Wrapper::Api::Order.all force: true, page: 6

        VCR.use_cassette('order/administrator/create/success') do
          params = {
            "description": "Pembelian Voucher",
            "recepient": {
              "name": "Mr. Burnice Anderson",
              "email": "enrique.prosacco@kulas.net",
              "phone_number": "947.962.2387",
              "address": "Rasuna Said 10",
              "city": "dki jakarta",
              "zip_code": "12950",
              "notes": "-"
            },
            "items":[
              {
                "id": 1,
                "variants": [{
                  "id": 1,
                  "quantity": 10
                },
                {
                  "id": 2,
                  "quantity": 10
                }]
              },
              {
                "id": 2,
                "variants": [{
                  "id": 3,
                  "quantity": 10
                },
                {
                  "id": 4,
                  "quantity": 10
                }]
              }
            ],
            "metadata":{
              "user":{
                "id": 1,
                "name": "Admin"
              }
            }
          }
          order = Gcfs::Wrapper::Api::Order.create params

          VCR.use_cassette('order/administrator/create/success/all') do
            orders = Gcfs::Wrapper::Api::Order.all force: true, page: 6

            orders.size.must_equal 4
            orders.total_count.must_equal 104
            orders.total_pages.must_equal 6
            orders.current_page.must_equal 6

            orders.total_count.must_equal (before_orders.total_count + 1)

            orders.last.class.must_equal Gcfs::Wrapper::Api::Order
            assert orders.last.kind_of?(Gcfs::Wrapper::Api::Order)

            orders.last.id.must_equal 104
            orders.last.transaction_id.must_equal 'd1cIui5lmW'
            orders.last.invoice_number.must_equal nil
            orders.last.description.must_equal 'Pembelian Voucher'

            orders.last.client.class.must_equal Gcfs::Wrapper::Api::Client
            orders.last.client.name.must_equal 'Giftcard'
            orders.last.client.address.must_equal 'giftcard.co.id'
            orders.last.client.billing_address.must_equal 'giftcard.co.id'

            orders.last.recepient.class.must_equal Gcfs::Wrapper::Api::Recepient
            orders.last.recepient.name.must_equal 'Mr. Burnice Anderson'
            orders.last.recepient.email.must_equal 'enrique.prosacco@kulas.net'
            orders.last.recepient.phone_number.must_equal '947.962.2387'
            orders.last.recepient.address.must_equal 'Rasuna Said 10 DKI JAKARTA 12950'
            orders.last.recepient.city.must_equal 'DKI JAKARTA'
            orders.last.recepient.zip_code.must_equal '12950'
            orders.last.recepient.notes.must_equal "-"

            orders.last.items.each do |item|
              item.class.must_equal Gcfs::Wrapper::Api::OrderItem
              assert item.kind_of?(Gcfs::Wrapper::Api::OrderItem)
            end

            orders.last.items.first.id.must_equal 1
            orders.last.items.first.sku.must_equal '0101'
            orders.last.items.first.name.must_equal 'Fintone'

            orders.last.items.first.variants.each do |variant|
              variant.class.must_equal Gcfs::Wrapper::Api::OrderItemVariant
              assert variant.kind_of?(Gcfs::Wrapper::Api::OrderItemVariant)
            end

            orders.last.items.first.variants.first.id.must_equal 1
            orders.last.items.first.variants.first.sku.must_equal '010101'
            orders.last.items.first.variants.first.description.must_equal 'Fintone 50rb'
            orders.last.items.first.variants.first.quantity.must_equal 10
            orders.last.items.first.variants.first.price.must_equal 45000
            orders.last.items.first.variants.first.nominal.must_equal 50000
            orders.last.items.first.variants.first.subtotal.must_equal 450000

            orders.last.histories.each do |history|
              history.class.must_equal Gcfs::Wrapper::Api::OrderHistory
              assert history.kind_of?(Gcfs::Wrapper::Api::OrderHistory)
            end

            orders.last.histories.first.id.must_equal 117
            orders.last.histories.first.status.must_equal 'new order'
            orders.last.histories.first.description.must_equal 'Order #d1cIui5lmW'
            metadata = {"user"=>{"id"=>1, "name"=>"Admin"}}
            orders.last.histories.first.metadata.must_equal metadata

            total = 0
            orders.last.items.each do |item|
              item.variants.each do |variant|
                total += variant.subtotal
              end
            end
            orders.last.total.must_equal total
            orders.last.shipping_fee.must_equal 0
            orders.last.total_with_shipping.must_equal total + 0
            orders.last.status.must_equal orders.last.histories.first.status
            orders.last.status.must_equal 'new order'
            orders.last.payment_status.must_equal 'outstanding'
          end
        end
      end
    end

    it 'raise errors if quantity more than stock when create order' do
      VCR.use_cassette('order/administrator/create/success/all') do
        before_orders = Gcfs::Wrapper::Api::Order.all force: true, page: 6

        VCR.use_cassette('order/administrator/create/failed_quantity_more_than_stock') do
          params = {
            "description": "Pembelian Voucher",
            "recepient": {
              "name": "Mr. Burnice Anderson",
              "email": "enrique.prosacco@kulas.net",
              "phone_number": "947.962.2387",
              "address": "Rasuna Said 10",
              "city": "dki jakarta",
              "zip_code": "12950",
              "notes": "-"
            },
            "items":[
              {
                "id": 10,
                "variants": [{
                  "id": 21,
                  "quantity": 10
                }]
              }
            ],
            "metadata":{
              "user":{
                "id": 1,
                "name": "Admin"
              }
            }
          }
          order = Gcfs::Wrapper::Api::Order.create params

          order.class.must_equal Gcfs::Wrapper::Api::Error
          assert order.kind_of?(Gcfs::Wrapper::Api::Error)

          order.message.must_include('quantity insufficient stock')
          order.message.must_include('quantity out of stock')

          VCR.use_cassette('order/administrator/create/failed/all') do
            orders = Gcfs::Wrapper::Api::Order.all force: true, page: 6

            orders.size.must_equal 4
            orders.total_count.must_equal 104
            orders.total_pages.must_equal 6
            orders.current_page.must_equal 6

            orders.total_count.must_equal before_orders.total_count
          end
        end
      end

    end

    it 'raise errors if params not filled when create order' do
      VCR.use_cassette('order/administrator/create/success/all') do
        before_orders = Gcfs::Wrapper::Api::Order.all force: true, page: 6

        VCR.use_cassette('order/administrator/create/failed_params_not_filled') do
          order = Gcfs::Wrapper::Api::Order.create

          order.class.must_equal Gcfs::Wrapper::Api::Error
          assert order.kind_of?(Gcfs::Wrapper::Api::Error)

          order.message.must_include('description is missing')
          order.message.must_include('recepient is missing')
          order.message.must_include('recepient[name] is missing')
          order.message.must_include('recepient[address] is missing')
          order.message.must_include('items is missing')
          order.message.must_include('metadata is missing')
          order.message.must_include('metadata[user] is missing')
          order.message.must_include('metadata[user][id] is missing')
          order.message.must_include('metadata[user][name] is missing')

          VCR.use_cassette('order/administrator/create/failed/all') do
            orders = Gcfs::Wrapper::Api::Order.all force: true, page: 6

            orders.size.must_equal 4
            orders.total_count.must_equal 104
            orders.total_pages.must_equal 6
            orders.current_page.must_equal 6

            orders.total_count.must_equal before_orders.total_count
          end
        end
      end

    end

   it 'raise errors if params items not filled when create order' do
      VCR.use_cassette('order/administrator/create/success/all') do
        before_orders = Gcfs::Wrapper::Api::Order.all force: true, page: 6

        VCR.use_cassette('order/administrator/create/failed_params_items_not_filled') do
          params = {
            "description": "Pembelian Voucher",
            "recepient": {
              "name": "Mr. Burnice Anderson",
              "email": "enrique.prosacco@kulas.net",
              "phone_number": "947.962.2387",
              "address": "Rasuna Said 10",
              "city": "dki jakarta",
              "zip_code": "12950",
              "notes": "-"
            },
            "items":[],
            "metadata":{
              "user":{
                "id": 1,
                "name": "Admin"
              }
            }
          }
          order = Gcfs::Wrapper::Api::Order.create params

          order.class.must_equal Gcfs::Wrapper::Api::Error
          assert order.kind_of?(Gcfs::Wrapper::Api::Error)

          order.message.must_include('items is missing')

          VCR.use_cassette('order/administrator/create/failed/all') do
            orders = Gcfs::Wrapper::Api::Order.all force: true, page: 6

            orders.size.must_equal 4
            orders.total_count.must_equal 104
            orders.total_pages.must_equal 6
            orders.current_page.must_equal 6

            orders.total_count.must_equal before_orders.total_count
          end
        end
      end

    end

    it 'raise errors if item id wrong from different Client when create order' do
      VCR.use_cassette('order/administrator/create/success/all') do
        before_orders = Gcfs::Wrapper::Api::Order.all force: true, page: 6

        VCR.use_cassette('item/administrator/list/all/success') do
          items = Gcfs::Wrapper::Api::Item.all force: true

          Gcfs::Wrapper::Api::configure do |config|
            config.key      = '59tXpmSARVZ5rTzentMoDmwl6Mk'
            config.secret   = 'uMO7PoP7Z1q4EpvNPdBkXbI0ylw'
            config.username = 'mutouzi@gmail.com'
            config.password = '12345678'
          end
          VCR.use_cassette('token/request_token/administrator/different_client/success') do
            @token = Gcfs::Wrapper::Api::Token.request
          end

          VCR.use_cassette('order/administrator/create/failed_item_id_wrong_from_different_client') do
            params = {
              "description": "Pembelian Voucher",
              "recepient": {
                "name": "Mr. Burnice Anderson",
                "email": "enrique.prosacco@kulas.net",
                "phone_number": "947.962.2387",
                "address": "Rasuna Said 10",
                "city": "dki jakarta",
                "zip_code": "12950",
                "notes": "-"
              },
              "items":[
                {
                  "id": 10,
                  "variants": [{
                    "id": 21,
                    "quantity": 10
                  }]
                }
              ],
              "metadata":{
                "user":{
                  "id": 1,
                  "name": "Admin"
                }
              }
            }
            order = Gcfs::Wrapper::Api::Order.create params

            order.message.must_include("Item ID "+10.to_s+" doesn't Exist")

            VCR.use_cassette('order/administrator/create/failed/all') do
              orders = Gcfs::Wrapper::Api::Order.all force: true, page: 6

              orders.size.must_equal 4
              orders.total_count.must_equal 104
              orders.total_pages.must_equal 6
              orders.current_page.must_equal 6

              orders.total_count.must_equal before_orders.total_count
            end
          end

        end

      end

    end

    it 'edit order status to delivered' do
      VCR.use_cassette('order/administrator/create/success/all') do
        before_orders = Gcfs::Wrapper::Api::Order.all force: true, page: 6

        VCR.use_cassette('order/administrator/update/success') do
          params = {
            "status": "delivered",
            "delivery":{
              "courier_name": "JNE",
              "receipt_number": "CGKS301072156314"
            },
            "metadata":{
              "user":{
                "id": 1,
                "name": "Admin"
              }
            }
          }
          order = Gcfs::Wrapper::Api::Order.update before_orders.last.id, params

          VCR.use_cassette('order/administrator/update/success/all') do
            orders = Gcfs::Wrapper::Api::Order.all force: true, page: 6

            orders.size.must_equal 4
            orders.total_count.must_equal 104
            orders.total_pages.must_equal 6
            orders.current_page.must_equal 6

            orders.total_count.must_equal before_orders.total_count

            orders.last.class.must_equal Gcfs::Wrapper::Api::Order
            assert orders.last.kind_of?(Gcfs::Wrapper::Api::Order)

            orders.last.id.must_equal 104
            orders.last.transaction_id.must_equal 'd1cIui5lmW'
            orders.last.invoice_number.must_equal nil
            orders.last.description.must_equal 'Pembelian Voucher'

            orders.last.client.class.must_equal Gcfs::Wrapper::Api::Client
            orders.last.client.name.must_equal 'Giftcard'
            orders.last.client.address.must_equal 'giftcard.co.id'
            orders.last.client.billing_address.must_equal 'giftcard.co.id'

            orders.last.recepient.class.must_equal Gcfs::Wrapper::Api::Recepient
            orders.last.recepient.name.must_equal 'Mr. Burnice Anderson'
            orders.last.recepient.email.must_equal 'enrique.prosacco@kulas.net'
            orders.last.recepient.phone_number.must_equal '947.962.2387'
            orders.last.recepient.address.must_equal 'Rasuna Said 10 DKI JAKARTA 12950'
            orders.last.recepient.city.must_equal 'DKI JAKARTA'
            orders.last.recepient.zip_code.must_equal '12950'
            orders.last.recepient.notes.must_equal "-"

            orders.last.items.each do |item|
              item.class.must_equal Gcfs::Wrapper::Api::OrderItem
              assert item.kind_of?(Gcfs::Wrapper::Api::OrderItem)
            end

            orders.last.items.first.id.must_equal 1
            orders.last.items.first.sku.must_equal '0101'
            orders.last.items.first.name.must_equal 'Fintone'

            orders.last.items.first.variants.each do |variant|
              variant.class.must_equal Gcfs::Wrapper::Api::OrderItemVariant
              assert variant.kind_of?(Gcfs::Wrapper::Api::OrderItemVariant)
            end

            orders.last.items.first.variants.first.id.must_equal 1
            orders.last.items.first.variants.first.sku.must_equal '010101'
            orders.last.items.first.variants.first.description.must_equal 'Fintone 50rb'
            orders.last.items.first.variants.first.quantity.must_equal 10
            orders.last.items.first.variants.first.price.must_equal 45000
            orders.last.items.first.variants.first.nominal.must_equal 50000
            orders.last.items.first.variants.first.subtotal.must_equal 450000

            orders.last.histories.each do |history|
              history.class.must_equal Gcfs::Wrapper::Api::OrderHistory
              assert history.kind_of?(Gcfs::Wrapper::Api::OrderHistory)
            end

            orders.last.histories.first.id.must_equal 118
            orders.last.histories.first.status.must_equal 'delivered'
            orders.last.histories.first.description.must_equal 'JNE with resi CGKS301072156314'
            metadata = {"user"=>{"id"=>1, "name"=>"Admin"}}
            orders.last.histories.first.metadata.must_equal metadata

            total = 0
            orders.last.items.each do |item|
              item.variants.each do |variant|
                total += variant.subtotal
              end
            end
            orders.last.total.must_equal total
            orders.last.shipping_fee.must_equal 0
            orders.last.total_with_shipping.must_equal total + 0
            orders.last.status.must_equal orders.last.histories.first.status
            orders.last.status.must_equal 'delivered'
            orders.last.payment_status.must_equal 'outstanding'
            orders.last.delivery.class.must_equal Gcfs::Wrapper::Api::OrderDelivery
            assert orders.last.delivery.kind_of?(Gcfs::Wrapper::Api::OrderDelivery)
            orders.last.delivery.courier_name.must_equal 'JNE'
            orders.last.delivery.receipt_number.must_equal 'CGKS301072156314'
          end
        end

      end

    end

    it 'edit order status to received' do
      VCR.use_cassette('order/administrator/update/success/all') do
        before_orders = Gcfs::Wrapper::Api::Order.all force: true, page: 6

        VCR.use_cassette('order/administrator/update/received/success') do
          params = {
            "status": "received",
            "receive":{
              "receiver": "Julita",
              "received_at": "2015-03-12 08:07:52"
            },
            "metadata":{
              "user":{
                "id": 1,
                "name": "Admin"
              }
            }
          }
          order = Gcfs::Wrapper::Api::Order.update before_orders.last.id, params

          VCR.use_cassette('order/administrator/update/received/success/all') do
            orders = Gcfs::Wrapper::Api::Order.all force: true, page: 6

            orders.size.must_equal 4
            orders.total_count.must_equal 104
            orders.total_pages.must_equal 6
            orders.current_page.must_equal 6

            orders.total_count.must_equal before_orders.total_count

            orders.last.class.must_equal Gcfs::Wrapper::Api::Order
            assert orders.last.kind_of?(Gcfs::Wrapper::Api::Order)

            orders.last.id.must_equal 104
            orders.last.transaction_id.must_equal 'd1cIui5lmW'
            orders.last.invoice_number.must_equal nil
            orders.last.description.must_equal 'Pembelian Voucher'

            orders.last.client.class.must_equal Gcfs::Wrapper::Api::Client
            orders.last.client.name.must_equal 'Giftcard'
            orders.last.client.address.must_equal 'giftcard.co.id'
            orders.last.client.billing_address.must_equal 'giftcard.co.id'

            orders.last.recepient.class.must_equal Gcfs::Wrapper::Api::Recepient
            orders.last.recepient.name.must_equal 'Mr. Burnice Anderson'
            orders.last.recepient.email.must_equal 'enrique.prosacco@kulas.net'
            orders.last.recepient.phone_number.must_equal '947.962.2387'
            orders.last.recepient.address.must_equal 'Rasuna Said 10 DKI JAKARTA 12950'
            orders.last.recepient.city.must_equal 'DKI JAKARTA'
            orders.last.recepient.zip_code.must_equal '12950'
            orders.last.recepient.notes.must_equal "-"

            orders.last.items.each do |item|
              item.class.must_equal Gcfs::Wrapper::Api::OrderItem
              assert item.kind_of?(Gcfs::Wrapper::Api::OrderItem)
            end

            orders.last.items.first.id.must_equal 1
            orders.last.items.first.sku.must_equal '0101'
            orders.last.items.first.name.must_equal 'Fintone'

            orders.last.items.first.variants.each do |variant|
              variant.class.must_equal Gcfs::Wrapper::Api::OrderItemVariant
              assert variant.kind_of?(Gcfs::Wrapper::Api::OrderItemVariant)
            end

            orders.last.items.first.variants.first.id.must_equal 1
            orders.last.items.first.variants.first.sku.must_equal '010101'
            orders.last.items.first.variants.first.description.must_equal 'Fintone 50rb'
            orders.last.items.first.variants.first.quantity.must_equal 10
            orders.last.items.first.variants.first.price.must_equal 45000
            orders.last.items.first.variants.first.nominal.must_equal 50000
            orders.last.items.first.variants.first.subtotal.must_equal 450000

            orders.last.histories.each do |history|
              history.class.must_equal Gcfs::Wrapper::Api::OrderHistory
              assert history.kind_of?(Gcfs::Wrapper::Api::OrderHistory)
            end

            orders.last.histories.first.id.must_equal 119
            orders.last.histories.first.status.must_equal 'received'
            orders.last.histories.first.description.must_equal 'Received by Julita at 2015-03-12 08:07:52'
            metadata = {"user"=>{"id"=>1, "name"=>"Admin"}}
            orders.last.histories.first.metadata.must_equal metadata

            total = 0
            orders.last.items.each do |item|
              item.variants.each do |variant|
                total += variant.subtotal
              end
            end
            orders.last.total.must_equal total
            orders.last.shipping_fee.must_equal 0
            orders.last.total_with_shipping.must_equal total + 0
            orders.last.status.must_equal orders.last.histories.first.status
            orders.last.status.must_equal 'received'
            orders.last.payment_status.must_equal 'outstanding'
            orders.last.delivery.courier_name.must_equal 'JNE'
            orders.last.delivery.receipt_number.must_equal 'CGKS301072156314'
            orders.last.receive.class.must_equal Gcfs::Wrapper::Api::OrderReceive
              assert orders.last.receive.kind_of?(Gcfs::Wrapper::Api::OrderReceive)
            orders.last.receive.receiver.must_equal 'Julita'
            orders.last.receive.received_at.must_equal Time.zone.parse('2015-03-12 08:07:52' + ' ' + Gcfs::Wrapper::Api.options[:timezone])
          end
        end

      end

    end

    it 'raise errors if params not filled when edit order status' do
      VCR.use_cassette('order/administrator/update/received/success/all') do
        before_orders = Gcfs::Wrapper::Api::Order.all force: true, page: 6

        VCR.use_cassette('order/administrator/update/failed_params_not_filled') do
          order = Gcfs::Wrapper::Api::Order.update before_orders.last.id

          VCR.use_cassette('order/administrator/update/failed_params_not_filled/all') do
            orders = Gcfs::Wrapper::Api::Order.all force: true, page: 6

            orders.size.must_equal 4
            orders.total_count.must_equal 104
            orders.total_pages.must_equal 6
            orders.current_page.must_equal 6

            orders.total_count.must_equal before_orders.total_count

            order.class.must_equal Gcfs::Wrapper::Api::Error
            assert order.kind_of?(Gcfs::Wrapper::Api::Error)

            order.message.must_include('status is missing')
            order.message.must_include('status does not have a valid value')
            order.message.must_include('metadata is missing')
            order.message.must_include('metadata[user] is missing')
            order.message.must_include('metadata[user][id] is missing')
            order.message.must_include('metadata[user][name] is missing')
          end
        end

      end

    end

    it 'raise errors if params delivery not filled when edit order status to delivered' do
      VCR.use_cassette('order/administrator/update/received/success/all') do
        before_orders = Gcfs::Wrapper::Api::Order.all force: true, page: 6

        VCR.use_cassette('order/administrator/update/failed_params_delivery_not_filled') do
          params = {
            "status": "delivered",
            "metadata":{
              "user":{
                "id": 1,
                "name": "Admin"
              }
            }
          }
          order = Gcfs::Wrapper::Api::Order.update before_orders.last.id, params
            
          order.message.must_include('delivery is missing')

        end

      end

    end

    it 'raise errors if params delivery[courier_name] not filled when edit order status to delivered' do
      VCR.use_cassette('order/administrator/update/received/success/all') do
        before_orders = Gcfs::Wrapper::Api::Order.all force: true, page: 6

        VCR.use_cassette('order/administrator/update/failed_params_delivery[courier_name]_not_filled') do
          params = {
            "status": "delivered",
            "delivery":{
              "receipt_number": "CGKS301072156314"
            },
            "metadata":{
              "user":{
                "id": 1,
                "name": "Admin"
              }
            }
          }
          order = Gcfs::Wrapper::Api::Order.update before_orders.last.id, params
            
          order.message.must_include('delivery[courier_name] is missing')

        end

      end
    end

    it 'raise errors if params delivery[receipt_number] not filled when edit order status to delivered' do
      VCR.use_cassette('order/administrator/update/received/success/all') do
        before_orders = Gcfs::Wrapper::Api::Order.all force: true, page: 6

        VCR.use_cassette('order/administrator/update/failed_params_delivery[receipt_number]_not_filled') do
          params = {
            "status": "delivered",
            "delivery":{
              "courier_name": "JNE"
            },
            "metadata":{
              "user":{
                "id": 1,
                "name": "Admin"
              }
            }
          }
          order = Gcfs::Wrapper::Api::Order.update before_orders.last.id, params
            
          order.message.must_include('delivery[receipt_number] is missing')

        end

      end
    end

    it 'raise errors if params receive not filled when edit order status to received' do
      VCR.use_cassette('order/administrator/update/received/success/all') do
        before_orders = Gcfs::Wrapper::Api::Order.all force: true, page: 6

        VCR.use_cassette('order/administrator/update/failed_params_receive_not_filled') do
          params = {
            "status": "received",
            "metadata":{
              "user":{
                "id": 1,
                "name": "Admin"
              }
            }
          }
          order = Gcfs::Wrapper::Api::Order.update before_orders.last.id, params
            
          order.message.must_include('receive is missing')

        end

      end

    end

    it 'raise errors if params receive[receiver] not filled when edit order status to received' do
      VCR.use_cassette('order/administrator/update/received/success/all') do
        before_orders = Gcfs::Wrapper::Api::Order.all force: true, page: 6

        VCR.use_cassette('order/administrator/update/failed_params_receive[receiver]_not_filled') do
          params = {
            "status": "received",
            "receive":{
              "received_at": "2015-03-12 08:07:52"
            },
            "metadata":{
              "user":{
                "id": 1,
                "name": "Admin"
              }
            }
          }
          order = Gcfs::Wrapper::Api::Order.update before_orders.last.id, params
            
          order.message.must_include('receive[receiver] is missing')

        end

      end
    end

    it 'raise errors if params receive[received_at] not filled when edit order status to received' do
      VCR.use_cassette('order/administrator/update/received/success/all') do
        before_orders = Gcfs::Wrapper::Api::Order.all force: true, page: 6

        VCR.use_cassette('order/administrator/update/failed_params_receive[received_at]_not_filled') do
          params = {
            "status": "received",
            "receive":{
              "receiver": "Julita",
            },
            "metadata":{
              "user":{
                "id": 1,
                "name": "Admin"
              }
            }
          }
          order = Gcfs::Wrapper::Api::Order.update before_orders.last.id, params
            
          order.message.must_include('receive[received_at] is missing')

        end

      end
    end

    it 'raise errors if params status wrong when edit order status' do
      VCR.use_cassette('order/administrator/update/received/success/all') do
        before_orders = Gcfs::Wrapper::Api::Order.all force: true, page: 6

        VCR.use_cassette('order/administrator/update/failed_params_status_wrong') do
          params = {
            "status": "ABCDE",
            "metadata":{
              "user":{
                "id": 1,
                "name": "Admin"
              }
            }
          }
          order = Gcfs::Wrapper::Api::Order.update before_orders.last.id, params
            
          order.message.must_include('status does not have a valid value')

        end

      end
    end

    it 'show order' do
      VCR.use_cassette('order/administrator/update/received/success/all') do
        orders = Gcfs::Wrapper::Api::Order.all force: true, page: 6

        VCR.use_cassette('order/administrator/show/'+orders.last.id.to_s+'/success') do
          order = Gcfs::Wrapper::Api::Order.find(orders.last.id)

          order.class.must_equal Gcfs::Wrapper::Api::Order
          assert order.kind_of?(Gcfs::Wrapper::Api::Order)

          orders.last.id.must_equal 104
            orders.last.transaction_id.must_equal 'd1cIui5lmW'
            orders.last.invoice_number.must_equal nil
            orders.last.description.must_equal 'Pembelian Voucher'

            orders.last.client.class.must_equal Gcfs::Wrapper::Api::Client
            orders.last.client.name.must_equal 'Giftcard'
            orders.last.client.address.must_equal 'giftcard.co.id'
            orders.last.client.billing_address.must_equal 'giftcard.co.id'

            orders.last.recepient.class.must_equal Gcfs::Wrapper::Api::Recepient
            orders.last.recepient.name.must_equal 'Mr. Burnice Anderson'
            orders.last.recepient.email.must_equal 'enrique.prosacco@kulas.net'
            orders.last.recepient.phone_number.must_equal '947.962.2387'
            orders.last.recepient.address.must_equal 'Rasuna Said 10 DKI JAKARTA 12950'
            orders.last.recepient.city.must_equal 'DKI JAKARTA'
            orders.last.recepient.zip_code.must_equal '12950'
            orders.last.recepient.notes.must_equal "-"

            orders.last.items.each do |item|
              item.class.must_equal Gcfs::Wrapper::Api::OrderItem
              assert item.kind_of?(Gcfs::Wrapper::Api::OrderItem)
            end

            orders.last.items.first.id.must_equal 1
            orders.last.items.first.sku.must_equal '0101'
            orders.last.items.first.name.must_equal 'Fintone'

            orders.last.items.first.variants.each do |variant|
              variant.class.must_equal Gcfs::Wrapper::Api::OrderItemVariant
              assert variant.kind_of?(Gcfs::Wrapper::Api::OrderItemVariant)
            end

            orders.last.items.first.variants.first.id.must_equal 1
            orders.last.items.first.variants.first.sku.must_equal '010101'
            orders.last.items.first.variants.first.description.must_equal 'Fintone 50rb'
            orders.last.items.first.variants.first.quantity.must_equal 10
            orders.last.items.first.variants.first.price.must_equal 45000
            orders.last.items.first.variants.first.nominal.must_equal 50000
            orders.last.items.first.variants.first.subtotal.must_equal 450000

          order.histories.each do |history|
            history.class.must_equal Gcfs::Wrapper::Api::OrderHistory
            assert history.kind_of?(Gcfs::Wrapper::Api::OrderHistory)
          end

          order.histories.first.id.must_equal 119
          order.histories.first.status.must_equal 'received'
          order.histories.first.description.must_equal 'Received by Julita at 2015-03-12 08:07:52'
          metadata = {"user"=>{"id"=>1, "name"=>"Admin"}}
          order.histories.first.metadata.must_equal metadata

          total = 0
          order.items.each do |item|
            item.variants.each do |variant|
              total += variant.subtotal
            end
          end
          order.total.must_equal total
          order.shipping_fee.must_equal 0
          order.total_with_shipping.must_equal total + 0
          order.status.must_equal order.histories.first.status
          order.status.must_equal 'received'
          order.payment_status.must_equal 'outstanding'
          order.delivery.courier_name.must_equal 'JNE'
          order.delivery.receipt_number.must_equal 'CGKS301072156314'
          order.receive.class.must_equal Gcfs::Wrapper::Api::OrderReceive
            assert order.receive.kind_of?(Gcfs::Wrapper::Api::OrderReceive)
          order.receive.receiver.must_equal 'Julita'
          order.receive.received_at.must_equal Time.zone.parse('2015-03-12 08:07:52' + ' ' + Gcfs::Wrapper::Api.options[:timezone])
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

    it "list of orders" do
      VCR.use_cassette('order/developer/list/all/success') do
        orders = Gcfs::Wrapper::Api::Order.all force: true

        orders.size.must_equal 14
        orders.total_count.must_equal 14
        orders.total_pages.must_equal 1
        orders.current_page.must_equal 1

        orders.last.class.must_equal Gcfs::Wrapper::Api::Order
        assert orders.last.kind_of?(Gcfs::Wrapper::Api::Order)

        orders.last.id.must_equal 118
        orders.last.transaction_id.must_equal '260UWfRO8D'
        orders.last.invoice_number.must_equal nil
        orders.last.description.must_equal 'Adipisci perferendis dolor est labore.'

        orders.last.client.class.must_equal Gcfs::Wrapper::Api::Client
        orders.last.client.name.must_equal 'Feil-Baumbach'
        orders.last.client.address.must_equal '33593 Cassie Branch New Brianchester SD 66436-1797'
        orders.last.client.billing_address.must_equal '955 Afton Canyon Stoltenbergfurt DE 25374-5680'

        orders.last.recepient.class.must_equal Gcfs::Wrapper::Api::Recepient
        orders.last.recepient.name.must_equal 'Jakayla Lynch Jr.'
        orders.last.recepient.email.must_equal 'lynch.jakayla.jr@altenwerth.com'
        orders.last.recepient.phone_number.must_equal '1-756-516-8353'
        orders.last.recepient.address.must_equal '8477 Mante Forge West Emmieburgh 03/01 KEDIRI 79511'
        orders.last.recepient.city.must_equal 'KEDIRI'
        orders.last.recepient.zip_code.must_equal '79511'
        orders.last.recepient.notes.must_equal "Inventore necessitatibus molestiae voluptas. Blanditiis sit quos id nihil ut."
        
        orders.last.items.each do |item|
          item.class.must_equal Gcfs::Wrapper::Api::OrderItem
          assert item.kind_of?(Gcfs::Wrapper::Api::OrderItem)
        end

        orders.last.items.first.id.must_equal 7
        orders.last.items.first.sku.must_equal '0407'
        orders.last.items.first.name.must_equal 'Tampflex'
        
        orders.last.items.first.variants.each do |variant|
          variant.class.must_equal Gcfs::Wrapper::Api::OrderItemVariant
          assert variant.kind_of?(Gcfs::Wrapper::Api::OrderItemVariant)
        end

        orders.last.items.first.variants.first.id.must_equal 14
        orders.last.items.first.variants.first.sku.must_equal '040714'
        orders.last.items.first.variants.first.description.must_equal 'Tampflex 100rb'
        orders.last.items.first.variants.first.quantity.must_equal 6
        orders.last.items.first.variants.first.price.must_equal 90000
        orders.last.items.first.variants.first.nominal.must_equal 100000
        orders.last.items.first.variants.first.subtotal.must_equal 540000

        orders.last.histories.each do |history|
          history.class.must_equal Gcfs::Wrapper::Api::OrderHistory
          assert history.kind_of?(Gcfs::Wrapper::Api::OrderHistory)
        end

        orders.last.histories.first.id.must_equal 135
        orders.last.histories.first.status.must_equal 'new order'
        orders.last.histories.first.description.must_equal 'Order #260UWfRO8D'
        metadata = nil
        orders.last.histories.first.metadata.must_equal metadata

        total = 0
        orders.last.items.each do |item|
          item.variants.each do |variant|
            total += variant.subtotal
          end
        end
        orders.last.total.must_equal total
        orders.last.shipping_fee.must_equal 23500
        orders.last.total_with_shipping.must_equal total + 23500
        orders.last.status.must_equal orders.last.histories.first.status
        orders.last.status.must_equal 'new order'
        orders.last.payment_status.must_equal 'outstanding'
      end
    end

    it 'raise errors if token invalid' do
      VCR.use_cassette('order/developer/list/all/token_invalid') do
        Gcfs::Wrapper::Api.access_token = '1234567890ASDFGHJKLMNBVCX'

        orders = Gcfs::Wrapper::Api::Order.all force: true, page: 78
        
        orders.class.must_equal Gcfs::Wrapper::Api::Error
        assert orders.kind_of?(Gcfs::Wrapper::Api::Error)

        orders.message.must_equal 'invalid_request'
      end
    end

    it 'create order' do
      VCR.use_cassette('order/developer/list/all/success') do
        before_orders = Gcfs::Wrapper::Api::Order.all force: true

        VCR.use_cassette('order/developer/create/success') do
          params = {
            "description": "Pembelian Voucher",
            "recepient": {
              "name": "Mr. Burnice Anderson",
              "email": "enrique.prosacco@kulas.net",
              "phone_number": "947.962.2387",
              "address": "Rasuna Said 10",
              "city": "dki jakarta",
              "zip_code": "12950",
              "notes": "-"
            },
            "items":[
              {
                "id": 1,
                "variants": [{
                  "id": 1,
                  "quantity": 10
                },
                {
                  "id": 2,
                  "quantity": 10
                }]
              },
              {
                "id": 2,
                "variants": [{
                  "id": 3,
                  "quantity": 10
                },
                {
                  "id": 4,
                  "quantity": 10
                }]
              }
            ],
            "metadata":{
              "user":{
                "id": 1,
                "name": "mutouzi@gmail.com"
              }
            }
          }
          order = Gcfs::Wrapper::Api::Order.create params

          VCR.use_cassette('order/developer/create/success/all') do
            orders = Gcfs::Wrapper::Api::Order.all force: true, page: 1

            orders.size.must_equal 15
            orders.total_count.must_equal 15
            orders.total_pages.must_equal 1
            orders.current_page.must_equal 1

            orders.total_count.must_equal (before_orders.total_count + 1)

            orders.last.class.must_equal Gcfs::Wrapper::Api::Order
            assert orders.last.kind_of?(Gcfs::Wrapper::Api::Order)

            orders.last.id.must_equal 119
            orders.last.transaction_id.must_equal 'qilLP5ZbIp'
            orders.last.invoice_number.must_equal nil
            orders.last.description.must_equal 'Pembelian Voucher'

            orders.last.client.class.must_equal Gcfs::Wrapper::Api::Client
            orders.last.client.name.must_equal 'Feil-Baumbach'
            orders.last.client.address.must_equal '33593 Cassie Branch New Brianchester SD 66436-1797'
            orders.last.client.billing_address.must_equal '955 Afton Canyon Stoltenbergfurt DE 25374-5680'

            orders.last.recepient.class.must_equal Gcfs::Wrapper::Api::Recepient
            orders.last.recepient.name.must_equal 'Mr. Burnice Anderson'
            orders.last.recepient.email.must_equal 'enrique.prosacco@kulas.net'
            orders.last.recepient.phone_number.must_equal '947.962.2387'
            orders.last.recepient.address.must_equal 'Rasuna Said 10 DKI JAKARTA 12950'
            orders.last.recepient.city.must_equal 'DKI JAKARTA'
            orders.last.recepient.zip_code.must_equal '12950'
            orders.last.recepient.notes.must_equal "-"

            orders.last.items.each do |item|
              item.class.must_equal Gcfs::Wrapper::Api::OrderItem
              assert item.kind_of?(Gcfs::Wrapper::Api::OrderItem)
            end

            orders.last.items.first.id.must_equal 1
            orders.last.items.first.sku.must_equal '0101'
            orders.last.items.first.name.must_equal 'Fintone'

            orders.last.items.first.variants.each do |variant|
              variant.class.must_equal Gcfs::Wrapper::Api::OrderItemVariant
              assert variant.kind_of?(Gcfs::Wrapper::Api::OrderItemVariant)
            end

            orders.last.items.first.variants.first.id.must_equal 1
            orders.last.items.first.variants.first.sku.must_equal '010101'
            orders.last.items.first.variants.first.description.must_equal 'Fintone 50rb'
            orders.last.items.first.variants.first.quantity.must_equal 10
            orders.last.items.first.variants.first.price.must_equal 45000
            orders.last.items.first.variants.first.nominal.must_equal 50000
            orders.last.items.first.variants.first.subtotal.must_equal 450000

            orders.last.histories.each do |history|
              history.class.must_equal Gcfs::Wrapper::Api::OrderHistory
              assert history.kind_of?(Gcfs::Wrapper::Api::OrderHistory)
            end

            orders.last.histories.first.id.must_equal 136
            orders.last.histories.first.status.must_equal 'new order'
            orders.last.histories.first.description.must_equal 'Order #qilLP5ZbIp'
            metadata = {"user"=>{"id"=>1, "name"=>"mutouzi@gmail.com"}}
            orders.last.histories.first.metadata.must_equal metadata

            total = 0
            orders.last.items.each do |item|
              item.variants.each do |variant|
                total += variant.subtotal
              end
            end
            orders.last.total.must_equal total
            orders.last.shipping_fee.must_equal 0
            orders.last.total_with_shipping.must_equal total + 0
            orders.last.status.must_equal orders.last.histories.first.status
            orders.last.status.must_equal 'new order'
            orders.last.payment_status.must_equal 'outstanding'
          end
        end
      end
    end

    it 'raise errors if quantity more than stock when create order' do
      VCR.use_cassette('order/developer/create/success/all') do
        before_orders = Gcfs::Wrapper::Api::Order.all force: true, page: 1

        VCR.use_cassette('order/developer/create/failed_quantity_more_than_stock') do
          params = {
            "description": "Pembelian Voucher",
            "recepient": {
              "name": "Mr. Burnice Anderson",
              "email": "enrique.prosacco@kulas.net",
              "phone_number": "947.962.2387",
              "address": "Rasuna Said 10",
              "city": "dki jakarta",
              "zip_code": "12950",
              "notes": "-"
            },
            "items":[
              {
                "id": 10,
                "variants": [{
                  "id": 21,
                  "quantity": 10
                }]
              }
            ],
            "metadata":{
              "user":{
                "id": 1,
                "name": "mutouzi@gmail.com"
              }
            }
          }
          order = Gcfs::Wrapper::Api::Order.create params

          order.class.must_equal Gcfs::Wrapper::Api::Error
          assert order.kind_of?(Gcfs::Wrapper::Api::Error)

          order.message.must_include('quantity insufficient stock')
          order.message.must_include('quantity out of stock')

          VCR.use_cassette('order/developer/create/failed/all') do
            orders = Gcfs::Wrapper::Api::Order.all force: true, page: 1

            orders.size.must_equal 15
            orders.total_count.must_equal 15
            orders.total_pages.must_equal 1
            orders.current_page.must_equal 1

            orders.total_count.must_equal before_orders.total_count
          end
        end
      end

    end

    it 'raise errors if params not filled when create order' do
      VCR.use_cassette('order/developer/create/success/all') do
        before_orders = Gcfs::Wrapper::Api::Order.all force: true, page: 1

        VCR.use_cassette('order/developer/create/failed_params_not_filled') do
          order = Gcfs::Wrapper::Api::Order.create

          order.class.must_equal Gcfs::Wrapper::Api::Error
          assert order.kind_of?(Gcfs::Wrapper::Api::Error)

          order.message.must_include('description is missing')
          order.message.must_include('recepient is missing')
          order.message.must_include('recepient[name] is missing')
          order.message.must_include('recepient[address] is missing')
          order.message.must_include('items is missing')
          order.message.must_include('metadata is missing')
          order.message.must_include('metadata[user] is missing')
          order.message.must_include('metadata[user][id] is missing')
          order.message.must_include('metadata[user][name] is missing')

          VCR.use_cassette('order/developer/create/failed/all') do
            orders = Gcfs::Wrapper::Api::Order.all force: true, page: 1

            orders.size.must_equal 15
            orders.total_count.must_equal 15
            orders.total_pages.must_equal 1
            orders.current_page.must_equal 1

            orders.total_count.must_equal before_orders.total_count
          end
        end
      end

    end

   it 'raise errors if params items not filled when create order' do
      VCR.use_cassette('order/developer/create/success/all') do
        before_orders = Gcfs::Wrapper::Api::Order.all force: true, page: 1

        VCR.use_cassette('order/developer/create/failed_params_items_not_filled') do
          params = {
            "description": "Pembelian Voucher",
            "recepient": {
              "name": "Mr. Burnice Anderson",
              "email": "enrique.prosacco@kulas.net",
              "phone_number": "947.962.2387",
              "address": "Rasuna Said 10",
              "city": "dki jakarta",
              "zip_code": "12950",
              "notes": "-"
            },
            "items":[],
            "metadata":{
              "user":{
                "id": 1,
                "name": "mutouzi@gmail.com"
              }
            }
          }
          order = Gcfs::Wrapper::Api::Order.create params

          order.class.must_equal Gcfs::Wrapper::Api::Error
          assert order.kind_of?(Gcfs::Wrapper::Api::Error)

          order.message.must_include('items is missing')

          VCR.use_cassette('order/developer/create/failed/all') do
            orders = Gcfs::Wrapper::Api::Order.all force: true, page: 1

            orders.size.must_equal 15
            orders.total_count.must_equal 15
            orders.total_pages.must_equal 1
            orders.current_page.must_equal 1

            orders.total_count.must_equal before_orders.total_count
          end
        end
      end

    end

    it 'raise errors if item id wrong from different Client when create order' do
      VCR.use_cassette('order/developer/create/success/all') do
        before_orders = Gcfs::Wrapper::Api::Order.all force: true, page: 1

        VCR.use_cassette('item/developer/list/all/success') do
          items = Gcfs::Wrapper::Api::Item.all force: true

          Gcfs::Wrapper::Api::configure do |config|
            config.key      = '59tXpmSARVZ5rTzentMoDmwl6Mk'
            config.secret   = 'uMO7PoP7Z1q4EpvNPdBkXbI0ylw'
            config.username = 'admin@gcfs.co.id'
            config.password = '12345678'
          end
          VCR.use_cassette('token/request_token/developer/different_client/success') do
            @token = Gcfs::Wrapper::Api::Token.request
          end

          VCR.use_cassette('order/developer/create/failed_item_id_wrong_from_different_client') do
            params = {
              "description": "Pembelian Voucher",
              "recepient": {
                "name": "Mr. Burnice Anderson",
                "email": "enrique.prosacco@kulas.net",
                "phone_number": "947.962.2387",
                "address": "Rasuna Said 10",
                "city": "dki jakarta",
                "zip_code": "12950",
                "notes": "-"
              },
              "items":[
                {
                  "id": 10,
                  "variants": [{
                    "id": 21,
                    "quantity": 10
                  }]
                }
              ],
              "metadata":{
                "user":{
                  "id": 1,
                  "name": "mutouzi@gmail.com"
                }
              }
            }
            order = Gcfs::Wrapper::Api::Order.create params

            order.message.must_include("Item ID "+items.last.id.to_s+" doesn't Exist")

            VCR.use_cassette('order/developer/create/failed/all') do
              orders = Gcfs::Wrapper::Api::Order.all force: true, page: 1

              orders.size.must_equal 15
              orders.total_count.must_equal 15
              orders.total_pages.must_equal 1
              orders.current_page.must_equal 1

              orders.total_count.must_equal before_orders.total_count
            end
          end

        end

      end

    end

    it 'edit order status to delivered' do
      VCR.use_cassette('order/developer/create/success/all') do
        before_orders = Gcfs::Wrapper::Api::Order.all force: true, page: 1

        VCR.use_cassette('order/developer/update/success') do
          params = {
            "status": "delivered",
            "delivery":{
              "courier_name": "JNE",
              "receipt_number": "CGKS301072156314"
            },
            "metadata":{
              "user":{
                "id": 1,
                "name": "mutouzi@gmail.com"
              }
            }
          }
          order = Gcfs::Wrapper::Api::Order.update before_orders.last.id, params

          VCR.use_cassette('order/developer/update/success/all') do
            orders = Gcfs::Wrapper::Api::Order.all force: true, page: 1

            orders.size.must_equal 15
            orders.total_count.must_equal 15
            orders.total_pages.must_equal 1
            orders.current_page.must_equal 1

            orders.total_count.must_equal before_orders.total_count

            orders.last.class.must_equal Gcfs::Wrapper::Api::Order
            assert orders.last.kind_of?(Gcfs::Wrapper::Api::Order)

            orders.last.id.must_equal 119
            orders.last.transaction_id.must_equal 'qilLP5ZbIp'
            orders.last.invoice_number.must_equal nil
            orders.last.description.must_equal 'Pembelian Voucher'

            orders.last.client.class.must_equal Gcfs::Wrapper::Api::Client
            orders.last.client.name.must_equal 'Feil-Baumbach'
            orders.last.client.address.must_equal '33593 Cassie Branch New Brianchester SD 66436-1797'
            orders.last.client.billing_address.must_equal '955 Afton Canyon Stoltenbergfurt DE 25374-5680'

            orders.last.recepient.class.must_equal Gcfs::Wrapper::Api::Recepient
            orders.last.recepient.name.must_equal 'Mr. Burnice Anderson'
            orders.last.recepient.email.must_equal 'enrique.prosacco@kulas.net'
            orders.last.recepient.phone_number.must_equal '947.962.2387'
            orders.last.recepient.address.must_equal 'Rasuna Said 10 DKI JAKARTA 12950'
            orders.last.recepient.city.must_equal 'DKI JAKARTA'
            orders.last.recepient.zip_code.must_equal '12950'
            orders.last.recepient.notes.must_equal "-"

            orders.last.items.each do |item|
              item.class.must_equal Gcfs::Wrapper::Api::OrderItem
              assert item.kind_of?(Gcfs::Wrapper::Api::OrderItem)
            end

            orders.last.items.first.id.must_equal 1
            orders.last.items.first.sku.must_equal '0101'
            orders.last.items.first.name.must_equal 'Fintone'

            orders.last.items.first.variants.each do |variant|
              variant.class.must_equal Gcfs::Wrapper::Api::OrderItemVariant
              assert variant.kind_of?(Gcfs::Wrapper::Api::OrderItemVariant)
            end

            orders.last.items.first.variants.first.id.must_equal 1
            orders.last.items.first.variants.first.sku.must_equal '010101'
            orders.last.items.first.variants.first.description.must_equal 'Fintone 50rb'
            orders.last.items.first.variants.first.quantity.must_equal 10
            orders.last.items.first.variants.first.price.must_equal 45000
            orders.last.items.first.variants.first.nominal.must_equal 50000
            orders.last.items.first.variants.first.subtotal.must_equal 450000

            orders.last.histories.each do |history|
              history.class.must_equal Gcfs::Wrapper::Api::OrderHistory
              assert history.kind_of?(Gcfs::Wrapper::Api::OrderHistory)
            end

            orders.last.histories.first.id.must_equal 137
            orders.last.histories.first.status.must_equal 'delivered'
            orders.last.histories.first.description.must_equal 'JNE with resi CGKS301072156314'
            metadata = {"user"=>{"id"=>1, "name"=>"mutouzi@gmail.com"}}
            orders.last.histories.first.metadata.must_equal metadata

            total = 0
            orders.last.items.each do |item|
              item.variants.each do |variant|
                total += variant.subtotal
              end
            end
            orders.last.total.must_equal total
            orders.last.shipping_fee.must_equal 0
            orders.last.total_with_shipping.must_equal total + 0
            orders.last.status.must_equal orders.last.histories.first.status
            orders.last.status.must_equal 'delivered'
            orders.last.payment_status.must_equal 'outstanding'
            orders.last.delivery.class.must_equal Gcfs::Wrapper::Api::OrderDelivery
            assert orders.last.delivery.kind_of?(Gcfs::Wrapper::Api::OrderDelivery)
            orders.last.delivery.courier_name.must_equal 'JNE'
            orders.last.delivery.receipt_number.must_equal 'CGKS301072156314'
          end
        end

      end

    end

    it 'edit order status to received' do
      VCR.use_cassette('order/developer/update/success/all') do
        before_orders = Gcfs::Wrapper::Api::Order.all force: true, page: 1

        VCR.use_cassette('order/developer/update/received/success') do
          params = {
            "status": "received",
            "receive":{
              "receiver": "Julita",
              "received_at": "2015-03-12 08:07:52"
            },
            "metadata":{
              "user":{
                "id": 1,
                "name": "mutouzi@gmail.com"
              }
            }
          }
          order = Gcfs::Wrapper::Api::Order.update before_orders.last.id, params

          VCR.use_cassette('order/developer/update/received/success/all') do
            orders = Gcfs::Wrapper::Api::Order.all force: true, page: 1

            orders.size.must_equal 15
            orders.total_count.must_equal 15
            orders.total_pages.must_equal 1
            orders.current_page.must_equal 1

            orders.total_count.must_equal before_orders.total_count

            orders.last.class.must_equal Gcfs::Wrapper::Api::Order
            assert orders.last.kind_of?(Gcfs::Wrapper::Api::Order)

            orders.last.id.must_equal 119
            orders.last.transaction_id.must_equal 'qilLP5ZbIp'
            orders.last.invoice_number.must_equal nil
            orders.last.description.must_equal 'Pembelian Voucher'

            orders.last.client.class.must_equal Gcfs::Wrapper::Api::Client
            orders.last.client.name.must_equal 'Feil-Baumbach'
            orders.last.client.address.must_equal '33593 Cassie Branch New Brianchester SD 66436-1797'
            orders.last.client.billing_address.must_equal '955 Afton Canyon Stoltenbergfurt DE 25374-5680'

            orders.last.recepient.class.must_equal Gcfs::Wrapper::Api::Recepient
            orders.last.recepient.name.must_equal 'Mr. Burnice Anderson'
            orders.last.recepient.email.must_equal 'enrique.prosacco@kulas.net'
            orders.last.recepient.phone_number.must_equal '947.962.2387'
            orders.last.recepient.address.must_equal 'Rasuna Said 10 DKI JAKARTA 12950'
            orders.last.recepient.city.must_equal 'DKI JAKARTA'
            orders.last.recepient.zip_code.must_equal '12950'
            orders.last.recepient.notes.must_equal "-"

            orders.last.items.each do |item|
              item.class.must_equal Gcfs::Wrapper::Api::OrderItem
              assert item.kind_of?(Gcfs::Wrapper::Api::OrderItem)
            end

            orders.last.items.first.id.must_equal 1
            orders.last.items.first.sku.must_equal '0101'
            orders.last.items.first.name.must_equal 'Fintone'

            orders.last.items.first.variants.each do |variant|
              variant.class.must_equal Gcfs::Wrapper::Api::OrderItemVariant
              assert variant.kind_of?(Gcfs::Wrapper::Api::OrderItemVariant)
            end

            orders.last.items.first.variants.first.id.must_equal 1
            orders.last.items.first.variants.first.sku.must_equal '010101'
            orders.last.items.first.variants.first.description.must_equal 'Fintone 50rb'
            orders.last.items.first.variants.first.quantity.must_equal 10
            orders.last.items.first.variants.first.price.must_equal 45000
            orders.last.items.first.variants.first.nominal.must_equal 50000
            orders.last.items.first.variants.first.subtotal.must_equal 450000

            orders.last.histories.each do |history|
              history.class.must_equal Gcfs::Wrapper::Api::OrderHistory
              assert history.kind_of?(Gcfs::Wrapper::Api::OrderHistory)
            end

            orders.last.histories.first.id.must_equal 138
            orders.last.histories.first.status.must_equal 'received'
            orders.last.histories.first.description.must_equal 'Received by Julita at 2015-03-12 08:07:52'
            metadata = {"user"=>{"id"=>1, "name"=>"mutouzi@gmail.com"}}
            orders.last.histories.first.metadata.must_equal metadata

            total = 0
            orders.last.items.each do |item|
              item.variants.each do |variant|
                total += variant.subtotal
              end
            end
            orders.last.total.must_equal total
            orders.last.shipping_fee.must_equal 0
            orders.last.total_with_shipping.must_equal total + 0
            orders.last.status.must_equal orders.last.histories.first.status
            orders.last.status.must_equal 'received'
            orders.last.payment_status.must_equal 'outstanding'
            orders.last.delivery.courier_name.must_equal 'JNE'
            orders.last.delivery.receipt_number.must_equal 'CGKS301072156314'
            orders.last.receive.class.must_equal Gcfs::Wrapper::Api::OrderReceive
              assert orders.last.receive.kind_of?(Gcfs::Wrapper::Api::OrderReceive)
            orders.last.receive.receiver.must_equal 'Julita'
            orders.last.receive.received_at.must_equal Time.zone.parse('2015-03-12 08:07:52' + ' ' + Gcfs::Wrapper::Api.options[:timezone])
          end
        end

      end

    end

    it 'raise errors if params not filled when edit order status' do
      VCR.use_cassette('order/developer/update/received/success/all') do
        before_orders = Gcfs::Wrapper::Api::Order.all force: true, page: 1

        VCR.use_cassette('order/developer/update/failed_params_not_filled') do
          order = Gcfs::Wrapper::Api::Order.update before_orders.last.id

          VCR.use_cassette('order/developer/update/failed_params_not_filled/all') do
            orders = Gcfs::Wrapper::Api::Order.all force: true, page: 1

            orders.size.must_equal 15
            orders.total_count.must_equal 15
            orders.total_pages.must_equal 1
            orders.current_page.must_equal 1

            orders.total_count.must_equal before_orders.total_count

            order.class.must_equal Gcfs::Wrapper::Api::Error
            assert order.kind_of?(Gcfs::Wrapper::Api::Error)

            order.message.must_include('status is missing')
            order.message.must_include('status does not have a valid value')
            order.message.must_include('metadata is missing')
            order.message.must_include('metadata[user] is missing')
            order.message.must_include('metadata[user][id] is missing')
            order.message.must_include('metadata[user][name] is missing')
          end
        end

      end

    end

    it 'raise errors if params delivery not filled when edit order status to delivered' do
      VCR.use_cassette('order/developer/update/received/success/all') do
        before_orders = Gcfs::Wrapper::Api::Order.all force: true, page: 1

        VCR.use_cassette('order/developer/update/failed_params_delivery_not_filled') do
          params = {
            "status": "delivered",
            "metadata":{
              "user":{
                "id": 1,
                "name": "mutouzi@gmail.com"
              }
            }
          }
          order = Gcfs::Wrapper::Api::Order.update before_orders.last.id, params
            
          order.message.must_include('delivery is missing')

        end

      end

    end

    it 'raise errors if params delivery[courier_name] not filled when edit order status to delivered' do
      VCR.use_cassette('order/developer/update/received/success/all') do
        before_orders = Gcfs::Wrapper::Api::Order.all force: true, page: 1

        VCR.use_cassette('order/developer/update/failed_params_delivery[courier_name]_not_filled') do
          params = {
            "status": "delivered",
            "delivery":{
              "receipt_number": "CGKS301072156314"
            },
            "metadata":{
              "user":{
                "id": 1,
                "name": "mutouzi@gmail.com"
              }
            }
          }
          order = Gcfs::Wrapper::Api::Order.update before_orders.last.id, params
            
          order.message.must_include('delivery[courier_name] is missing')

        end

      end
    end

    it 'raise errors if params delivery[receipt_number] not filled when edit order status to delivered' do
      VCR.use_cassette('order/developer/update/received/success/all') do
        before_orders = Gcfs::Wrapper::Api::Order.all force: true, page: 1

        VCR.use_cassette('order/developer/update/failed_params_delivery[receipt_number]_not_filled') do
          params = {
            "status": "delivered",
            "delivery":{
              "courier_name": "JNE"
            },
            "metadata":{
              "user":{
                "id": 1,
                "name": "mutouzi@gmail.com"
              }
            }
          }
          order = Gcfs::Wrapper::Api::Order.update before_orders.last.id, params
            
          order.message.must_include('delivery[receipt_number] is missing')

        end

      end
    end

    it 'raise errors if params receive not filled when edit order status to received' do
      VCR.use_cassette('order/developer/update/received/success/all') do
        before_orders = Gcfs::Wrapper::Api::Order.all force: true, page: 1

        VCR.use_cassette('order/developer/update/failed_params_receive_not_filled') do
          params = {
            "status": "received",
            "metadata":{
              "user":{
                "id": 1,
                "name": "mutouzi@gmail.com"
              }
            }
          }
          order = Gcfs::Wrapper::Api::Order.update before_orders.last.id, params
            
          order.message.must_include('receive is missing')

        end

      end

    end

    it 'raise errors if params receive[receiver] not filled when edit order status to received' do
      VCR.use_cassette('order/developer/update/received/success/all') do
        before_orders = Gcfs::Wrapper::Api::Order.all force: true, page: 1

        VCR.use_cassette('order/developer/update/failed_params_receive[receiver]_not_filled') do
          params = {
            "status": "received",
            "receive":{
              "received_at": "2015-03-12 08:07:52"
            },
            "metadata":{
              "user":{
                "id": 1,
                "name": "mutouzi@gmail.com"
              }
            }
          }
          order = Gcfs::Wrapper::Api::Order.update before_orders.last.id, params
            
          order.message.must_include('receive[receiver] is missing')

        end

      end
    end

    it 'raise errors if params receive[received_at] not filled when edit order status to received' do
      VCR.use_cassette('order/developer/update/received/success/all') do
        before_orders = Gcfs::Wrapper::Api::Order.all force: true, page: 1

        VCR.use_cassette('order/developer/update/failed_params_receive[received_at]_not_filled') do
          params = {
            "status": "received",
            "receive":{
              "receiver": "Julita",
            },
            "metadata":{
              "user":{
                "id": 1,
                "name": "mutouzi@gmail.com"
              }
            }
          }
          order = Gcfs::Wrapper::Api::Order.update before_orders.last.id, params
            
          order.message.must_include('receive[received_at] is missing')

        end

      end
    end

    it 'raise errors if params status wrong when edit order status' do
      VCR.use_cassette('order/developer/update/received/success/all') do
        before_orders = Gcfs::Wrapper::Api::Order.all force: true, page: 1

        VCR.use_cassette('order/developer/update/failed_params_status_wrong') do
          params = {
            "status": "ABCDE",
            "metadata":{
              "user":{
                "id": 1,
                "name": "mutouzi@gmail.com"
              }
            }
          }
          order = Gcfs::Wrapper::Api::Order.update before_orders.last.id, params
            
          order.message.must_include('status does not have a valid value')

        end

      end
    end

    it 'show order' do
      VCR.use_cassette('order/developer/update/received/success/all') do
        orders = Gcfs::Wrapper::Api::Order.all force: true, page: 1

        VCR.use_cassette('order/developer/show/'+orders.last.id.to_s+'/success') do
          order = Gcfs::Wrapper::Api::Order.find(orders.last.id)

          order.class.must_equal Gcfs::Wrapper::Api::Order
          assert order.kind_of?(Gcfs::Wrapper::Api::Order)

          order.id.must_equal 119
          order.transaction_id.must_equal 'qilLP5ZbIp'
          order.invoice_number.must_equal nil
          order.description.must_equal 'Pembelian Voucher'

          order.client.class.must_equal Gcfs::Wrapper::Api::Client
          order.client.name.must_equal 'Feil-Baumbach'
          order.client.address.must_equal '33593 Cassie Branch New Brianchester SD 66436-1797'
          order.client.billing_address.must_equal '955 Afton Canyon Stoltenbergfurt DE 25374-5680'

          order.recepient.class.must_equal Gcfs::Wrapper::Api::Recepient
          order.recepient.name.must_equal 'Mr. Burnice Anderson'
          order.recepient.email.must_equal 'enrique.prosacco@kulas.net'
          order.recepient.phone_number.must_equal '947.962.2387'
          order.recepient.address.must_equal 'Rasuna Said 10 DKI JAKARTA 12950'
          order.recepient.city.must_equal 'DKI JAKARTA'
          order.recepient.zip_code.must_equal '12950'
          order.recepient.notes.must_equal "-"
          
          order.items.each do |item|
            item.class.must_equal Gcfs::Wrapper::Api::OrderItem
            assert item.kind_of?(Gcfs::Wrapper::Api::OrderItem)
          end

          order.items.first.id.must_equal 1
          order.items.first.sku.must_equal '0101'
          order.items.first.name.must_equal 'Fintone'
          
          order.items.first.variants.each do |variant|
            variant.class.must_equal Gcfs::Wrapper::Api::OrderItemVariant
            assert variant.kind_of?(Gcfs::Wrapper::Api::OrderItemVariant)
          end

          order.items.first.variants.first.id.must_equal 1
          order.items.first.variants.first.sku.must_equal '010101'
          order.items.first.variants.first.description.must_equal 'Fintone 50rb'
          order.items.first.variants.first.quantity.must_equal 10
          order.items.first.variants.first.price.must_equal 45000
          order.items.first.variants.first.nominal.must_equal 50000
          order.items.first.variants.first.subtotal.must_equal 450000

          order.histories.each do |history|
            history.class.must_equal Gcfs::Wrapper::Api::OrderHistory
            assert history.kind_of?(Gcfs::Wrapper::Api::OrderHistory)
          end

          order.histories.first.id.must_equal 138
          order.histories.first.status.must_equal 'received'
          order.histories.first.description.must_equal 'Received by Julita at 2015-03-12 08:07:52'
          metadata = {"user"=>{"id"=>1, "name"=>"mutouzi@gmail.com"}}
          order.histories.first.metadata.must_equal metadata

          total = 0
          order.items.each do |item|
            item.variants.each do |variant|
              total += variant.subtotal
            end
          end
          order.total.must_equal total
          order.shipping_fee.must_equal 0
          order.total_with_shipping.must_equal total + 0
          order.status.must_equal order.histories.first.status
          order.status.must_equal 'received'
          order.payment_status.must_equal 'outstanding'
          order.delivery.courier_name.must_equal 'JNE'
          order.delivery.receipt_number.must_equal 'CGKS301072156314'
          order.receive.class.must_equal Gcfs::Wrapper::Api::OrderReceive
            assert order.receive.kind_of?(Gcfs::Wrapper::Api::OrderReceive)
          order.receive.receiver.must_equal 'Julita'
          order.receive.received_at.must_equal Time.zone.parse('2015-03-12 08:07:52' + ' ' + Gcfs::Wrapper::Api.options[:timezone])
        end

      end
    end

  end

end