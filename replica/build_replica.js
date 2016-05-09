rs.initiate({_id:"my_replica_set", members:
	[{ _id:0, host:"mongo-replica-svc-a" },
	{ _id:1, host:"mongo-replica-svc-b" },
	{ _id:2, host:"mongo-replica-svc-c" }
]});   

