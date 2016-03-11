module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class BlacklistedEmail < Base
        INPUT_ATTRIBUTES = [].freeze
        TABLE_ATTRIBUTES = [:status].freeze
        VALID_ATTRIBUTES =  TABLE_ATTRIBUTES + INPUT_ATTRIBUTES
        attr_reader *VALID_ATTRIBUTES

        SORT_ATTRIBUTES = [:name].freeze

        def initialize(attributes)
          @status = attributes["status"]
        end

        def self.check(email_address)
          @options = configure_params query: { query: { email: email_address }}
          status = retrieve_url self.get("/v1/blacklisted_email/check", @options)
        end

      end

    end
  end
end