module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class DtcellOrder < Base
        VALID_ATTRIBUTES =  [:id, :resultcode, :message, :trxid, :ref_trxid, :vendor, :operator_code, :phone_number, :status, :is_sent].freeze
        attr_reader *VALID_ATTRIBUTES

        def initialize(attributes)
          @id = attributes["id"]
          @resultcode = attributes["resultcode"]
          @message = attributes["message"]
          @trxid = attributes["trxid"]
          @ref_trxid = attributes["ref_trxid"]
          @vendor = attributes["vendor"]
          @operator_code = attributes["operator_code"]
          @phone_number = attributes["phone_number"]
          @status = attributes["status"]
          @is_sent = attributes["is_sent"]
        end
      end

    end
  end
end