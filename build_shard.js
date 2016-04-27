rs.initiate({
	_id:"configReplSet", 
	configsvr: true,
	members:
	[{ _id:0, host:"mongo-svc-configsvr-a:27019"  },
	{ _id:1, host:"mongo-svc-configsvr-b:27019"  },
	{ _id:2, host:"mongo-svc-configsvr-c:27019"  }
]});