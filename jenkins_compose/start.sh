#!/bin/bash
set -e

echo "========================================"
echo " Jenkins Deployment"
echo "========================================"

export DOCKER_GID=$(stat -c '%g' /var/run/docker.sock)

echo "Docker Socket GID : ${DOCKER_GID}"

docker compose -f docker-compose.default.yml down

docker compose -f docker-compose.default.yml build --no-cache

docker compose -f docker-compose.default.yml up -d

echo
echo "========================================"
echo " Verification"
echo "========================================"

echo
echo "Jenkins User Information:"
docker exec -it jenkins id

echo
echo "Docker Access Test:"
docker exec -it jenkins docker ps

echo
echo "========================================"
echo " Jenkins deployed successfully."
echo "========================================"
