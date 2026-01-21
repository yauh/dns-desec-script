#!/bin/bash

# Load config
CONFIG_FILE="/path/to/desec-updater.conf"
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: Config file $CONFIG_FILE not found."
  exit 1
fi
source "$CONFIG_FILE"

if [[ -z "$TOKEN" || -z "$DOMAINS" ]]; then
  echo "Error: TOKEN or DOMAINS not set in config."
  exit 1
fi

# Fetch current public IPv4
CURRENT_IP=$(curl -s4 https://checkipv4.dedyn.io/)
if [[ -z "$CURRENT_IP" ]]; then
  echo "$(date '+%a %b %d %T %Y'): Failed to fetch current IP."
  exit 1
fi

echo "$(date '+%a %b %d %T %Y'): Current IP: $CURRENT_IP"

# Process each domain
for DOMAIN in $DOMAINS; do
  # Query current A record (first IP if multiple)
  DNS_IP=$(dig +short A "$DOMAIN" @1.1.1.1 | head -n1 | tr -d '\n')

  if [[ "$CURRENT_IP" == "$DNS_IP" ]]; then
    echo "$(date '+%a %b %d %T %Y'): $DOMAIN A record already correct ($CURRENT_IP). Skipping."
    continue
  fi

  echo "$(date '+%a %b %d %T %Y'): Updating $DOMAIN from $DNS_IP to $CURRENT_IP"

  # Update via deSEC DynDNS API (uses connection IP automatically)
  RESPONSE=$(curl -sS -w "%{http_code}" \
    --header "Authorization: Token $TOKEN" \
    "https://update.dedyn.io/?hostname=$DOMAIN")

  HTTP_CODE="${RESPONSE: -3}"
  BODY="${RESPONSE%???}"

  if [[ "$HTTP_CODE" == "200" && "$BODY" == "good" ]]; then
    echo "$(date '+%a %b %d %T %Y'): Success: $DOMAIN updated."
  else
    echo "$(date '+%a %b %d %T %Y'): Error updating $DOMAIN: HTTP $HTTP_CODE, body: $BODY"
  fi
done
