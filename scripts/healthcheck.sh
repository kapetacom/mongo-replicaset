#!/bin/sh
if [ -z "$MONGO_INITDB_ROOT_USERNAME" ]; then
    MONGO_INITDB_ROOT_USERNAME=root
fi
if [ -z "$MONGO_INITDB_ROOT_PASSWORD" ]; then
    MONGO_INITDB_ROOT_PASSWORD=root
fi
DB=admin
RS_OK=$(mongosh --quiet -u $MONGO_INITDB_ROOT_USERNAME -p $MONGO_INITDB_ROOT_PASSWORD $DB --eval "rs.status().ok" || echo -n 'FAIL')
if [ "$RS_OK" = "FAIL" ]; then
    echo -n "initialising replica set..."
    mongosh -u $MONGO_INITDB_ROOT_USERNAME -p $MONGO_INITDB_ROOT_PASSWORD $DB --eval "rs.initiate({_id: 'rs0', members: [ { _id: 0, host: 'localhost:27017'} ] });" || exit 1
    echo -n "Replica set initialized..."
    exit 1
fi

MASTER_OK=$(mongosh --quiet -u $MONGO_INITDB_ROOT_USERNAME -p $MONGO_INITDB_ROOT_PASSWORD $DB --eval "rs.isMaster().ismaster" || echo -n 'FAIL')
if [ "$MASTER_OK" = "true" ]; then
    echo -n "Replica set is OK"
    exit 0
fi

echo -n "Replica set not yet ready: $RS_OK"
exit 1
