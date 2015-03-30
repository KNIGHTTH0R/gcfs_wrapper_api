module Gcfs
  module Wrapper
    module Api
      extend Configuration

      class Base
        include HTTParty
        include Util
        base_uri Gcfs::Wrapper::Api.options[:endpoint]
        debug_output $stderr if Gcfs::Wrapper::Api.options[:debug]
      end

    end
  end
end