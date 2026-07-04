#!/bin/bash
set -e

# Start xrdp
service xrdp start
sleep 2

# Start ngrok in background
nohup ngrok tcp 3389 --authtoken "$NGROK_AUTH_TOKEN" --log /tmp/ngrok.log > /dev/null 2>&1 &
disown

# Wait for ngrok and grab the URL
URL=""
for i in {1..30}; do
  sleep 2
  URL=$(curl -s http://localhost:4040/api/tunnels 2>/dev/null | grep -o '"public_url":"[^"]*"' | head -1 | cut -d'"' -f4)
  [ -n "$URL" ] && break
done

if [ -n "$URL" ]; then
  HOST=${URL#tcp://}
  echo ""
  echo "==========================================="
  echo "  RDP Server is LIVE!"
  echo ""
  echo "  Host:     $HOST"
  echo "  Username: root"
  echo "  Password: RDPpassword!"
  echo "==========================================="
  echo "  Your files live at /workspaces and persist."
  echo "==========================================="
else
  echo "ngrok did not start. Log:"
  cat /tmp/ngrok.log
  exit 1
fi
