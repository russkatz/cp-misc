#!/bin/sh

echo "Creating topic"
./node1/bin/kafka-topics --bootstrap-server node1:9092 --create --replication-factor 3 --partitions 3 --topic topic01

echo "Altering topic"
./node1/bin/kafka-configs --zookeeper node1:2181 --entity-type topics --entity-name topic01 --alter --add-config retention.ms=5000

echo "Creating file sink connector"
curl -X DELETE http://node1:8083/connectors/topic01-file
curl -H "Content-Type: application/json" -d @"makeconnector.json" -X POST http://node1:8083/connectors

echo "Creating cassandra connector"
curl -X DELETE http://node1:8083/connectors/cas01
curl -H "Content-Type: application/json" -d @"cassandraConnector.json" -X POST http://node1:8083/connectors

echo "creating cassandra table"
/opt/cassandra/current/bin/cqlsh -e "CREATE TABLE IF NOT EXISTS test.topic01 ( sensor text,time text,reading float,type text,PRIMARY KEY (sensor, time, type));"
