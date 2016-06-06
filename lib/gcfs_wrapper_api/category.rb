module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class Category < Base
        INPUT_ATTRIBUTES = [:name, :label].freeze
        TABLE_ATTRIBUTES = [:id].freeze
        VALID_ATTRIBUTES =  TABLE_ATTRIBUTES + INPUT_ATTRIBUTES
        attr_reader *VALID_ATTRIBUTES

        SORT_ATTRIBUTES = [:name].freeze

        def initialize(attributes)
          @id = attributes["id"]
          @name = attributes["name"]
          @label = attributes["label"]
        end

        def self.all(options={force: false})
          options = parsed_params options
          @options = configure_params query: { page: options[:page], per_page: options[:per_page] }.merge(options[:sort] ? {sort: options[:sort].select{|key, hash|SORT_ATTRIBUTES.include? key }} : {})

          @objects ||= []
          @objects[options[:per_page].to_i] ||= []
          options[:force] = true if @objects[options[:per_page].to_i][options[:page].to_i].kind_of?(Gcfs::Wrapper::Api::Error)
          @objects[options[:per_page].to_i] = [] if options[:force] and @objects[options[:per_page].to_i]
          @objects[options[:per_page].to_i][options[:page].to_i] = nil if options[:force]
          # @objects[options[:per_page].to_i][options[:page].to_i] ||= retrieve_url self.get("/v1/categories", @options)
          categories = retrieve_url self.get("/v1/categories", @options)
        end

        def self.create(options={})
          options = parsed_params options
          @options = configure_params body: options.select{|key, hash|INPUT_ATTRIBUTES.include? key }.to_json
          object = retrieve_url self.post("/v1/categories", @options)
          @objects = [] if object.kind_of?(self)
          object
        end

        def self.find(id)
          @options = configure_params
          object = retrieve_url self.get("/v1/categories/" + id.to_s, @options)
        end

        def self.update(id, options={})
          options = parsed_params options
          @options = configure_params body: options.select{|key, hash|INPUT_ATTRIBUTES.include? key }.to_json
          object = retrieve_url self.put("/v1/categories/" + id.to_s, @options)
          @objects = [] if object.kind_of?(self)
          object
        end

        def self.destroy(id)
          @options = configure_params
          object = retrieve_url self.delete("/v1/categories/" + id.to_s, @options)
          @objects = [] if object.kind_of?(self)
          object
        end
      end

    end
  end
end