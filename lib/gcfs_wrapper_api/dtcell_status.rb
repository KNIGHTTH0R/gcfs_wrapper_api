module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class DtcellStatus < Base
        VALID_ATTRIBUTES =  [:message].freeze
        attr_reader *VALID_ATTRIBUTES

        def initialize(attributes)
          @message = attributes["message"]
        end
      end

    end
  end
end