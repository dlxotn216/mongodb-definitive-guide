#!/bin/bash

docker-compose up -d
docker exec mongo-1 bash -c "chmod +x /scripts/setup.sh"

sleep 15
docker exec mongo-1 /scripts/setup.sh
