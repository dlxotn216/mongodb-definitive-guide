#init/setup.sh
sleep 15 | echo "Waiting for the servers to start..."
mongosh mongodb://localhost:27017 /usr/src/configs/init/setReplication.js
