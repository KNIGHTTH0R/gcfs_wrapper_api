module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class OrderItemVariant < Base
        VALID_ATTRIBUTES =  [:id, :sku, :description, :quantity, :price, :nominal, :subtotal, :design_type, :tada_type, :topup_card_no, :design_notes, :program_id, :order_item_id, :dtcell_orders, :bem_request_logs, :card_notes].freeze
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
          @topup_card_no = attributes["topup_card_no"]
          @design_notes = attributes["design_notes"]
          @program_id = attributes["program_id"]
          @order_item_id = attributes["order_item_id"]
          @card_notes = attributes["card_notes"]
          @dtcell_orders = attributes["dtcell_orders"].map{|dtcell_order| Gcfs::Wrapper::Api::DtcellOrder.new dtcell_order } if attributes["dtcell_orders"].present?
          @bem_request_logs = attributes["bem_request_logs"].map{|bem_log| Gcfs::Wrapper::Api::BemRequestLog.new bem_log } if attributes["bem_request_logs"].present?
        end
      end
    end
  end
end