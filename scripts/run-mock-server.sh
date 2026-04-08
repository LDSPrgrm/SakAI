#!/bin/bash

# Ensure prism is installed or use npx
if ! command -v npx &> /dev/null
then
    echo "npx could not be found. Please install Node.js/npm."
    exit 1
fi

echo "Starting SakAI Mock Server on port 8081..."
echo "Configuring Service Area: http://localhost:8081/service-area"

npx @stoplight/prism-cli mock openapi/swagger.yaml -p 8081
