module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class OrderHistory < Base
        VALID_ATTRIBUTES =  [:id, :status, :description, :metadata, :changes, :created_at].freeze
        attr_reader *VALID_ATTRIBUTES

        def initialize(attributes)
          @id = attributes["id"]
          @status = attributes["status"]
          @description = attributes["description"]
          @metadata = attributes["metadata"]
          @changes = attributes["changes"]
          @created_at = attributes["created_at"]
        end
      end

    end
  end
end