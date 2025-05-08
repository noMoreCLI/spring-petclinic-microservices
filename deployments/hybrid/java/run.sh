#!/bin/bash
CONFIG_SERVER_URL=http://config-server:8888 java -Dappdynamics.async.instrumentation.strategy=constructor -jar jar/*.jar --server.port=8082 --spring.profiles.active=hybrid,mysql 