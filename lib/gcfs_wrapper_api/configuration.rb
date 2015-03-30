module Gcfs
  module Wrapper
    module Api
      module Configuration
        VALID_CONFIG_KEYS     = [:endpoint, :key, :secret, :username, :password, :grant_type, :scope, :token, :access_token, :debug].freeze
     
        DEFAULT_ENDPOINT      = 'localhost:3000'
        DEFAULT_GRANT_TYPE    = 'password'
        DEFAULT_SCOPE         = 'offline_access'
        DEFAULT_KEY           = '12345678901234567890'
        DEFAULT_SECRET        = '12345678901234567890'
        DEFAULT_Bearer        = '12345678901234567890'
        DEFAULT_DEBUG         = false
     
        attr_accessor *VALID_CONFIG_KEYS
     
        # Make sure we have the default values set when we get 'extended'
        def self.extended(base)
          base.reset
        end
     
        def reset
          self.endpoint     = DEFAULT_ENDPOINT
          self.grant_type   = DEFAULT_GRANT_TYPE
          self.scope        = DEFAULT_SCOPE
          self.key          = DEFAULT_KEY
          self.secret       = DEFAULT_SECRET
          self.access_token = DEFAULT_Bearer
          self.debug        = DEFAULT_DEBUG
        end
        
        def configure
          yield self
        end

        def options
          Hash[ * VALID_CONFIG_KEYS.map { |key| [key, send(key)] }.flatten ]
        end
      end
    end
  end
end