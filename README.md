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
        image: hyge/mongo-cluster
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

After the 3 mongo replication controllers have been created and finished initialzation, run `kubectl get pods` first to get the pod name.
If the pod name is `mongo-replica-rc1-dsw20`:
```
kubectl exec -ti mongo-replica-rc1-dsw20 mongo
> rs.initiate({_id:"my_replica_set", members:
  [{ _id:0, host:"mongo-replica-svc-a" },
  { _id:1, host:"mongo-replica-svc-b" },
  { _id:2, host:"mongo-replica-svc-c" }
]});
```
If mongo shell returns `{ "ok" : 1 }`, congratulations, a mongo replica set has been built!
Run `rs.status()` to check the status of replica set.

### Automatical initialization of the replica set

`kubectl exec -ti mongo-replica-rcX-ABC123 mongo < replica/build_replica.js`

build_replica.js does the same as the previous mongo shell:

```
rs.initiate({_id:"my_replica_set", members:
  [{ _id:0, host:"mongo-replica-svc-a" },
  { _id:1, host:"mongo-replica-svc-b" },
  { _id:2, host:"mongo-replica-svc-c" }
]})
```
In general, the member who runs `rs.initiate()` will become the primary one.

### Use mongo

Use `kubectl exec -ti mongo-replica-rcX-ABC123 mongo` to enter the Xth member of replica set.

#### Use driver to connect to mongo cluster
For example: node.js
```
var connectionString = 'mongodb://mongo-replica-svc-a:27017,mongo-replica-svc-b:27017,mongo-replica-svc-c:27017/your_db?replicaSet=my_replica_set' +

MongoClient.connect(connectionString, callback)
```

### Issue
Note: Since Kubernetes v1.2 has a [bug](https://github.com/kubernetes/kubernetes/issues/19930) that a pod cannot connect to itself via its service's cluster IP. I used `headless` services, which means all services do not have cluster IP and can be accessed only inside K8s cluster through service name like `mongo-replica-svc-a`. E.g. `mongodb://service-name:27017/test`
* If the number of replica set members are even, you may add a mongodb arbiter to create an "imbalance" (optional).

### TODO:

Currently the name of RC and services are hard coded in yaml. Later, users can choose the number of replica nodes and determine service/rc name...

# MongoDB sharded cluster

It is similar to build a replica set.

`./run_shards.sh` 
It will deploy 3 config servers in replica set, and a `mongos` instance as controller.

Then you can connect to `mongos` and add mongo instances as shards. e.g., Add replica set as one shard: `sh.addShard("my_replica_set/mongo-replica-svc-a")`
