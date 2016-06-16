#! /bin/bash

content="rs.initiate({_id:\"$mongo_replica_set_name\", members: ["
mongo_members="{_id: 0, host:\"${mongo_node_name}-0\"}\n"
i=1
while [ $i -lt $mongo_nodes_number ]; do
	mongo_members="$mongo_members, {_id:$i, host:\"${mongo_node_name}-$i\"}"
	((i++));
done;
content="$content $mongo_members]});"
# create the mongo-shell file: replica_init.js
echo $content > replica_init.js