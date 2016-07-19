# kubernetes-mongodb-cluster
Deploy a mongo cluster on kubernetes. 
Based on [Enabling Microservices: Containers & Orchestration Explained](https://www.mongodb.com/collateral/microservices-containers-and-orchestration-explained)

# MongoDB replica set

`replica/mongo-replica-rs.yaml` creates 3 mongodb replication controllers and their corresponding services. The 3 mongodb instances can consist a replica set named as "my_replica_set". 

One of mongodb replication controller's yaml:
```
apiVersion: v1
kind: ReplicationController
metadata:
  name: mongo-replica-rc0
  labels:
    name: mongo-replica-rc
spec:
  replicas: 1
  selector:
    name: mongo-replica-node0
  template:
    metadata:
      labels:
        name: mongo-replica-node0
    spec:
      containers:
      - name: mongo-replica-node0
        image: hyge/mongo-cluster
        env:
          - name: mongo_node_name
            value: mongo-replica-node
          - name: mongo_nodes_number
            value: "3"
          - name: mongo_replica_set_name
            value: my_replica_set
        ports:
        - containerPort: 27017
        volumeMounts:
        - name: mongo-replica-storage0
          mountPath: /data/db
      volumes:
      - name: mongo-replica-storage0
        emptyDir: {}
```
* To scale nodes of the mongo replica, promote the environmental variable "mongo_nodes_number". 
* Environmental variable "mongo_replica_set_name" is the name of replica set.
* Environmental variable "mongo_node_name" is the name prefix for each node. The suffix of the name will be "Nth" number. It must match k8s svc's name.
* See `replica/start_replica.sh` and `replica/Dockerfile` for more details.

One mongo service yaml:
```
apiVersion: v1
kind: Service
metadata:
  name: mongo-replica-node-0
  labels:
    name: mongo-svc
spec:
  clusterIP: None
  ports:
  - port: 27017
    targetPort: 27017
    protocol: TCP
    name: mongo-svc-port
  selector:
    name: mongo-replica-node0
```

## How to deploy a replica set

To start a 3 node mongo rs, run 
`kubectl create -f ./replica/mongo-replica-rs.yaml`

#### Use driver to connect to mongo cluster

For example: node.js
```
var connectionString = 'mongodb://mongo-replica-svc-a:27017,mongo-replica-svc-b:27017,mongo-replica-svc-c:27017/your_db?replicaSet=my_replica_set' +

MongoClient.connect(connectionString, callback)
```

### Issue

Update: The bug has been fixed since k8s v1.2.4.
Note: Before Kubernetes v1.2.4 has a [bug](https://github.com/kubernetes/kubernetes/issues/19930) that a pod cannot connect to itself via its service's cluster IP. I used `headless` services, which means all services do not have cluster IP and can be accessed only inside K8s cluster through service name like `mongo-replica-svc-a`. E.g. `mongodb://service-name:27017/test`
* If the number of replica set members are even, you may add a mongodb arbiter to create an "imbalance" (optional).

# MongoDB sharded cluster

It is similar to build a replica set.

`./run_shards.sh` 
It will deploy 3 config servers in replica set, and a `mongos` instance as controller.

Then you can connect to `mongos` and add mongo instances as shards. e.g., Add replica set as one shard: `sh.addShard("my_replica_set/mongo-replica-svc-a")`
