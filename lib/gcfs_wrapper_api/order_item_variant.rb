module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class OrderItemVariant < Base
        VALID_ATTRIBUTES =  [:id, :sku, :description, :quantity, :price, :nominal, :subtotal, :design_type, :tada_type, :design_notes, :program_id, :order_item_id, :card_notes].freeze
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
          @design_notes = attributes["design_notes"]
          @program_id = attributes["program_id"]
          @order_item_id = attributes["order_item_id"]
          @card_notes = attributes["card_notes"]
        end
      end

    end
  end
end