#!/bin/bash
set -e

# Default values
PACT_BROKER_BASE_URL=${PACT_BROKER_BASE_URL:-http://localhost:9292}
PACT_BROKER_TOKEN=${PACT_BROKER_TOKEN:-}
PACTICIPANT_NAME=${PACTICIPANT_NAME:-Provider}
CONSUMER_NAME=${CONSUMER_NAME:-Consumer}
VERSION=${VERSION:-$(git rev-parse HEAD)}
BRANCH=${BRANCH:-$(git rev-parse --abbrev-ref HEAD)}
OAS_FILE=${OAS_FILE:-samples/provider/oas/provider-oas.json}

# Find OAS file
if [ ! -f "$OAS_FILE" ]; then
    # Try finding relative to script location
    SCRIPT_DIR=$(dirname "$0")
    OAS_FILE="$SCRIPT_DIR/../oas/provider-oas.json"
fi

if [ ! -f "$OAS_FILE" ]; then
    echo "Error: OAS file not found at $OAS_FILE"
    exit 1
fi

# Base64 encode content (Linux/Mac compatible)
if [[ "$OSTYPE" == "darwin"* ]]; then
  CONTENT=$(base64 < "$OAS_FILE")
else
  CONTENT=$(base64 -w 0 "$OAS_FILE")
fi

# Construct JSON payload
cat <<EOF > payload.json
{
  "pacticipantName": "$PACTICIPANT_NAME",
  "pacticipantVersionNumber": "$VERSION",
  "contracts": [
    {
      "consumerName": "$CONSUMER_NAME",
      "providerName": "$PACTICIPANT_NAME",
      "specification": "oas",
      "contentType": "application/json",
      "content": "$CONTENT"
    }
  ],
  "tags": ["$BRANCH"],
  "branch": "$BRANCH"
}
EOF

echo "Publishing OAS to $PACT_BROKER_BASE_URL/contracts/publish..."

CURL_ARGS=(-v -X POST "$PACT_BROKER_BASE_URL/contracts/publish" -H "Content-Type: application/json" -d @payload.json)

if [ -n "$PACT_BROKER_TOKEN" ]; then
  CURL_ARGS+=(-H "Authorization: Bearer $PACT_BROKER_TOKEN")
fi

curl "${CURL_ARGS[@]}"

rm payload.json
echo "Done."
