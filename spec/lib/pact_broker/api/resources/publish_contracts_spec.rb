require "pact_broker/api/resources/publish_contracts"
require "pact_broker/api"

module PactBroker
  module Api
    module Resources
      describe PublishContracts do
        # Create a real Webmachine app that routes to the resource, or use a helper that does it
        let(:app) do
          PactBroker::API
        end

        let(:path) { "/contracts/publish" }

        let(:params) do
          {
            pacticipantName: "Consumer",
            pacticipantVersionNumber: "1.0.0",
            contracts: [
              {
                consumerName: "Consumer",
                providerName: "Provider",
                specification: "pact",
                contentType: "application/json",
                content: Base64.strict_encode64({ consumer: { name: "Consumer" }, provider: { name: "Provider" }, interactions: [] }.to_json)
              }
            ]
          }
        end

        before do
          allow(PactBroker::Contracts::Service).to receive(:publish).and_return(double("results"))
          allow(PactBroker::Api::Decorators::PublishContractsResultsDecorator).to receive(:new).and_return(double("decorator", to_json: {}.to_json))
        end

        context "with valid parameters" do
          it "returns a 200 OK" do
            post path, params.to_json, { "CONTENT_TYPE" => "application/json" }
            expect(last_response.status).to eq 200
          end

          it "calls the contract service" do
            expect(PactBroker::Contracts::Service).to receive(:publish)
            post path, params.to_json, { "CONTENT_TYPE" => "application/json" }
          end
        end

        context "with validation errors" do
          before do
            params.delete(:pacticipantName)
          end

          it "returns a 400 Bad Request" do
            post path, params.to_json, { "CONTENT_TYPE" => "application/json" }
            expect(last_response.status).to eq 400
          end
        end
      end
    end
  end
end
