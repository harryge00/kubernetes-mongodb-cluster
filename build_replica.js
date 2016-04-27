rs.initiate({_id:"my_replica_set", members:
	[{ _id:0, host:"mongo-svc-a" },
	{ _id:1, host:"mongo-svc-b" },
	{ _id:2, host:"mongo-svc-c" }
]});   

