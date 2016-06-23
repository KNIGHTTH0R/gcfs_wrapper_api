module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class PhoneChecker < Base
        INPUT_ATTRIBUTES = [].freeze
        TABLE_ATTRIBUTES = [:status].freeze
        VALID_ATTRIBUTES =  TABLE_ATTRIBUTES + INPUT_ATTRIBUTES
        attr_reader *VALID_ATTRIBUTES

        # SORT_ATTRIBUTES = [:name].freeze

        def initialize(attributes)
          @status = attributes["status"]
        end

        def self.check(phone_number,item_id)
          @options = configure_params query: {phone_number: phone_number, item_id: item_id }
          status = retrieve_url self.get("/v1/phone_prefix_checker/status", @options)
        end

      end

    end
  end
end