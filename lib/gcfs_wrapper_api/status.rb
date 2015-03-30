module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class Status < Base
        VALID_ATTRIBUTES = [:message].freeze
        attr_reader *VALID_ATTRIBUTES

        def initialize(attributes)
          @message = attributes["message"]
        end

        def self.get_stat(options={})
          @options = configure_params
          status = retrieve_url self.get("/v1/status", @options)
        end
      end

    end
  end
end