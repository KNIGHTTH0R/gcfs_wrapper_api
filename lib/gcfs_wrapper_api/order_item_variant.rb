module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class OrderItemVariant < Base
        VALID_ATTRIBUTES =  [:id, :sku, :description, :quantity, :price, :nominal, :subtotal, :design_type, :tada_type].freeze
        attr_reader *VALID_ATTRIBUTES

        def initialize(attributes)
          @id = attributes["id"]
          @sku = attributes["sku"]
          @description = attributes["description"]
          @quantity = attributes["quantity"]
          @price = attributes["price"]
          @nominal = attributes["nominal"]
          @subtotal = attributes["subtotal"]
          @design_type = attributes["design_type"]
          @tada_type = attributes["tada_type"]
        end
      end

    end
  end
end