require "pact_broker/app"

module PactBroker
  describe App do
    before do
      allow(PactBroker::DB).to receive(:run_migrations)
      allow(PactBroker::DB).to receive(:version).and_return(1)
      allow(PactBroker::DB).to receive(:is_current?).and_return(true)

      # Mock the database connection to avoid actual DB access
      allow(PactBroker).to receive(:create_database_connection).and_return(double("connection", extension: nil, timezone: :utc))
    end

    class TestApp < PactBroker::App
      def configure_database_connection
        # do nothing
      end

      def configure_sucker_punch
         # do nothing
      end

      # Override to avoid loading actual DB stuff that might fail
      def prepare_database
        # do nothing
      end
    end

    let(:app) do
      TestApp.new do | configuration |
        configuration.database_connection = double("connection")
        configuration.oidc_enabled = oidc_enabled
        configuration.openapi_enabled = openapi_enabled
        configuration.oidc_issuer = "https://issuer.com"
        configuration.oidc_client_id = "id"
        configuration.oidc_client_secret = "secret"
        configuration.openapi_file_path = "pact_broker_oas.yaml"
        configuration.base_urls = ["http://localhost:9292"]
      end
    end

    let(:oidc_enabled) { false }
    let(:openapi_enabled) { false }

    context "when OIDC and OpenAPI are enabled" do
      let(:oidc_enabled) { true }
      let(:openapi_enabled) { true }

      it "adds the middlewares" do
        builder = double("Rack::Builder")
        allow(Rack::Builder).to receive(:new).and_return(builder)
        allow(builder).to receive(:use)
        allow(builder).to receive(:use_when)
        allow(builder).to receive(:run)
        allow(builder).to receive(:map)
        allow(builder).to receive(:call)

        expect(builder).to receive(:use).with(OmniAuth::Builder)
        expect(builder).to receive(:use).with(OpenapiFirst::Middlewares::RequestValidation, "pact_broker_oas.yaml")

        app.call(Rack::MockRequest.env_for("/"))
      end
    end

    context "when OIDC and OpenAPI are disabled" do
      let(:oidc_enabled) { false }
      let(:openapi_enabled) { false }

      it "does not add the middlewares" do
        builder = double("Rack::Builder")
        allow(Rack::Builder).to receive(:new).and_return(builder)
        allow(builder).to receive(:use)
        allow(builder).to receive(:use_when)
        allow(builder).to receive(:run)
        allow(builder).to receive(:map)
        allow(builder).to receive(:call)

        expect(builder).not_to receive(:use).with(OmniAuth::Builder)
        expect(builder).not_to receive(:use).with(OpenapiFirst::Middlewares::RequestValidation, anything)

        app.call(Rack::MockRequest.env_for("/"))
      end
    end
  end
end
