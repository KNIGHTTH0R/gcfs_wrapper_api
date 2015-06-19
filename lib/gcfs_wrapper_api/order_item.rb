module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class OrderItem < Base
        VALID_ATTRIBUTES =  [:id, :sku, :name, :variants, :output].freeze
        attr_reader *VALID_ATTRIBUTES

        def initialize(attributes)
          @id = attributes["id"]
          @sku = attributes["sku"]
          @name = attributes["name"]
          @output = attributes["output"] if attributes["output"]
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