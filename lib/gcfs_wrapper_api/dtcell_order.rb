module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class DtcellOrder < Base
        VALID_ATTRIBUTES =  [:id, :resultcode, :message, :trxid, :ref_trxid, :operator_code, :phone_number, :status].freeze
        attr_reader *VALID_ATTRIBUTES

        def initialize(attributes)
          @id = attributes["id"]
          @resultcode = attributes["resultcode"]
          @message = attributes["message"]
          @trxid = attributes["trxid"]
          @ref_trxid = attributes["ref_trxid"]
          @operator_code = attributes["operator_code"]
          @phone_number = attributes["phone_number"]
          @status = attributes["status"]
        end
      end

    end
  end
end