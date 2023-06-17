#!/bin/sh
USER=root
PASS=root
DB=admin
RS_OK=$(mongosh --quiet -u $USER -p $PASS $DB --eval "rs.isMaster().ismaster" || echo -n 'FAIL')

if [ "$RS_OK" = "FAIL" ]; then
    echo -n "initialising replica set..."
    mongosh -u $USER -p $PASS $DB --eval "rs.initiate({_id: 'rs0', members: [ { _id: 0, host: 'localhost:27017'} ] });" || exit 1
    echo -n "Replica set initialized..."
    exit 1
fi

if [ "$RS_OK" = "true" ]; then
    echo -n "Replica set is OK"
    exit 0
fi

echo -n "Replica set not yet ready: $RS_OK"
exit 1




