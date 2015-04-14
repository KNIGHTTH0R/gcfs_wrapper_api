module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class Item < Base
        INPUT_ATTRIBUTES = [:name, :category, :image].freeze
        VARIANTS_ATTRIBUTES = [:variants].freeze
        INPUT_ATTRIBUTES_WITH_VARIANTS = INPUT_ATTRIBUTES + VARIANTS_ATTRIBUTES
        TABLE_ATTRIBUTES = [:id, :sku, :created_at, :updated_at].freeze
        VALID_ATTRIBUTES =  TABLE_ATTRIBUTES + INPUT_ATTRIBUTES_WITH_VARIANTS
        attr_reader *VALID_ATTRIBUTES

        QUERY_ATTRIBUTES = [:client, :category, :sku, :name, :nominal, :price].freeze
        SORT_ATTRIBUTES = [:sku, :name, :category].freeze

        def initialize(attributes)
          @id = attributes["id"]
          @sku = attributes["sku"]
          @name = attributes["name"]
          @category = attributes["category"]
          @image = attributes["image"]
          @created_at = attributes["created_at"]
          @updated_at = attributes["updated_at"]
          @variants = attributes["variants"].map{|variant| Gcfs::Wrapper::Api::ItemVariant.new variant } if attributes["variants"]
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