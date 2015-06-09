module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class Token < Base
        VALID_ATTRIBUTES = [:access_token, :expired_at, :expires_in].freeze
        attr_reader *VALID_ATTRIBUTES

        def initialize(attributes)
          attributes = JSON.parse(attributes.to_json)
          @access_token = attributes['access_token']
          @expired_at = Time.zone.now + attributes['expires_in']
          @expires_in = attributes['expires_in']
          Gcfs::Wrapper::Api.access_token = attributes['access_token']
        end

        def expired?
          self.expired_at <= Time.now
        end

        def self.request
          @options = configure_params(
            body: {username: Gcfs::Wrapper::Api.options[:username], password: Gcfs::Wrapper::Api.options[:password], grant_type: Gcfs::Wrapper::Api.options[:grant_type], scope: Gcfs::Wrapper::Api.options[:scope]}.to_json, 
            headers: {"Authorization"=> "Basic " + Base64.urlsafe_encode64(Gcfs::Wrapper::Api.options[:key] + ':' + Gcfs::Wrapper::Api.options[:secret])}
          )
          token = retrieve_url self.post("/v1/token", @options)
          Gcfs::Wrapper::Api.token = token if token.kind_of?(Gcfs::Wrapper::Api::Token)
          token
        end
      end

    end
  end
end