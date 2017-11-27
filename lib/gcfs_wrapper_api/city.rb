module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class City < Base
        INPUT_ATTRIBUTES = [].freeze
        TABLE_ATTRIBUTES = [:id, :name, :price, :categories].freeze
        VALID_ATTRIBUTES =  TABLE_ATTRIBUTES + INPUT_ATTRIBUTES
        attr_reader *VALID_ATTRIBUTES

        SORT_ATTRIBUTES = [:name].freeze

        def initialize(attributes)
          @id = attributes["id"]
          @name = attributes["name"]
          @price = attributes["price"]
          @categories = attributes["categories"]
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
          cities = retrieve_url self.get("/v1/cities/old", @options)
        end

        def self.complete(options={})
          options = parsed_params options
          query = { :complete => 1 }
          query[:city] = options[:city] if options[:city]
          @options = configure_params query: query
          cities = retrieve_url self.get("/v1/cities", @options)
        end

      end

    end
  end
end