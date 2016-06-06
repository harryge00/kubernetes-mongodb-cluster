mongod --replSet $SET_NAME &
until nc -z localhost 27017
do
    echo "waiting"
    sleep 1
done
echo "done"
mongo < /build_replica.js

