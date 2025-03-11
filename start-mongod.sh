#!/bin/sh
# Create directory for MongoDB logs if it doesn't exist
mkdir -p /var/log/mongodb
touch /var/log/mongodb/mongod.log
chown -R mongodb:mongodb /var/log/mongodb

# Start MongoDB in the background
/usr/local/bin/docker-entrypoint.sh --replSet rs0 --bind_ip_all --keyFile /data/mongo-keyfile --quiet --logpath /var/log/mongodb/mongod.log &

# Store the process ID to be able to wait for it
MONGO_PID=$!

# Wait for MongoDB to start accepting connections
echo "Waiting for MongoDB to start..."
sleep 10

# Set default values for credentials and host
MONGO_USERNAME=${MONGO_INITDB_ROOT_USERNAME:-root}
MONGO_PASSWORD=${MONGO_INITDB_ROOT_PASSWORD:-root}
MONGO_HOST=${MONGO_HOST:-host.docker.internal}

echo "Using MongoDB host: $MONGO_HOST"

# Try operations without authentication first (for first run)
echo "Checking MongoDB status..."
mongosh --host localhost --eval "db.adminCommand('ping')" --quiet &>/dev/null
NO_AUTH_RESULT=$?

if [ $NO_AUTH_RESULT -eq 0 ]; then
    echo "First-time setup required..."

    # Initialize replica set using the configured host
    echo "Initializing replica set with $MONGO_HOST..."
    mongosh --host localhost --eval "rs.initiate({
	_id: 'rs0',
	members: [
	    {_id: 0, host: '$MONGO_HOST:27017'}
	]
    })"

    # Wait for the replica set to initialize
    echo "Waiting for replica set initialization..."
    sleep 10

    # Create admin user
    echo "Creating admin user: $MONGO_USERNAME"
    mongosh --host localhost --eval "db = db.getSiblingDB('admin'); db.createUser({user: '$MONGO_USERNAME', pwd: '$MONGO_PASSWORD', roles: ['root']})"
else
    # Try with authentication
    echo "Trying with authentication..."
    mongosh --host localhost --username "$MONGO_USERNAME" --password "$MONGO_PASSWORD" --authenticationDatabase admin --eval "db.adminCommand('ping')" &>/dev/null
    AUTH_RESULT=$?

    if [ $AUTH_RESULT -eq 0 ]; then
	echo "Authentication successful, MongoDB already configured."

	# Check and update replica set configuration if needed
	echo "Checking replica set configuration..."
	RS_CONFIG=$(mongosh --host localhost --username "$MONGO_USERNAME" --password "$MONGO_PASSWORD" --authenticationDatabase admin --eval "rs.conf()" --quiet)

	# Check if the configured host is in the config and update if needed
	if ! echo "$RS_CONFIG" | grep -q "$MONGO_HOST:27017"; then
	    echo "Updating replica set configuration to use $MONGO_HOST..."
	    mongosh --host localhost --username "$MONGO_USERNAME" --password "$MONGO_PASSWORD" --authenticationDatabase admin --eval "
		var config = rs.conf();
		config.members[0].host = '$MONGO_HOST:27017';
		rs.reconfig(config, {force: true});
	    "
	    echo "Replica set configuration updated."
	else
	    echo "Replica set is already configured correctly."
	fi
    else
	echo "Cannot connect to MongoDB. Make sure MongoDB is running properly."
	exit 1
    fi
fi

echo "MongoDB setup complete, and is now running ready for connections."
echo "Connect using any of these options:"
echo "- From containers: mongodb://$MONGO_USERNAME:$MONGO_PASSWORD@$MONGO_HOST:27017/?authSource=admin&replicaSet=rs0"
echo "- From host machine: mongodb://$MONGO_USERNAME:$MONGO_PASSWORD@localhost:27017/?authSource=admin&replicaSet=rs0&directConnection=true"

# Wait for the MongoDB process
wait $MONGO_PID