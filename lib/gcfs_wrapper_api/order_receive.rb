module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class OrderReceive < Base
        VALID_ATTRIBUTES =  [:receiver, :received_at].freeze
        attr_reader *VALID_ATTRIBUTES

        def initialize(attributes)
          @receiver = attributes["receiver"]
          @received_at = Time.zone.parse(attributes["received_at"] + ' ' + Gcfs::Wrapper::Api.options[:timezone])
        end
      end

    end
  end
end