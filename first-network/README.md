## Build Your First Network (BYFN)

The directions for using this are documented in the Hyperledger Fabric
["Build Your First Network"](http://hyperledger-fabric.readthedocs.io/en/latest/build_network.html) tutorial.

### 1. Generate configuration
$cd templates
$./generate_configuration.sh

### 2. Clean up existing network & artifacts if any
$./fabric -m cleanup

### 3. Generate artifacts
$./fabric -m generate

### 4. Bootstrap network
$./fabric -m up -s couchdb
