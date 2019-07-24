#!/bin/bash

export KAFKA_HEAP_OPTS="-Xmx1G -Xms1G"

#echo Binding IPs
#sudo ifconfig en0 alias 10.10.0.10 255.255.255.0 
#sudo ifconfig en0 alias 10.10.0.20 255.255.255.0 
#sudo ifconfig en0 alias 10.10.0.30 255.255.255.0
#
#sudo route change 10.10.0.10 -interface en0
#sudo route change 10.10.0.20 -interface en0
#sudo route change 10.10.0.30 -interface en0

echo Starting zookeeper cluster
nohup ./node1/bin/zookeeper-server-start ./node1/etc/kafka/zookeeper.properties &
#sleep 1
#nohup ./node2/bin/zookeeper-server-start ./node2/etc/kafka/zookeeper.properties &
#sleep 1
#nohup ./node3/bin/zookeeper-server-start ./node3/etc/kafka/zookeeper.properties &
echo ""

sleep 30

echo Starting Kafka brokers
nohup ./node1/bin/kafka-server-start ./node1/etc/kafka/server.properties &
nohup ./node2/bin/kafka-server-start ./node2/etc/kafka/server.properties &
nohup ./node3/bin/kafka-server-start ./node3/etc/kafka/server.properties &
echo ""
sleep 20

echo Starting Schema Registry
./node1/bin/schema-registry-start -daemon ./node1/etc/schema-registry/schema-registry.properties
sleep 10
echo ""

echo Staring up connect cluster
nohup ./node1/bin/connect-distributed ./node1/etc/kafka/connect-distributed.properties &
nohup ./node2/bin/connect-distributed ./node2/etc/kafka/connect-distributed.properties &
nohup ./node3/bin/connect-distributed ./node3/etc/kafka/connect-distributed.properties &
echo ""

echo Starting Control Center
nohup ./node1/bin/control-center-start ./node1/etc/confluent-control-center/control-center.properties &
echo ""
echo ""
echo ""
