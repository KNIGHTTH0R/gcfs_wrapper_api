module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class OrderPayment < Base
        VALID_ATTRIBUTES =  [:id, :payment_type, :card_no, :prev_balance, :current_balance, :merchant_id].freeze
        attr_reader *VALID_ATTRIBUTES

        def initialize(attributes)
          @id = attributes["id"]
          @payment_type = attributes["payment_type"]
          @card_no = attributes["card_no"]
          @prev_balance = attributes["prev_balance"]
          @current_balance = attributes["current_balance"]
          @merchant_id = attributes["merchant_id"]
        end
      end

    end
  end
end