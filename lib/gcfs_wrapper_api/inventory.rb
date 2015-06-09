module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class Inventory < Base
        INPUT_ATTRIBUTES = [:type, :description, :item_id, :variant_id, :quantity, :metadata].freeze
        TABLE_ATTRIBUTES = [:id, :item, :variant, :created_at, :updated_at].freeze
        VALID_ATTRIBUTES =  TABLE_ATTRIBUTES + INPUT_ATTRIBUTES
        attr_reader *VALID_ATTRIBUTES

        SORT_ATTRIBUTES = [:description, :item, :variant, :quantity, :created_at].freeze

        def initialize(attributes)
          @id = attributes["id"]
          @type = attributes["type"]
          @description = attributes["description"]
          @item = Gcfs::Wrapper::Api::Item.new(attributes["item"]) if attributes["item"]
          @variant = Gcfs::Wrapper::Api::ItemVariant.new(attributes["variant"]) if attributes["variant"]
          @quantity = attributes["quantity"]
          @metadata = attributes["metadata"]
          @created_at = Time.zone.parse(attributes["created_at"] + ' ' + Gcfs::Wrapper::Api.options[:timezone])
          @updated_at = Time.zone.parse(attributes["updated_at"] + ' ' + Gcfs::Wrapper::Api.options[:timezone])
        end

        def self.all(type, options={force: false})
          type = type.to_s
          type.downcase!
          types = ['incoming', 'outgoing']
          return Gcfs::Wrapper::Api::Error.new('invalid_type') unless types.include? type

          options = parsed_params options
          @options = configure_params query: { page: options[:page], per_page: options[:per_page] }.merge(options[:sort] ? {sort: options[:sort].select{|key, hash|SORT_ATTRIBUTES.include? key }} : {})

          @objects ||= {}
          @objects[type] ||= []
          @objects[type][options[:per_page].to_i] ||= []
          options[:force] = true if @objects[type][options[:per_page].to_i][options[:page].to_i].kind_of?(Gcfs::Wrapper::Api::Error)
          @objects[type][options[:per_page].to_i] = [] if options[:force] and @objects[type][options[:per_page].to_i]
          @objects[type][options[:per_page].to_i][options[:page].to_i] = nil if options[:force]
          @objects[type][options[:per_page].to_i][options[:page].to_i] ||= retrieve_url self.get("/v1/inventories/"+type.to_s, @options)
        end

        def self.create(options={})
          options = parsed_params options
          @options = configure_params body: options.select{|key, hash|INPUT_ATTRIBUTES.include? key }.to_json
          object = retrieve_url self.post("/v1/inventories", @options)
          @objects = {} if object.kind_of?(self)
          object
        end
      end

    end
  end
end