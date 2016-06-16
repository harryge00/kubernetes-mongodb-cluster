rs.initiate({_id:"my_replica_set", members:
	[{ _id:0, host:"mongo-node-1" },
	{ _id:1, host:"mongo-node-b" },
	{ _id:2, host:"mongo-node-c" }
]});   

