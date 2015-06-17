module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class Dtcell < Base

        SORT_ATTRIBUTES = [:operator, :operator_code].freeze
        TABLE_ATTRIBUTES = [:id, :description, :nominal, :price]
        INPUT_ATTRIBUTES = [:phone_number, :qty, :recepient, :metadata].freeze

        TABLE_WITH_SORT_ATTRIBUTES = TABLE_ATTRIBUTES + SORT_ATTRIBUTES
        VALID_ATTRIBUTES = INPUT_ATTRIBUTES + TABLE_WITH_SORT_ATTRIBUTES

        TOPUP_ATTRIBUTES = SORT_ATTRIBUTES + INPUT_ATTRIBUTES

        attr_reader *VALID_ATTRIBUTES

        def initialize(attributes)
          attributes = JSON.parse(attributes.to_json)
          @id = attributes["id"]
          @description = attributes["description"]
          @operator = attributes["operator"]
          @operator_code = attributes["operator_code"]
          @description = attributes["description"]
          @nominal = attributes["nominal"]
          @price = attributes["price"]
        end

        def self.topup(options={})
          options = parsed_params options
          @options = configure_params body: options.select{|key, hash|TOPUP_ATTRIBUTES.include? key }.to_json

          retrieve_url_topup self.post("/v1/dtcell/credit/topup", @options)
        end

        def self.all(options={})
          options = parsed_params options
          @options = configure_params query: { page: options[:page], per_page: options[:per_page] }.merge(options[:sort] ? {sort: options[:sort].select{|key, hash|SORT_ATTRIBUTES.include? key }} : {})
          categories = retrieve_url self.get("/v1/dtcell/product", @options)
        end

        def self.create(options={})
          options = parsed_params options
          @options = configure_params body: options.select{|key, hash|TABLE_WITH_SORT_ATTRIBUTES.include? key }.to_json
          object = retrieve_url self.post("/v1/dtcell/product", @options)
          @objects = [] if object.kind_of?(self)
          object
        end

        def self.find(id)
          @options = configure_params
          object = retrieve_url self.get("/v1/dtcell/product/" + id.to_s, @options)
        end

        def self.update(id, options={})
          options = parsed_params options

          @options = configure_params body: options.select{|key, hash|TABLE_WITH_SORT_ATTRIBUTES.include? key }.to_json
          object = retrieve_url self.put("/v1/dtcell/product/" + id.to_s, @options)
          @objects = [] if object.kind_of?(self)
          object
        end

        def self.destroy(id)
          @options = configure_params
          object = retrieve_url self.delete("/v1/dtcell/product/" + id.to_s, @options)
          @objects = [] if object.kind_of?(self)
          object
        end

        private
        def self.retrieve_url_topup(response)
          begin
            json = JSON.parse response.body
            if json.has_key? 'error'
              raise Gcfs::Wrapper::Api::Error.new json['error']
            else  
              Gcfs::Wrapper::Api::DtcellStatus.new json
            end
          rescue Gcfs::Wrapper::Api::Error => e
            e
          end
        end
        
      end
    end
  end
end