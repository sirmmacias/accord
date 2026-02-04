require "rack/pact_broker/ui_authentication"

module Rack
  module PactBroker
    describe UIAuthentication do
      let(:app) { double("app", call: [200, {}, []]) }
      let(:middleware) { UIAuthentication.new(app) }
      let(:env) { { "PATH_INFO" => "/", "rack.session" => {} } }

      before do
        allow(::PactBroker.configuration).to receive(:oidc_enabled).and_return(oidc_enabled)
        allow(::PactBroker.configuration).to receive(:authentication_configured?).and_return(true)
        allow(::PactBroker.configuration).to receive(:authenticate).and_return(nil)
        allow(::PactBroker.configuration).to receive(:authenticate_with_basic_auth).and_return(nil)
      end

      let(:oidc_enabled) { false }

      context "when accessing /auth/ path" do
        let(:env) { { "PATH_INFO" => "/auth/openid_connect" } }

        it "allows access without auth" do
          expect(app).to receive(:call).with(env)
          middleware.call(env)
        end
      end

      context "when authenticated via session" do
        let(:env) { { "PATH_INFO" => "/", "rack.session" => { user: "test" } } }

        it "allows access" do
          expect(app).to receive(:call).with(env)
          middleware.call(env)
        end
      end

      context "when not authenticated and OIDC is enabled" do
        let(:oidc_enabled) { true }

        it "redirects to OIDC login" do
          status, headers, _ = middleware.call(env)
          expect(status).to eq 302
          expect(headers["Location"]).to eq "/auth/openid_connect"
        end
      end

      context "when not authenticated and OIDC is disabled" do
        let(:oidc_enabled) { false }

        it "returns 401" do
          status, _ = middleware.call(env)
          expect(status).to eq 401
        end
      end
    end
  end
end
