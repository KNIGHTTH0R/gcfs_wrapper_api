module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class ItemVariant < Base
        INPUT_ATTRIBUTES = [:name, :description, :nominal, :active, :price, :program_id, :metadata].freeze
        TABLE_ATTRIBUTES = [:id, :sku, :name, :created_at, :updated_at, :stock].freeze
        VALID_ATTRIBUTES =  TABLE_ATTRIBUTES + INPUT_ATTRIBUTES
        attr_reader *VALID_ATTRIBUTES

        SORT_ATTRIBUTES = [:sku, :description, :nominal, :price].freeze

        def initialize(attributes)
          @id = attributes["id"]
          @sku = attributes["sku"]
          @name = attributes["name"]
          @description = attributes["description"]
          @nominal = attributes["nominal"]
          @price = attributes["price"]
          @stock = attributes["stock"]
          @active = attributes["active"]
          @program_id = attributes["program_id"]
          @metadata = attributes["metadata"]
          @created_at = Time.zone.parse(attributes["created_at"] + ' ' + Gcfs::Wrapper::Api.options[:timezone])
          @updated_at = Time.zone.parse(attributes["updated_at"] + ' ' + Gcfs::Wrapper::Api.options[:timezone])
        end

        def self.all(item_id, options={force: false})
          options = parsed_params options
          @options = configure_params query: { page: options[:page], per_page: options[:per_page] }.merge(options[:sort] ? {sort: options[:sort].select{|key, hash|SORT_ATTRIBUTES.include? key }} : {})

          @objects ||= []
          @objects[options[:per_page].to_i] ||= []
          options[:force] = true if @objects[options[:per_page].to_i][options[:page].to_i].kind_of?(Gcfs::Wrapper::Api::Error)
          @objects[options[:per_page].to_i] = [] if options[:force] and @objects[options[:per_page].to_i]
          @objects[options[:per_page].to_i][options[:page].to_i] = nil if options[:force]
          # @objects[options[:per_page].to_i][options[:page].to_i] ||= retrieve_url self.get("/v1/items/"+item_id.to_s+"/variants", @options)
          retrieve_url self.get("/v1/items/"+item_id.to_s+"/variants", @options)
        end

        def self.create(item_id, options={})
          options = parsed_params options
          @options = configure_params body: options.select{|key, hash|INPUT_ATTRIBUTES.include? key }.to_json
          object = retrieve_url self.post("/v1/items/"+item_id.to_s+"/variants", @options)
          @objects = [] if object.kind_of?(self)
          object
        end

        def self.find(item_id, id)
          @options = configure_params
          object = retrieve_url self.get("/v1/items/"+item_id.to_s+"/variants/" + id.to_s, @options)
        end

        def self.update(item_id, id, options={})
          options = parsed_params options
          @options = configure_params body: options.select{|key, hash|INPUT_ATTRIBUTES.include? key }.to_json
          object = retrieve_url self.put("/v1/items/"+item_id.to_s+"/variants/" + id.to_s, @options)
          @objects = [] if object.kind_of?(self)
          object
        end

        def self.destroy(item_id, id)
          @options = configure_params
          object = retrieve_url self.delete("/v1/items/"+item_id.to_s+"/variants/" + id.to_s, @options)
          @objects = [] if object.kind_of?(self)
          object
        end
      end

    end
  end
end
