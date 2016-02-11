module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class Client < Base
        VALID_ATTRIBUTES =  [:name, :address, :billing_address, :client_code].freeze
        attr_reader *VALID_ATTRIBUTES

        def initialize(attributes)
          @name = attributes["name"]
          @address = attributes["address"]
          @billing_address = attributes["billing_address"]
          @client_code =  attributes["client_code"]
        end
      end

    end
  end
end