echo "building mongodb nodes"
kubectl create -f mongo-replica-rs.yaml
#wait until the mongodb finish initiation
sleep 15;
echo "initializing mongodb replica set"
kubectl create -f mongo-replica-starter-rc.yaml
echo "delete replica set starter"
kubectl delete rc mongo-replica-starter