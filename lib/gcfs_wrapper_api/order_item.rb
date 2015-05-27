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
        end
      end

    end
  end
end