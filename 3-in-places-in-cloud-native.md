"3 in-place" is a basic cloud native function, which is not difficult to implement. 

The biggest advantage of in-place is that the pod will not be recreated, thus avoiding a series of problems such as resource release and recycling, route allocation, and network fluctuation, and reducing maintenance costs. Thus, the cloud platform can show a static and orderly beauty. 

Let's talk about the three in place respectively. 

First of all, in-place updates the POD image, which is actually the basic function of kubelet. Openkurise does something superfluous. 

The second is in-place vertical resource expansion. In essence, it is the resource management of cgroup. However, it requires some effort to maintain the consistency of settings, operations, and views. Therefore, in K8S 1.25, it is still aIpha. If you just want a program that requires 8g of memory, it is not very difficult to run in an environment with only 3g limit; 

The last is in-place dynamic mount. You can mount any directory you want and any time you want. It's not difficult to do this, just use nscenter and some device volumes. 

If you want to know the details, you can go to my Github and Medium.
