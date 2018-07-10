#!/bin/bash

ORG_AMOUNT=5
PEER_PER_ORG=1
PEER_INDEX_MAX=$(( PEER_PER_ORG - 1 ))


# Generate docker-compose-cli.yaml
#
cat docker-compose-cli-basic.yaml > ../docker-compose-cli.yaml

echo -e "#Peer and CA list\n#" >> ../docker-compose-cli.yaml
START_CA_PORT=12000
for ORG_INDEX in $(eval echo "{1..$ORG_AMOUNT}");
do
    # Generate CA configuration
    # Note: comment the following code if ca is not required for cli template
    #
    CA_INDEX=${ORG_INDEX}
    CA_PORT=$(( START_CA_PORT + ( ORG_INDEX - 1 ) ))
    sed -e 's/${ORG_INDEX}/'$ORG_INDEX'/g' -e 's/${CA_INDEX}/'$CA_INDEX'/g' \
        -e 's/${CA_PORT}/'$CA_PORT'/g' \
        docker-compose-e2e-template-ca.yaml >> ../docker-compose-cli.yaml

    # Generate Peer configuration
    #
    for PEER_INDEX in $(eval echo "{0..$PEER_INDEX_MAX}");
    do
        ORG_NAME=org$ORG_INDEX
        PEER_NAME=peer$PEER_INDEX
        sed -e 's/${PEER_NAME}/'$PEER_NAME'/g' -e 's/${ORG_NAME}/'$ORG_NAME'/g' docker-compose-cli-e2e-peer.yaml >> ../docker-compose-cli.yaml
    done
done

# Generate docker-compose-couch.yaml
#
cat docker-compose-couch-basic.yaml > ../docker-compose-couch.yaml

echo -e "#CouchDB and peer list\n#" >> ../docker-compose-couch.yaml
START_COUCHDB_PORT=11000
for ORG_INDEX in $(eval echo "{1..$ORG_AMOUNT}");
do
    for PEER_INDEX in $(eval echo "{0..$PEER_INDEX_MAX}");
    do
        ORG_NAME=org$ORG_INDEX
        PEER_NAME=peer$PEER_INDEX
        COUCHDB_INDEX=${ORG_INDEX}-$PEER_INDEX
        COUCHDB_PORT=$(( START_COUCHDB_PORT + ( ORG_INDEX - 1 ) * PEER_PER_ORG + PEER_INDEX ))
        sed -e 's/${PEER_NAME}/'$PEER_NAME'/g' -e 's/${ORG_NAME}/'$ORG_NAME'/g' \
            -e 's/${COUCHDB_INDEX}/'$COUCHDB_INDEX'/g' -e 's/${COUCHDB_PORT}/'$COUCHDB_PORT'/g' \
            docker-compose-couch-peer.yaml >> ../docker-compose-couch.yaml
    done
done


# Generate docker-compose-e2e-template.yaml
#
cat docker-compose-e2e-template-basic.yaml > ../docker-compose-e2e-template.yaml

echo -e "#Peer and CA list\n#" >> ../docker-compose-e2e-template.yaml
START_CA_PORT=12000
for ORG_INDEX in $(eval echo "{1..$ORG_AMOUNT}");
do
    # Generate CA configuration
    #
    CA_INDEX=${ORG_INDEX}
    CA_PORT=$(( START_CA_PORT + ( ORG_INDEX - 1 ) ))
    sed -e 's/${ORG_INDEX}/'$ORG_INDEX'/g' -e 's/${CA_INDEX}/'$CA_INDEX'/g' \
        -e 's/${CA_PORT}/'$CA_PORT'/g' \
        docker-compose-e2e-template-ca.yaml >> ../docker-compose-e2e-template.yaml

    # Generate Peer configuration
    #
    for PEER_INDEX in $(eval echo "{0..$PEER_INDEX_MAX}");
    do
        ORG_NAME=org$ORG_INDEX
        PEER_NAME=peer$PEER_INDEX
        sed -e 's/${PEER_NAME}/'$PEER_NAME'/g' -e 's/${ORG_NAME}/'$ORG_NAME'/g' docker-compose-cli-e2e-peer.yaml >> ../docker-compose-e2e-template.yaml
    done
done


