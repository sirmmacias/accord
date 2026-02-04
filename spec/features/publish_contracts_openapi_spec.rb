require "spec_helper"

describe "Publish contracts with OpenAPI validation", validate_oas: true, type: :feature do
  let(:path) { "/contracts/publish" }
  let(:headers) { { "CONTENT_TYPE" => "application/json" } }
  let(:body) do
    {
      pacticipantName: "Consumer",
      pacticipantVersionNumber: "1.0.0",
      tags: ["dev"],
      branch: "main",
      contracts: [
        {
          consumerName: "Consumer",
          providerName: "Provider",
          specification: "pact",
          contentType: "application/json",
          content: encode_pact_content({ "consumer" => { "name" => "Consumer" }, "provider" => { "name" => "Provider" }, "interactions" => [] })
        }
      ]
    }.to_json
  end

  def encode_pact_content(pact_hash)
    Base64.strict_encode64(pact_hash.to_json)
  end

  it "successfully publishes a contract and validates against OAS" do
    post(path, body, headers)

    expect(last_response.status).to eq 200
    # The middleware/test helper usually asserts OAS compliance automatically if configured
  end
end
