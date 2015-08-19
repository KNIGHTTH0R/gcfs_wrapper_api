module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class UserInfo < Base
        TABLE_ATTRIBUTES = [:id, :email, :role].freeze
        VALID_ATTRIBUTES =  TABLE_ATTRIBUTES #+ INPUT_ATTRIBUTES
        attr_reader *VALID_ATTRIBUTES

        def initialize(attributes)
          @id = attributes["id"]
          @email = attributes["email"]
          @role = attributes["role"]
        end

        def self.info(options={})
          @options = configure_params options
          user = retrieve_url self.get("/v1/user_info", @options)
        end

      end

    end
  end
end