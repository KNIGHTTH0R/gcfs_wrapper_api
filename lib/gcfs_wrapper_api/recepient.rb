module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class Recepient < Base
        VALID_ATTRIBUTES =  [:name, :email, :phone_number, :address, :city, :zip_code, :notes].freeze
        attr_reader *VALID_ATTRIBUTES

        def initialize(attributes)
          @name = attributes["name"]
          @email = attributes["email"]
          @phone_number = attributes["phone_number"]
          @address = attributes["address"]
          @city = attributes["city"]
          @zip_code = attributes["zip_code"]
          @notes = attributes["notes"]
        end
      end

    end
  end
end