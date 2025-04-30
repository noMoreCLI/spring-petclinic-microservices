#!/bin/bash
CONFIG_SERVER_URL=http://config-server:8888 java -jar jar/*.jar --server.port=8082 --spring.profiles.active=hybrid,mysql 