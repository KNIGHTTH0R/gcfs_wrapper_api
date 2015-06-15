module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class Dtcell < Base

        SORT_ATTRIBUTES = [:operator, :operator_code].freeze
        INPUT_ATTRIBUTES = [:id, :phone_number, :qty, :transaction_id].freeze
        VALID_ATTRIBUTES = INPUT_ATTRIBUTES + SORT_ATTRIBUTES
        attr_reader *VALID_ATTRIBUTES

        # QUERY_ATTRIBUTES = [:d, :a, :date, :ret_date, :adult, :child, :infant]
        # METADATA_ATTRIBUTES = [:id, :name].freeze

        def initialize(attributes)
          attributes = JSON.parse(attributes.to_json)
          @id = attributes["id"]
          @operator = attributes["operator"]
          @operator_code = attributes["operator_code"]
          @nominal = attributes["nominal"]
          @price = attributes["price"]
        end

        def self.topup(options={})
          options = parsed_params options
          @options = configure_params body: options.select{|key, hash|INPUT_ATTRIBUTES.include? key }.to_json
          
          retrieve_url self.post("/v1/dtcell/credit/topup", @options)
        end

        def self.all(options={})
          options = parsed_params options
          @options = configure_params query: { page: options[:page], per_page: options[:per_page] }.merge(options[:sort] ? {sort: options[:sort].select{|key, hash|SORT_ATTRIBUTES.include? key }} : {})
          categories = retrieve_url self.get("/v1/dtcell/product", @options)
        end

      end
    end
  end
end