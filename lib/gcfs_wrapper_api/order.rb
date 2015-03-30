module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class Order < Base
        INPUT_ATTRIBUTES = [:description, :status, :metadata].freeze
        RECEPIENT_ATTRIBUTES = [:recepient].freeze
        INPUT_ATTRIBUTES_WITH_RECEPIENT = INPUT_ATTRIBUTES + RECEPIENT_ATTRIBUTES
        DELIVERY_ATTRIBUTES = [:delivery].freeze
        RECEIVE_ATTRIBUTES = [:receive].freeze
        INPUT_ATTRIBUTES_WITH_DELIVERY_RECEIVE = INPUT_ATTRIBUTES + DELIVERY_ATTRIBUTES + RECEIVE_ATTRIBUTES
        ITEMS_ATTRIBUTES = [:items].freeze
        INPUT_ATTRIBUTES_WITH_ITEMS = INPUT_ATTRIBUTES_WITH_RECEPIENT + ITEMS_ATTRIBUTES
        TABLE_ATTRIBUTES = [:id, :transaction_id, :invoice_number, :client, :histories, :total, :payment_status, :created_at, :updated_at].freeze
        VALID_ATTRIBUTES =  TABLE_ATTRIBUTES + INPUT_ATTRIBUTES_WITH_ITEMS + DELIVERY_ATTRIBUTES + RECEIVE_ATTRIBUTES
        attr_reader *VALID_ATTRIBUTES

        QUERY_ATTRIBUTES = [:start_date, :end_date, :client, :category, :item, :variant, :invoice_number, :transaction_id, :status, :payment_status].freeze
        SORT_ATTRIBUTES = [:date, :client, :transaction_id, :description, :recepient, :total, :invoice_number, :status, :payment_status].freeze

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
          @status = attributes["status"]
          @payment_status = attributes["payment_status"]
          @delivery = attributes["delivery"]
          @receive = attributes["receive"]
          @created_at = attributes["created_at"]
          @updated_at = attributes["updated_at"]
        end

        def self.all(options={force: false, query:{}, sort:{}})
          options = options.symbolize_keys
          options.keys.select{|key|[:query,:sort].include? key}.each do |key|
            options[key] = options[key].symbolize_keys
            options[key].delete_if {|key, value| value.blank? }
          end

          options = { page: options[:page].presence, per_page: options[:per_page].presence, query: options[:query] ? options[:query].select{|key, hash|QUERY_ATTRIBUTES.include? key } : options[:query], sort: options[:sort] ? options[:sort].select{|key, hash|SORT_ATTRIBUTES.include? key } : options[:sort] }

          options = parsed_params options

          @options = configure_params query: options

          @objects ||= []
          @objects[options[:per_page].to_i] ||= []
          options[:force] = true if @objects[options[:per_page].to_i][options[:page].to_i].kind_of?(Gcfs::Wrapper::Api::Error)
          @objects[options[:per_page].to_i] = [] if options[:force] and @objects[options[:per_page].to_i]
          @objects[options[:per_page].to_i][options[:page].to_i] = nil if options[:force]
          # @objects[options[:per_page].to_i][options[:page].to_i] ||= retrieve_url self.get("/v1/orders", @options)
          retrieve_url self.get("/v1/orders", @options)
        end

        def self.create(options={})
          options = parsed_params options
          @options = configure_params body: options.select{|key, hash|INPUT_ATTRIBUTES_WITH_ITEMS.include? key }.to_json
          object = retrieve_url self.post("/v1/orders", @options)
          @objects = [] if object.kind_of?(self)
          object
        end

        def self.find(id)
          @options = configure_params
          object = retrieve_url self.get("/v1/orders/" + id.to_s, @options)
        end

        def self.update(id, options={})
          options = parsed_params options

          @options = configure_params body: options.select{|key, hash|INPUT_ATTRIBUTES_WITH_DELIVERY_RECEIVE.include? key }.to_json
          object = retrieve_url self.put("/v1/orders/" + id.to_s, @options)
          @objects = [] if object.kind_of?(self)
          object
        end
      end

    end
  end
end