# kubernetes-mongodb-cluster
Deploy a mongo cluster on kubernetes. 
Based on [Enabling Microservices: Containers & Orchestration Explained](https://www.mongodb.com/collateral/microservices-containers-and-orchestration-explained)

# MongoDB replica set

`replica/mongo-replica-rs.yaml` creates 3 mongodb replication controllers their corresponding services. The 3 mongodb instances can consist a replica set named as "my_replica_set".

One of mongodb replication controller's yaml:
```
apiVersion: v1
kind: ReplicationController
metadata:
  name: mongo-replica-rc1
  labels:
    name: mongo-replica-rc
spec:
  replicas: 1
  selector:
    name: mongo-replica-node1
  template:
    metadata:
      labels:
        name: mongo-replica-node1
    spec:
      containers:
      - name: mongo-replica-node1
        image: index.caicloud.io/caicloud/mongo:3.2
        command:
        - mongod
        - "--replSet"
        - my_replica_set
        ports:
        - containerPort: 27017
        volumeMounts:
        - name: mongo-replica-storage1
          mountPath: /data/db
      volumes:

      - name: mongo-replica-storage1
        emptyDir: {}
```
You can change "index.caicloud.io/caicloud/mongo:3.2" to any mongo's docker image supports replica-set.
One mongo service yaml:
```
apiVersion: v1
kind: Service
metadata:
  name: mongo-replica-svc-a
  labels:
    name: mongo-replica-svc-a
spec:
  clusterIP: None
  ports:
  - port: 27017
    targetPort: 27017
    protocol: TCP
    name: mongo-replica-svc-a
  selector:
    name: mongo-replica-node1
```

## How to deploy a replica set

To start them, run 
`kubectl create -f ./replica/mongo-replica-rs.yaml`

### Manual initialization of the replica set

After the 3 mongo replication controllers have been created and finished initialzation, execute commands in one containers:

`kubectl exec -ti mongo-replica-rc1-dsw20 bash ` (run `kubectl get pods` first to get the pod name)

```
root@mongo-replica-rc1-dsw20:/# mongo
> rs.initiate({_id:"my_replica_set", members:
  [{ _id:0, host:"mongo-replica-svc-a" },
  { _id:1, host:"mongo-replica-svc-b" },
  { _id:2, host:"mongo-replica-svc-c" }
]});
```
If mongo shell returns `{ "ok" : 1 }`, congratulations!
Run `rs.status()` to check the status of replica set.

#### Automatical initialization of the replica set

`kubectl exec -ti mongo-replica-rc1-dsw20 mongo < replica/build_replica.js`

build_replica.js:

```
rs.initiate({_id:"my_replica_set", members:
  [{ _id:0, host:"mongo-replica-svc-a" },
  { _id:1, host:"mongo-replica-svc-b" },
  { _id:2, host:"mongo-replica-svc-c" }
]})
```

#### Issue
Note: Since Kubernetes v1.2 has a [bug](https://github.com/kubernetes/kubernetes/issues/19930) that a pod cannot connect to itself via its service's cluster IP. I used `headless` services, which means all services do not have cluster IP and can be accessed only inside K8s cluster through service name like `mongo-replica-svc-a`. E.g. `mongodb://service-name:27017/test`

#### Partition tolerance

If less than half of all the repliction controllers are killed, the replica set can still work. If the number of replica set members are even, you may add a mongodb arbiter to create an "imbalance".

#### Driver connectting to mongo 
For example: node.js
```
var connectionString = 'mongodb://mongo-replica-svc-a:27017,mongo-replica-svc-b:27017,mongo-replica-svc-c:27017/your_db?replicaSet=my_replica_set' +

MongoClient.connect(connectionString, callback)
```

#### Options for users (TODO):

Users can select the number of replica nodes and determine service/rc name...

# MongoDB sharded cluster

It is similar to build a replica set.

`./run_shards.sh` 
It will deploy 3 config servers in replica set, and a `mongos` instance as controller.

Then you can connect to `mongos` and add mongo instances as shards. e.g., Add replica set as one shard: `sh.addShard("my_replica_set/mongo-replica-svc-a")`
