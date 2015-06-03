module Gcfs
  module Wrapper
    module Api

      module Util
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          private
          def retrieve_url(response)
            begin
              json = JSON.parse response.body
              if json.is_a? Array
                content = { data: json.map{|item| new(item) } }.merge!(parsed_pagination(response))
                Kaminari.paginate_array(content[:data], total_count: content[:total_count]).page(content[:page]).per(content[:per_page])
              elsif json.is_a? Hash
                if json.has_key? 'error'
                  raise Gcfs::Wrapper::Api::Error.new json['error']
                elsif json.has_key? 'diagnostic'
                  json
                else  
                  new(json)
                end
              else
                json
              end
            rescue Gcfs::Wrapper::Api::Error => e
              e
            end
          end

          def configure_params(options={})
            base_uri Gcfs::Wrapper::Api.options[:endpoint]
            debug_output $stderr if Gcfs::Wrapper::Api.options[:debug]

            params = { headers: { "Authorization"=> "Bearer #{Gcfs::Wrapper::Api.options[:access_token]}", "Content-Type"=> "application/json" } }
            params[:headers].merge!(options[:headers]) if options[:headers]
            params.merge!(query: options[:query]) if options[:query]
            params.merge!(body: options[:body]) if options[:body]
            params
          end

          def parsed_pagination response
            {
              total_count: response.headers["X-Total"].to_i,
              per_page:    response.headers["X-Per-Page"].to_i,
              page:        response.headers["X-Page"].to_i
            }
          end

          def parsed_params (options={})
            base_uri Gcfs::Wrapper::Api.options[:endpoint]
            debug_output $stderr if Gcfs::Wrapper::Api.options[:debug]

            options = options.symbolize_keys
            options.delete_if {|key, value| value.blank? }

            options.keys.select{|key|[:query,:sort].include? key}.each do |key|
              options[key] = options[key].symbolize_keys
              options[key].delete_if {|key, value| value.blank? }
            end
            options
          end

          def symbolize_keys my_hash
            my_hash.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
          end
        end

        def as_hash
          attributes = self.class.const_get('VALID_ATTRIBUTES')
          if self.kind_of?(Gcfs::Wrapper::Api::Item)
            attributes.select!{|key|!self.class.const_get('VARIANTS_ATTRIBUTES').include?(key)}
          elsif self.kind_of?(Gcfs::Wrapper::Api::Order)
            attributes.select!{|key|!(self.class.const_get('ITEMS_ATTRIBUTES')).include?(key)}
          end
          Hash[ * attributes.map { |key| [key, send(key)] }.flatten ]
        end

        def to_param
          self.id
        end

        def inspect
          vars = self.instance_variables.
            map{|v| "#{v}=#{instance_variable_get(v).inspect}"}.join(", ")
          "#<#{self.class}: #{vars}>"
        end
      end

    end
  end
end