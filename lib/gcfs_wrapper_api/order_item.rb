module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class OrderItem < Base
        VALID_ATTRIBUTES =  [:id, :sku, :name, :category_name, :variants, :output, :flight_order_id, :resultcode, :message, :trxid, :ref_trxid].freeze
        attr_reader *VALID_ATTRIBUTES

        def initialize(attributes)
          @id = attributes["id"]
          @sku = attributes["sku"]
          @name = attributes["name"]
          @category_name = attributes["category_name"]
          @output = attributes["output"] if attributes["output"]
          @flight_order_id = attributes["flight_order_id"] if attributes["flight_order_id"]
          @variants = attributes["variants"].map{|item| Gcfs::Wrapper::Api::OrderItemVariant.new item } if attributes["variants"]
          @resultcode = attributes["resultcode"]
          @message = attributes["message"]
          @trxid = attributes["trxid"]
          @ref_trxid = attributes["ref_trxid"]
        end
      end

    end
  end
end