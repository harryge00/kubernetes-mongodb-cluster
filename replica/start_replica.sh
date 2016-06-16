#!/bin/bash

if [ ! -z "$mongo_node_name" ] && [ ! -z "$mongo_replica_set_name" ]; then
  # Create a mongo shell to initialize the replica set.
  # Required environmental variables: $mongo_replica_set_name, $mongo_nodes_number, $mongo_node_name
  content="rs.initiate({_id:\"$mongo_replica_set_name\", members: ["
  mongo_members="{_id: 0, host:\"${mongo_node_name}-0\"}"
  i=1
  while [ $i -lt $mongo_nodes_number ]; do
    mongo_members="$mongo_members, {_id:$i, host:\"${mongo_node_name}-$i\"}"
    ((i++));
  done;
  content="$content $mongo_members]});"
  # create the mongo-shell file: replica_init.js
  echo $content > replica_init.js

  mongod --replSet $mongo_replica_set_name &
  until nc -z localhost 27017
  do
      echo "Wait mongoDB to be ready"
      sleep 1
  done
  echo "MongoDB initialized"
  # Start replica set
  mongo < ./replica_init.js
  tail -f /dev/null
else
	  echo "Starting up in standalone mode"
    mongod
fi