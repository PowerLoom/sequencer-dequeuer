#!/bin/bash

set -e

echo 'populating dequeuer settings from environment values...';

if [ -z "$PROST_RPC_URL" ]; then
    echo "$PROST_RPC_URL not found, please set this in your .env!";
    exit 1;
fi

if [ -z "$PROTOCOL_STATE_CONTRACT" ]; then
    echo "PROTOCOL_STATE_CONTRACT not found, please set this in your .env!";
    exit 1;
fi

# Assuming default values for each variable if not provided
export REDIS_HOST="${REDIS_HOST:-redis}"
export REDIS_PORT="${REDIS_PORT:-6379}"

priv_key="/keys/key.txt"

if [[ -f "$priv_key" ]]; then
    RELAYER_PRIVATE_KEY=$(cat "$priv_key")
else
    RELAYER_PRIVATE_KEY=""
fi

export RELAYER_PRIVATE_KEY

cd config

# Template to actual settings.json manipulation
cp settings.example.json settings.json

# Replace placeholders in settings.json with actual values from environment variables
sed -i'.backup' -e "s#PROST_RPC_URL#$PROST_RPC_URL#" \
                -e "s#PROTOCOL_STATE_CONTRACT#$PROTOCOL_STATE_CONTRACT#" \
                -e "s#REDIS_HOST#$REDIS_HOST#" \
                -e "s#REDIS_PORT#$REDIS_PORT#" \
                -e "s#\"FULL_NODES\"#$FULL_NODES#" \
                -e "s#\"PROST_CHAIN_ID\"#$PROST_CHAIN_ID#" \
                -e "s#SLACK_REPORTING_URL#$SLACK_REPORTING_URL#" settings.json

# Cleanup backup file
rm settings.json.backup
