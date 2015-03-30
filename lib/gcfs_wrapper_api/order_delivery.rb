module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class OrderDelivery < Base
        VALID_ATTRIBUTES =  [:courier_name, :receipt_number].freeze
        attr_reader *VALID_ATTRIBUTES

        def initialize(attributes)
          @courier_name = attributes["courier_name"]
          @receipt_number = attributes["receipt_number"]
        end
      end

    end
  end
end