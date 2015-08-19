module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class Flight < Base
        # INPUT_ATTRIBUTES = [:name, :category, :image].freeze
        # VARIANTS_ATTRIBUTES = [:variants].freeze
        # INPUT_ATTRIBUTES_WITH_VARIANTS = INPUT_ATTRIBUTES + VARIANTS_ATTRIBUTES
        # TABLE_ATTRIBUTES = [:id, :sku, :created_at, :updated_at].freeze
        # VALID_ATTRIBUTES =  TABLE_ATTRIBUTES + INPUT_ATTRIBUTES_WITH_VARIANTS
        VALID_ATTRIBUTES = [:id, :transaction_id, :invoice_number, :description, :client, :recepient, :items, :histories, :total, :shipping_fee, :total_with_shipping, :status, :payment_status, :created_at, :updated_at, :order_type].freeze
        attr_reader *VALID_ATTRIBUTES

        # QUERY_ATTRIBUTES = [:client, :category, :sku, :name, :nominal, :price, :min_price, :max_price].freeze

        QUERY_ATTRIBUTES = [:d, :a, :date, :ret_date, :adult, :child, :infant]
        METADATA_ATTRIBUTES = [:id, :name].freeze
        # SORT_ATTRIBUTES = [:sku, :name, :category].freeze

        def initialize(attributes)
          attributes = JSON.parse(attributes.to_json)
          @id = attributes["id"]
          @transaction_id = attributes["transaction_id"]
          @invoice_number = attributes["invoice_number"]
          @description = attributes["description"]
          @client = Gcfs::Wrapper::Api::Client.new attributes["client"]
          @recepient = Gcfs::Wrapper::Api::Recepient.new attributes["recepient"]
          @items = attributes["items"].map{|item| Gcfs::Wrapper::Api::OrderItem.new item } if attributes["items"]
          @histories = attributes["histories"].map{|item| Gcfs::Wrapper::Api::OrderHistory.new item } if attributes["histories"]
          @total = attributes["total"]
          @shipping_fee = attributes["shipping_fee"]
          @total_with_shipping = attributes["total_with_shipping"]
          @status = attributes["status"]
          @payment_status = attributes["payment_status"]
          @order_type = attributes["order_type"]
          @created_at = Time.zone.parse(attributes["created_at"] + ' ' + Gcfs::Wrapper::Api.options[:timezone])
          @updated_at = Time.zone.parse(attributes["updated_at"] + ' ' + Gcfs::Wrapper::Api.options[:timezone])

        end

        def self.search(options={})
          options = parsed_params options
          @options = configure_params query: {}
            .merge(options ? options.select{|key, hash|QUERY_ATTRIBUTES.include? key } : {})
            .merge(options[:metadata] ? {metadata: {user: options[:metadata][:user].select{|key, hash|METADATA_ATTRIBUTES.include? key } }} : {})
          retrieve_url self.get("/v1/flights/search", @options)
        end

        def self.process_order(options={})
          options = parsed_params options
          @options = configure_params body: options.to_json
          retrieve_url self.post("/v1/flights/process_order", @options)
        end

        def self.airports(metadata={})
          options = parsed_params metadata
          @options = configure_params query: metadata
          retrieve_url self.get("/v1/flights/airports", @options)
        end

      end
    end
  end
end