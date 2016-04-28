# kubernetes-mongodb-cluster
Deploy a mongo cluster on kubernetes. 
Based on [Enabling Microservices: Containers & Orchestration Explained](https://www.mongodb.com/collateral/microservices-containers-and-orchestration-explained)

# To start a MongoDB replica set

When start mongoDB replica set, `rs.initiate()` is executed until all the mongodb nodes are available (see run_replica.sh). 

`./run_replica.sh`

Note: Since Kubernetes v1.2 has a [bug](https://github.com/kubernetes/kubernetes/issues/19930) that a pod cannot connect to itself via its service's cluster IP. I used `headless` services, which means all services do not have cluster IP and can be accessed only inside K8s cluster through service name like `mongo-replica-svc-a`. E.g. `mongodb://service-name:27017/test`

# Availability

If less than half of all the pods are killed, the replica set can still work. If all of them are deleted, to re-initialize them, run `kubectl create -f mongo-replica-starter-rc.yaml`.

# Options for users (TODO):

Users can select the number of replica nodes, whether to use arbiter, service name...