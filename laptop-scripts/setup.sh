#!/bin/sh

./node1/bin/kafka-topics --bootstrap-server node1:9092 --create --replication-factor 3 --partitions 3 --topic topic01

#./node1/bin/kafka-topics --bootstrap-server node1:9092 --alter --topic topic01 --partitions 3 --config retention.ms=5000
./node1/bin/kafka-configs --zookeeper node1:2181 --entity-type topics --entity-name topic01 --alter --add-config retention.ms=5000
sleep 6

curl -X DELETE http://node1:8083/connectors/topic01-file
curl -H "Content-Type: application/json" -d @"makeconnector.json" -X POST http://node1:8083/connectors


