#!/bin/bash

mkdir -p webserver_logs
nohup python3 -m http.server 8000 > webserver_logs/server.log 2>&1 &
echo "Server started in background on port 8000"
echo "Access at http://localhost:8000"
echo "Check webserver_logs/server.log for details" 
