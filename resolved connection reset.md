On all nodes run:

`sysctl -w net.netfilter.nf_conntrack_tcp_be_liberal=1`

this instructed conntrack to not mark as INVALID the packets that it cannot process; now you will see that everything works smoothly.
