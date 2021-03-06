module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class Item < Base
        INPUT_ATTRIBUTES = [:name, :description, :category, :vendor_id, :image, :phone_prefixes].freeze
        VARIANTS_ATTRIBUTES = [:variants].freeze
        INPUT_ATTRIBUTES_WITH_VARIANTS = INPUT_ATTRIBUTES + VARIANTS_ATTRIBUTES
        TABLE_ATTRIBUTES = [:id, :sku, :category_id, :vendor_id, :created_at, :updated_at, :stock, :vendor].freeze
        VALID_ATTRIBUTES =  TABLE_ATTRIBUTES + INPUT_ATTRIBUTES_WITH_VARIANTS
        attr_reader *VALID_ATTRIBUTES

        QUERY_ATTRIBUTES = [:client, :category, :vendor_id, :sku, :name, :nominal, :price, :min_price, :max_price, :program_id].freeze
        SORT_ATTRIBUTES = [:sku, :name, :category].freeze

        def initialize(attributes)
          @id = attributes["id"]
          @sku = attributes["sku"]
          @name = attributes["name"]
          @description = attributes["description"]
          @category_id = attributes["category_id"]
          @category = attributes["category"]
          @vendor_id = attributes["vendor_id"]
          @image = attributes["image"]
          @stock = attributes["stock"]
          @vendor = attributes["vendor"]
          @created_at = Time.zone.parse(attributes["created_at"] + ' ' + Gcfs::Wrapper::Api.options[:timezone])
          @updated_at = Time.zone.parse(attributes["updated_at"] + ' ' + Gcfs::Wrapper::Api.options[:timezone])
          @variants = attributes["variants"].map{|variant| Gcfs::Wrapper::Api::ItemVariant.new variant } if attributes["variants"]
          @phone_prefixes = attributes["phone_prefixes"].map{|phone_prefix| Gcfs::Wrapper::Api::PhonePrefix.new phone_prefix } if attributes["phone_prefixes"]
        end

        def self.all(options={force: false})
          options = parsed_params options
          @options = configure_params query: { page: options[:page], per_page: options[:per_page] }.merge(options[:sort] ? {sort: options[:sort].select{|key, hash|SORT_ATTRIBUTES.include? key }} : {}).merge(options[:query] ? {query: options[:query].select{|key, hash|QUERY_ATTRIBUTES.include? key }} : {})

          @objects ||= []
          @objects[options[:per_page].to_i] ||= []
          options[:force] = true if @objects[options[:per_page].to_i][options[:page].to_i].kind_of?(Gcfs::Wrapper::Api::Error)
          @objects[options[:per_page].to_i] = [] if options[:force] and @objects[options[:per_page].to_i]
          @objects[options[:per_page].to_i][options[:page].to_i] = nil if options[:force]
          # @objects[options[:per_page].to_i][options[:page].to_i] ||= retrieve_url self.get("/v1/items", @options)
          retrieve_url self.get("/v1/items", @options)
        end

        def self.create(options={})
          options = parsed_params options
          options = parse_image options
          @options = configure_params body: options.select{|key, hash|INPUT_ATTRIBUTES_WITH_VARIANTS.include? key }.to_json
          object = retrieve_url self.post("/v1/items", @options)
          @objects = [] if object.kind_of?(self)
          object
        end

        def self.find(id)
          @options = configure_params
          object = retrieve_url self.get("/v1/items/" + id.to_s, @options)
        end

        def self.update(id, options={})
          options = parsed_params options
          options = parse_image options

          @options = configure_params body: options.select{|key, hash|INPUT_ATTRIBUTES.include? key }.to_json
          object = retrieve_url self.put("/v1/items/" + id.to_s, @options)
          @objects = [] if object.kind_of?(self)
          object
        end

        def self.destroy(id)
          @options = configure_params
          object = retrieve_url self.delete("/v1/items/" + id.to_s, @options)
          @objects = [] if object.kind_of?(self)
          object
        end

        private
        def self.parse_image(options={})
          if options[:image]
            if options[:image].kind_of?(ActionDispatch::Http::UploadedFile)
              tempfile = options[:image].tempfile
            elsif options[:image].kind_of?(File)
              tempfile = Tempfile.new("fileupload")
              tempfile.binmode
              tempfile.write(options[:image].read)
            end
            tempfile.rewind

            options[:image] = Base64.encode64(tempfile.read)
          end
          options = options.symbolize_keys
          if options[:variants]
            options[:variants].each do |variant|
              variant.delete_if {|key, value| value.blank? }
            end
            options[:variants] = options[:variants].map{|v|v.symbolize_keys}
          end
          options
        end
      end

    end
  end
end
