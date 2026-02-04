require "pact_broker/api/resources/authentication"

module Rack
  module PactBroker
    class UIAuthentication

      include ::PactBroker::Api::Resources::Authentication

      def initialize app
        @app = app
      end

      def call env
        if auth?(env)
          @app.call(env)
        elsif ::PactBroker.configuration.oidc_enabled
          [302, { "Location" => "/auth/openid_connect" }, []]
        else
          [401, { "WWW-Authenticate" => 'Basic realm="Restricted Area"' }, []]
        end
      end

      def auth? env
        return true if public_resource?(env)
        return true if session_authenticated?(env)
        authenticated?(nil, env["HTTP_AUTHORIZATION"])
      end

      def public_resource? env
        env["PATH_INFO"] =~ %r{^/auth/} || env["PATH_INFO"] =~ %r{^/logout}
      end

      def session_authenticated? env
        env["rack.session"] && env["rack.session"][:user]
      end
    end
  end
end
