#!/usr/bin/env bash



curl -X 'POST' \
  'http://localhost:8000/opml/' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "opml_url": "https://everest.castbox.fm/account/tools/opml/export?u=fdd32d0ecc1d42ad96e93662c128388f&t=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjJhNzVmNmUwYzg2ZjQ2ZDE4MDYyNzNkODI3YWI0ZDNmIn0.eyJ1aWQiOiJmZGQzMmQwZWNjMWQ0MmFkOTZlOTM2NjJjMTI4Mzg4ZiIsInN1aWQiOjE1MzI1NDQ2LCJsb2NhbGUiOiJlbiIsImVtYWlsIjoidW5jNzQxQGdtYWlsLmNvbSIsImlzcyI6InNlcnZpY2VAY2FzdGJveC5mbSIsImV4cCI6MTU2OTc2NDEyMywicHJvdmlkZXIiOiJnb29nbGUiLCJpYXQiOjE1NjcxNzIxMjMsImlkIjoiMTA3ODQ5NDMwMjMyOTY3NDUyNDU1IiwibmFtZSI6IkFsZXgifQ.OYcSivv-T-ArPLt7x9xZXd-sW1dAROKnJZGuwNIEDh8AoWe0cp5L5ENi1EgF_orgIRBTPXqpQjdP9Zm8NQjDmIZeNAfoZFVPqtpXiYBbRosURfDIDrKq5G58tpdnGCtVhMQAFyy6RkITthFTUCf_PuSipVEX5nEgkuftgVEhPcEz6IB9fj2mTw5N7kdcJCI8jCLQctbicsMkiZXkZ-0fJ6Rm_90RB-31DoMcH8gt4TwP2D4cbRLefJgT2EFrHiFY6uC8Zf9F9S4dK9VMnTIKlwNGfBx869-ZYJBwKcfiChEJRlYnNtAOYangNGBODSP1K2_cPk3vwftg8EeFRDXKHQ",
  "selected_shows": ["The CyberWire Daily", "Risky Business"]
}'

curl -X 'POST' \
  'http://localhost:8000/opml_file/' \
  -H 'accept: application/json' \
  -H 'Content-Type: multipart/form-data' \
  -F 'opml_file=@example.opml;type=text/x-opml+xml' \
  -F 'selected_shows='
