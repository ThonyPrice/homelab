#!/usr/bin/env sh


# Name of cluster in Proxmox
CLUSTER_NAME="cluster01"
# Node to execute the create cluster command
INIT_NODE="192.168.1.101"
# List of nodes that should be joined to the cluster
declare -a JOIN_NODES=("192.168.1.102")


function main() {

    echo "Connecting to primary node to create cluster..."
    ssh -t root@$INIT_NODE "pvecm create ${CLUSTER_NAME}"
    echo ""

    for NODE in "${JOIN_NODES[@]}"
    do
        echo "Connecting to node ${NODE} to join in cluster..."
        ssh -t root@$NODE "pvecm add ${INIT_NODE}"
    done
}

main
