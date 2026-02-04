require "pact_broker/ui/controllers/base"
require "pact_broker/logging"

module PactBroker
  module UI
    module Controllers
      class Sessions < Base
        include PactBroker::Logging

        get "/auth/openid_connect/callback" do
          auth_hash = request.env["omniauth.auth"]
          if auth_hash
            session[:user] = {
              name: auth_hash["info"]["name"],
              email: auth_hash["info"]["email"]
            }
            logger.info "User #{session[:user][:email]} logged in via OIDC"
            redirect "/"
          else
            logger.error "OIDC callback received but no auth hash found"
            halt 401, "Authentication failed"
          end
        end

        get "/logout" do
          session.clear
          redirect "/"
        end
      end
    end
  end
end
