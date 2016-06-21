module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class PhonePrefix < Base
        VALID_ATTRIBUTES =  [:prefix].freeze
        attr_reader *VALID_ATTRIBUTES

        def initialize(attributes)
          @prefix = attributes["prefix"]
        end
      end

    end
  end
end