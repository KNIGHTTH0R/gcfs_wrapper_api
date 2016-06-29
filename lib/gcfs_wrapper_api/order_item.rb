module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class OrderItem < Base
        VALID_ATTRIBUTES =  [:id, :sku, :name, :category_name, :variants, :output, :tiket_order_id, :resultcode, :message, :trxid, :ref_trxid, :is_po_item].freeze
        attr_reader *VALID_ATTRIBUTES

        def initialize(attributes)
          @id = attributes["id"]
          @sku = attributes["sku"]
          @name = attributes["name"]
          @category_name = attributes["category_name"]
          @output = attributes["output"] if attributes["output"]
          @tiket_order_id = attributes["tiket_order_id"] if attributes["tiket_order_id"]
          @variants = attributes["variants"].map{|item| Gcfs::Wrapper::Api::OrderItemVariant.new item } if attributes["variants"]
          @resultcode = attributes["resultcode"]
          @message = attributes["message"]
          @trxid = attributes["trxid"]
          @ref_trxid = attributes["ref_trxid"]
          @is_po_item = attributes["is_po_item"]
        end
      end

    end
  end
end