Kubernetes on Vagrant


Use Kubeadm on Vagrant to create a multi-master environment for Kubernetes cluster.


I use 2 master node and 3 worker node. one load balancer node is in front of 2 master node as follow: 

		--------------------------------Worker1
 		-                                    -                  
		----------------Master1---------------- 
 		-                                    -
		LB-----=====>-------------------Worker2
		-                                     -
		----------------Master2---------------- 
		-                                     -
		--------------------------------Worker3


But in Best practice, almost use odd number of master node or worker node. for example 1,3,5,... master or worker node.


Required spec to run this code:
 - Hosted Server memory 12G+
 - Vagrant >= 2.3
 - VirtualBox >= 6.0

Usage

run this command to setup and config multi master cluster:
vagrant up

After multi master cluster up nad ready to use, for deploy helm chart in cluster, ssh to master-1 node:

  vagrant ssh master-1

Then run this command:
  helm install api helm-chart



* For zero-downtime deployment or upgrade application in Kubernetes, we can use rolling update deployment strategy.


