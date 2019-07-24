#!/bin/bash

while [ 1 ]; do cat produce.json | ./node1/bin/kafka-console-producer --broker-list node1:9092 --topic topic01 ; done
