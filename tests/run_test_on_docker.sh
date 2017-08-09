#!/bin/bash -eu

image=$1

docker run -d --name mysql -e MYSQL_ALLOW_EMPTY_PASSWORD=yes mysql
docker run -d --name postgres postgres:alpine
docker run -d --name nginx nginx:alpine

sleep 10

if docker run -i --rm \
		  -v "$PWD:$PWD" -w "$PWD" \
		  -e LWT_LOG='* -> debug' \
		  --link mysql:mysql \
		  --link postgres:postgres \
		  --link nginx:nginx \
		  "$image" \
		  "./$(dirname $0)/run_test.sh"
then
	exit_code=0
else
	exit_code=1
fi

docker rm -f mysql postgres nginx

exit $exit_code
