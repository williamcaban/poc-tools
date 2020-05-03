# Netflow or sFlow on OpenShift 4 w/OVN Kubernetes


- Identify the `ovs-node` of the Node hosting the Pods to monitor 

    ```
    # oc get pods --selector="app=ovs-node" -o wide
    NAME             READY   STATUS    RESTARTS   AGE   IP              NODE       NOMINATED NODE   READINESS GATES
    ovs-node-4hldj   1/1     Running   0          47h   198.18.100.16   worker-1   <none>           <none>
    ovs-node-bd9ln   1/1     Running   0          47h   198.18.100.12   master-1   <none>           <none>
    ovs-node-csz9q   1/1     Running   0          47h   198.18.100.13   master-2   <none>           <none>
    ovs-node-qh4nv   1/1     Running   0          47h   198.18.100.15   worker-0   <none>           <none>
    ovs-node-rsfk4   1/1     Running   0          47h   198.18.100.17   worker-2   <none>           <none>
    ovs-node-zndhs   1/1     Running   0          47h   198.18.100.11   master-0   <none>           <none>
    ```

- Determine the information for the NetFlow/SFlow target to be used

    - Our example will use the following information:
    ```
    COLLECTOR_IP=198.18.101.101 # SFlow collector
    COLLECTOR_PORT=5555         # SFlow collector port
    AGENT_IP=ovn-k8s-mp0        # Node source (in this case ovn-k8s-mp0 is the management interface of OVN K8s in the Node)
    HEADER_BYTES=128
    SAMPLING_N=64
    POLLING_SECS=10
    OVS_BRIDGE=br-int              # OVN Kubernetes has multiple bridges based on features enabled. br-int is where all the Pods connects
    ```

- The NetFlow exports command will be
    ```
    ovs-vsctl -- --id=@netflow create netflow \
    target="\"${COLLECTOR_IP}:${COLLECTOR_PORT}\"" \
    -- set bridge ${OVS_BRIDGE} netflow=@netflow
    ```
    - To validate NetFlow session
    ```
    ovs-vsctl list netflow
    ```
    - To remove the NetFlow sessioin
    ```
    ovs-vsctl remove bridge ${OVS_BRIDGE} sflow <sFlow UUID>
    ```

- The SFlow exported command will be
    ```
    ovs-vsctl -- --id=@sflow create sflow agent=${AGENT_IP} \
        target="\"${COLLECTOR_IP}:${COLLECTOR_PORT}\"" header=${HEADER_BYTES} \
        sampling=${SAMPLING_N} polling=${POLLING_SECS} \
        -- set bridge ${OVS_BRIDGE} sflow=@sflow
    ```
    - To validate the SFlow session
    ```
    ovs-vsctl list sflow
    ```
    - To remove the SFlow sessioin
    ```
    ovs-vsctl remove bridge ${OVS_BRIDGE} sflow <sFlow UUID>
    ```

## Example with Netflow 

Login to the `ovs-node` of the corresponding Node 

```
# Enable NetFlow session
[root@bastion]# oc exec -ti ovs-node-rsfk4 /bin/bash
[root@worker-2 ~]# export COLLECTOR_IP=198.18.101.101
[root@worker-2 ~]# export COLLECTOR_PORT=5555
[root@worker-2 ~]# export OVS_BRIDGE=br-int
[root@worker-2 ~]# ovs-vsctl -- --id=@netflow create netflow \
> target="\"${COLLECTOR_IP}:${COLLECTOR_PORT}\"" \
> -- set bridge ${OVS_BRIDGE} netflow=@netflow
c77a2d56-abe0-47ca-8bc9-42ef56a892f4

# Valdidate the session is configured
[root@worker-2 ~]# ovs-vsctl list netflow
_uuid               : c77a2d56-abe0-47ca-8bc9-42ef56a892f4
active_timeout      : 0
add_id_to_interface : false
engine_id           : []
engine_type         : []
external_ids        : {}
targets             : ["198.18.101.101:5555"]

# Stop the NetFlow sessioin
[root@worker-2 ~]# ovs-vsctl remove bridge ${OVS_BRIDGE} netflow c77a2d56-abe0-47ca-8bc9-42ef56a892f4


```

## Example with SFlow

Login to the `ovs-node` of the corresponding Node 

```
# Enable the SFlow session 
[root@bastion]# oc exec -ti ovs-node-rsfk4 /bin/bash
[root@worker-2 ~]# export COLLECTOR_IP=198.18.101.101
[root@worker-2 ~]# export COLLECTOR_PORT=5555
[root@worker-2 ~]# export AGENT_IP=ovn-k8s-mp0
[root@worker-2 ~]# export HEADER_BYTES=128
[root@worker-2 ~]# export SAMPLING_N=64
[root@worker-2 ~]# export POLLING_SECS=10
[root@worker-2 ~]# export OVS_BRIDGE=br-int
[root@worker-2 ~]# ovs-vsctl -- --id=@sflow create sflow agent=${AGENT_IP} \
>     target="\"${COLLECTOR_IP}:${COLLECTOR_PORT}\"" header=${HEADER_BYTES} \
>     sampling=${SAMPLING_N} polling=${POLLING_SECS} \
>     -- set bridge ${OVS_BRIDGE} sflow=@sflow
0b8f138f-5d06-478c-8de6-47db58eb41d6

# Validate the session is configured
[root@worker-2 ~]# ovs-vsctl list sflow
_uuid               : 0b8f138f-5d06-478c-8de6-47db58eb41d6
agent               : ovn-k8s-mp0
external_ids        : {}
header              : 128
polling             : 10
sampling            : 64
targets             : ["198.18.101.101:5555"]

# Stop the SFlow session
[root@worker-2 ~]# ovs-vsctl remove bridge ${OVS_BRIDGE} sflow 0b8f138f-5d06-478c-8de6-47db58eb41d6
```

## Validating target collector is receiving the flows

Using `tcpdump`

```
[root@net1]# tcpdump -nni eth0 udp port 5555
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
15:04:09.995518 IP 198.18.101.55.41003 > 198.18.101.101.5555: UDP, length 652
15:04:11.995581 IP 198.18.101.55.41003 > 198.18.101.101.5555: UDP, length 408
15:04:13.996142 IP 198.18.101.55.41003 > 198.18.101.101.5555: UDP, length 404
15:04:16.996296 IP 198.18.101.55.41003 > 198.18.101.101.5555: UDP, length 792
15:04:18.996389 IP 198.18.101.55.41003 > 198.18.101.101.5555: UDP, length 252
15:04:20.995579 IP 198.18.101.55.41003 > 198.18.101.101.5555: UDP, length 636
^C
6 packets captured
6 packets received by filter
0 packets dropped by kernel
```