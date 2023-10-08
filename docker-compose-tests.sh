#!/bin/bash
set -e

docker-compose down --remove-orphans || echo new or partial install
#if [ ! -e config/tls/int_server/certs/localhost.pem ]; then
#  rm -rf config/tls
#  docker-compose up chainsmith
#fi

for e in postgres orioledb; do
  docker-compose up -d "${e}"
  for ((i=0;i<60;i++)); do
    docker-compose exec -u postgres "${e}" pg_isready && break
    sleep 1
  done
  docker-compose exec -u postgres "${e}" psql -f "/host/schema/${e}.sql"
  export PGHOST="${e}"
  docker-compose up pg_tps_optimizer
  docker-compose down "${e}"
done
