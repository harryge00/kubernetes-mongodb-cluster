#! /bin/bash
# start mongoDB
mongod --replSet $mongo_replica_set_name &

# create the mongo-shell file: build_mongo_replication.js
echo $mongo_node_name
content="rs.initiate({_id:"
content="$content \"$mongo_replica_set_name\", members: [{_id:0, host:\"${mongo_node_name}0\" }"
for i in $(eval echo {1..$mongo_nodes_number}); do
	mongo_members="${mongo_members}, { _id:$i, host:\"$mongo_node_name$i\" }"
done;
content="$content $mongo_members]});"
echo $content > build_mongo_replication.js
echo "build_mongo_replication.js created"
cat ./build_mongo_replication.js

# Wait until mongoDB initialized
until nc -z localhost 27017
do
    echo "MongoDB initializing"
    sleep 1
done
echo "MongoDB initialized"
# Start replica set
mongo < ./build_mongo_replication.js

