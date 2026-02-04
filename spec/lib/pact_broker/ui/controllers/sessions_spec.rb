require "pact_broker/ui/controllers/sessions"
require "rack/test"

module PactBroker
  module UI
    module Controllers
      describe Sessions do
        include Rack::Test::Methods

        let(:app) { Sessions }

        describe "GET /auth/openid_connect/callback" do
          context "when successful" do
            before do
              get "/auth/openid_connect/callback", nil, {
                "omniauth.auth" => {
                  "info" => {
                    "name" => "Test User",
                    "email" => "test@example.com"
                  }
                },
                "rack.session" => {}
              }
            end

            it "redirects to root" do
              expect(last_response.status).to eq 302
              expect(last_response.headers["Location"]).to match(%r{/$})
            end

            it "sets the session user" do
              expect(last_request.env["rack.session"][:user]).to eq({
                name: "Test User",
                email: "test@example.com"
              })
            end
          end

          context "when failure" do
            it "returns 401 if no auth hash" do
              get "/auth/openid_connect/callback"
              expect(last_response.status).to eq 401
            end
          end
        end

        describe "GET /logout" do
          it "clears the session and redirects" do
            get "/logout", nil, { "rack.session" => { user: "foo" } }
            expect(last_request.env["rack.session"]).to be_empty
            expect(last_response.status).to eq 302
            expect(last_response.headers["Location"]).to match(%r{/$})
          end
        end
      end
    end
  end
end
