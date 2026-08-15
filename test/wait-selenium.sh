#!/bin/bash -e

for i in $(seq 1 120); do
  if python3 -c "import urllib.request; urllib.request.urlopen('http://selenium:4444/wd/hub/status', timeout=2)" 2>/dev/null; then
    echo "selenium is ready"
    exit 0
  fi
  echo "waiting for selenium"
  sleep 1
done

echo "selenium did not become ready"
exit 1
