echo "building 3 mongodb config servers"
kubectl create -f mongo-shards-configsvr-rs.yaml
#wait until the mongodb finish initiation
sleep 15;
echo "initializing mongodb shards"
kubectl create -f mongo-shards-starter-rc.yaml
kubectl create -f mongo-shards-controller-rs.yaml
echo "delete shards starter"
kubectl delete rc mongo-shards-starter