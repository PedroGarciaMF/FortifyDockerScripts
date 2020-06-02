#!/bin/bash
echo "*** Creating fortify-ssc:dev ***"
docker build -t pedrogarciamf/fortify-ssc:dev .

echo "*** Starting ssc-dev ***"
docker run --detach --hostname fortify-ssc --publish 8180:8080 --name ssc-dev --network=fortify-network --ip=172.50.0.12 --add-host=fortify-mysql:172.50.0.10 --add-host=fortify-scancentral:172.50.0.13 pedrogarciamf/fortify-ssc:dev

sleep 120

echo "*** Stopping fortify-ssc:dev ***"
docker stop ssc-dev

sleep 30

echo "*** Flattening fortify-ssc:dev ***"
docker export -o fortify-ssc-dev.tar ssc-dev 

echo "*** Importing fortify-ssc:imported ***"
docker import fortify-ssc-dev.tar pedrogarciamf/fortify-ssc:imported

sleep 30

cd flattening
echo "*** Creating fortify-ssc:latest ***"
docker build -t pedrogarciamf/fortify-ssc:latest .

sleep 30

echo "*** Removing ssc-dev ***"
docker rm ssc-dev

echo "*** Creating fortify-ssc volumes ***"
docker volume create fortify_ssc_home
docker volume create fortify_ssc_logs
docker volume create fortify_ssc_search_index

echo "*** Starting fortify-ssc ***"
docker run --detach --hostname fortify-ssc --publish 8180:8080 --name fortify-ssc --volume fortify_ssc_home:/home/microfocus/.fortify --volume fortify_ssc_logs:/tools/fortify/tomcat/logs --volume fortify_ssc_search_index:/tools/fortify/search-index --network=fortify-network --ip=172.50.0.12 --add-host=fortify-mysql:172.50.0.10 --add-host=fortify-scancentral:172.50.0.13 --add-host=srv-fortify-linux:172.50.0.1 pedrogarciamf/fortify-ssc:latest

sleep 120

echo "*** Copying SQL folder ***"
docker cp fortify-ssc:/tools/fortify/sql .

echo "*** Copying init.token ***"
docker cp fortify-ssc:/home/microfocus/.fortify/ssc/init.token .

echo "*** Displaying init.token ***"
cat init.token && echo

echo "*** Done!!! ***"