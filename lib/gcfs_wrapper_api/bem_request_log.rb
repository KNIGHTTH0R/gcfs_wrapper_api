module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class BemRequestLog < Base
        VALID_ATTRIBUTES =  [:id, :output].freeze
        attr_reader *VALID_ATTRIBUTES

        def initialize(attributes)
          @id = attributes["id"]
          @output = attributes["output"]
        end
      end

    end
  end
end