# Generate base/docker-compose-base.yaml
#
cat base/docker-compose-base-basic.yaml > ../base/docker-compose-base.yaml

echo -e "#Peer list\n#" >> ../base/docker-compose-base.yaml
START_PEER_API_PORT=13000
START_PEER_EVENTHUB_PORT=14000
for ORG_INDEX in $(eval echo "{1..$ORG_AMOUNT}");
do
    for PEER_INDEX in $(eval echo "{0..$PEER_INDEX_MAX}");
    do
        ORG_NAME=org$ORG_INDEX
        PEER_NAME=peer$PEER_INDEX
        ANCHOR_PEER_NAME=peer0
        ORG_MSP_NAME=Org${ORG_INDEX}MSP
        PEER_API_PORT=$(( START_PEER_API_PORT + ( ORG_INDEX - 1 ) * PEER_PER_ORG + PEER_INDEX ))
        PEER_EVENTHUB_PORT=$(( START_PEER_EVENTHUB_PORT + ( ORG_INDEX - 1 ) * PEER_PER_ORG + PEER_INDEX ))
        sed -e 's/${PEER_NAME}/'$PEER_NAME'/g' -e 's/${ANCHOR_PEER_NAME}/'$ANCHOR_PEER_NAME'/g' \
            -e 's/${ORG_NAME}/'$ORG_NAME'/g' -e 's/${ORG_MSP_NAME}/'$ORG_MSP_NAME'/g' \
            -e 's/${PEER_API_PORT}/'$PEER_API_PORT'/g' -e 's/${PEER_EVENTHUB_PORT}/'$PEER_EVENTHUB_PORT'/g' \
            base/docker-compose-base-peer.yaml >> ../base/docker-compose-base.yaml
    done
done

cat base/peer-base.yaml > ../base/peer-base.yaml


# Generate configtx.yaml
#
cat configtx-basic-part3.yaml > ../configtx.yaml
for ORG_INDEX in $(eval echo "{1..$ORG_AMOUNT}");
do
    _ORG_NAME=Org$ORG_INDEX
    ORG_NAME=org$ORG_INDEX
    ORG_MSP_NAME=Org${ORG_INDEX}MSP
    ANCHOR_PEER_NAME=peer0
    sed -e 's/${ANCHOR_PEER_NAME}/'$ANCHOR_PEER_NAME'/g' -e 's/${ORG_NAME}/'$ORG_NAME'/g' \
        -e 's/${_ORG_NAME}/'$_ORG_NAME'/g' -e 's/${ORG_MSP_NAME}/'$ORG_MSP_NAME'/g' \
        configtx-org.yaml >> ../configtx.yaml
done

cat configtx-basic-part1.yaml >> ../configtx.yaml
for ORG_INDEX in $(eval echo "{1..$ORG_AMOUNT}");
do
    echo "                    - *Org$ORG_INDEX" >> ../configtx.yaml
done
cat configtx-basic-part2.yaml >> ../configtx.yaml
for ORG_INDEX in $(eval echo "{1..$ORG_AMOUNT}");
do
    echo "                - *Org$ORG_INDEX" >> ../configtx.yaml
done


# Generate crypto-configtx.yaml
#
cat crypto-config-basic.yaml > ../crypto-config.yaml

for ORG_INDEX in $(eval echo "{1..$ORG_AMOUNT}");
do
    _ORG_NAME=Org$ORG_INDEX
    ORG_NAME=org$ORG_INDEX
    sed -e 's/${PEER_PER_ORG}/'$PEER_PER_ORG'/g' -e 's/${ORG_NAME}/'$ORG_NAME'/g' \
        -e 's/${_ORG_NAME}/'$_ORG_NAME'/g' \
        crypto-config-org.yaml >> ../crypto-config.yaml
done

# Generate generate_artifacts.sh
PEER_INDEX_LIMIT=$(( PEER_PER_ORG - 1 ))
sed -e 's/${ORG_AMOUNT}/'$ORG_AMOUNT'/g' -e 's/${PEER_INDEX_LIMIT}/'$PEER_INDEX_LIMIT'/g' \
    generate_artifacts_template.sh > ../generate_artifacts.sh

# Generate .env file required by docker-compose
echo "COMPOSE_PROJECT_NAME=net" > ../.env
