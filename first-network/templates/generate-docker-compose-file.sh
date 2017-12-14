#!/bin/bash

ORG_AMOUNT=5
PEER_PER_ORG=2

# Generate docker-compose-cli.yaml
#
cat docker-compose-cli-basic.yaml > docker-compose-cli.yaml

echo -e "#Peer list\n#" >> docker-compose-cli.yaml
for ORG_INDEX in {1..5};
do
    for PEER_INDEX in {0..1};
    do
        ORG_NAME=org$ORG_INDEX
        PEER_NAME=peer$PEER_INDEX
        sed -e 's/${PEER_NAME}/'$PEER_NAME'/g' -e 's/${ORG_NAME}/'$ORG_NAME'/g' docker-compose-cli-peer.yaml >> docker-compose-cli.yaml
    done
done

# Generate docker-compose-couch.yaml
#
cat docker-compose-couch-basic.yaml > docker-compose-couch.yaml

echo -e "#CouchDB and peer list\n#" >> docker-compose-couch.yaml
for ORG_INDEX in {1..5};
do
    for PEER_INDEX in {0..1};
    do
        ORG_NAME=org$ORG_INDEX
        PEER_NAME=peer$PEER_INDEX
        COUCHDB_INDEX=${ORG_INDEX}-$PEER_INDEX
        COUCHDB_PORT=$(( 11000 + ORG_INDEX * PEER_INDEX ))
        sed -e 's/${PEER_NAME}/'$PEER_NAME'/g' -e 's/${ORG_NAME}/'$ORG_NAME'/g' \
            -e 's/${COUCHDB_INDEX}/'$COUCHDB_INDEX'/g' -e 's/${COUCHDB_PORT}/'$COUCHDB_PORT'/g' \
            docker-compose-couch-peer.yaml >> docker-compose-couch.yaml
    done
done

