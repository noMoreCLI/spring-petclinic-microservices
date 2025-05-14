#!/bin/bash

while true; do
  now=$(date)
  echo $now
  curl -X POST http://198.18.134.23:8080/api/visit/owners/3/pets/3/visits \
    -H "Content-Type: application/json" \
    -H "Accept: application/json, text/plain, */*" \
    -d "{\"date\":\"2025-05-13\",\"description\":\"Visit @ $now\"}"
  sleep 15
done
