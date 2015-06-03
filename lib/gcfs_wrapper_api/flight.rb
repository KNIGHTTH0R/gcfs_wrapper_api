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
          # @departure = attributes["d"]
          # @arrival = attributes["a"]
          # @departure_date = attributes["date"]
          # @return_date = attributes["ret_date"]
          # @adult = attributes["adult"]
          # @child = attributes["child"]
          # @infant = attributes["infant"]

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
          @created_at = attributes["created_at"]
          @updated_at = attributes["updated_at"]
          @order_type = attributes["order_type"]

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

        # def self.create(options={})
        #   options = parsed_params options
        #   options = parse_image options
        #   @options = configure_params body: options.select{|key, hash|INPUT_ATTRIBUTES_WITH_VARIANTS.include? key }.to_json
        #   object = retrieve_url self.post("/v1/items", @options)
        #   @objects = [] if object.kind_of?(self)
        #   object
        # end

        # def self.find(id)
        #   @options = configure_params
        #   object = retrieve_url self.get("/v1/items/" + id.to_s, @options)
        # end

        # def self.update(id, options={})
        #   options = parsed_params options
        #   options = parse_image options

        #   @options = configure_params body: options.select{|key, hash|INPUT_ATTRIBUTES.include? key }.to_json
        #   object = retrieve_url self.put("/v1/items/" + id.to_s, @options)
        #   @objects = [] if object.kind_of?(self)
        #   object
        # end

        # def self.destroy(id)
        #   @options = configure_params
        #   object = retrieve_url self.delete("/v1/items/" + id.to_s, @options)
        #   @objects = [] if object.kind_of?(self)
        #   object
        # end

        # private
        # def self.parse_image(options={})
        #   if options[:image]
        #     if options[:image].kind_of?(ActionDispatch::Http::UploadedFile)
        #       tempfile = options[:image].tempfile
        #     elsif options[:image].kind_of?(File)
        #       tempfile = Tempfile.new("fileupload")
        #       tempfile.binmode
        #       tempfile.write(options[:image].read)
        #     end
        #     tempfile.rewind

        #     options[:image] = Base64.encode64(tempfile.read)
        #   end
        #   options = options.symbolize_keys
        #   if options[:variants]
        #     options[:variants].each do |variant|
        #       variant.delete_if {|key, value| value.blank? }
        #     end
        #     options[:variants] = options[:variants].map{|v|v.symbolize_keys}
        #   end
        #   options
        # end
      end

    end
  end
end