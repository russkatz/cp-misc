#!/bin/bash

curl -X DELETE http://node1:8083/connectors/topic01-file
curl -H "Content-Type: application/json" -d @"makeconnector.json" -X POST http://node1:8083/connectors
