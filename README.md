This script creates two docker container(SDN: mininet, SDN controller: faucet) and one docker network(sdn-net).
The start.sh(in the mininet folder) initiate OVS and mininet with two single nodes in SDN, and connect to faucet which is initiated in another docker container.
When connected to the faucet controller, it will start to ping all nodes in SDN to check whether faucet controller can switch traffic within the SDN.
