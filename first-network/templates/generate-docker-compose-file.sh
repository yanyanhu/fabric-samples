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
        sed -e 's/${PEER_NAME}/'$PEER_NAME'/g' -e 's/${ORG_NAME}/'$ORG_NAME'/g' docker-compose-cli-e2e-peer.yaml >> docker-compose-cli.yaml
    done
done

# Generate docker-compose-couch.yaml
#
cat docker-compose-couch-basic.yaml > docker-compose-couch.yaml

echo -e "#CouchDB and peer list\n#" >> docker-compose-couch.yaml
START_COUCHDB_PORT=11000
for ORG_INDEX in {1..5};
do
    for PEER_INDEX in {0..1};
    do
        ORG_NAME=org$ORG_INDEX
        PEER_NAME=peer$PEER_INDEX
        COUCHDB_INDEX=${ORG_INDEX}-$PEER_INDEX
        COUCHDB_PORT=$(( START_COUCHDB_PORT + ( ORG_INDEX - 1 ) * PEER_PER_ORG + PEER_INDEX ))
        sed -e 's/${PEER_NAME}/'$PEER_NAME'/g' -e 's/${ORG_NAME}/'$ORG_NAME'/g' \
            -e 's/${COUCHDB_INDEX}/'$COUCHDB_INDEX'/g' -e 's/${COUCHDB_PORT}/'$COUCHDB_PORT'/g' \
            docker-compose-couch-peer.yaml >> docker-compose-couch.yaml
    done
done


# Generate docker-compose-e2e-template.yaml
#
cat docker-compose-e2e-template-basic.yaml > docker-compose-e2e-template.yaml

echo -e "#Peer and CA list\n#" >> docker-compose-e2e-template.yaml
START_CA_PORT=12000
for ORG_INDEX in {1..5};
do
    # Generate CA configuration
    #
    CA_INDEX=${ORG_INDEX}
    CA_PORT=$(( START_CA_PORT + ( ORG_INDEX - 1 ) ))
    sed -e 's/${ORG_INDEX}/'$ORG_INDEX'/g' -e 's/${CA_INDEX}/'$CA_INDEX'/g' \
        -e 's/${CA_PORT}/'$CA_PORT'/g' \
        docker-compose-e2e-template-ca.yaml >> docker-compose-e2e-template.yaml

    # Generate Peer configuration
    #
    for PEER_INDEX in {0..1};
    do
        ORG_NAME=org$ORG_INDEX
        PEER_NAME=peer$PEER_INDEX
        sed -e 's/${PEER_NAME}/'$PEER_NAME'/g' -e 's/${ORG_NAME}/'$ORG_NAME'/g' docker-compose-cli-e2e-peer.yaml >> docker-compose-e2e-template.yaml
    done
done


# Generate base/docker-compose-base.yaml
#
cat base/docker-compose-base-basic.yaml > base/docker-compose-base.yaml

echo -e "#Peer list\n#" >> base/docker-compose-base.yaml
START_PEER_API_PORT=13000
START_PEER_EVENTHUB_PORT=14000
for ORG_INDEX in {1..5};
do
    for PEER_INDEX in {0..1};
    do
        ORG_NAME=org$ORG_INDEX
        PEER_NAME=peer$PEER_INDEX
        ORG_MSP_NAME=Org${ORG_INDEX}MSP
        PEER_API_PORT=$(( START_PEER_API_PORT + ( ORG_INDEX - 1 ) * PEER_PER_ORG + PEER_INDEX ))
        PEER_EVENTHUB_PORT=$(( START_PEER_EVENTHUB_PORT + ( ORG_INDEX - 1 ) * PEER_PER_ORG + PEER_INDEX ))
        sed -e 's/${PEER_NAME}/'$PEER_NAME'/g' -e 's/${ORG_NAME}/'$ORG_NAME'/g' \
            -e 's/${ORG_MSP_NAME}/'$ORG_MSP_NAME'/g' -e 's/${PEER_API_PORT}/'$PEER_API_PORT'/g' \
            -e 's/${PEER_EVENTHUB_PORT}/'$PEER_EVENTHUB_PORT'/g' \
            base/docker-compose-base-peer.yaml >> base/docker-compose-base.yaml
    done
done

