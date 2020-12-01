#!/bin/bash -x

#KUBEVER=1.19.4-00
LBIP=192.168.50.10
LBDNS="k8s.local"
CLUSTERIP="10.32.0.10"

setup_kubectl() {
  mkdir -p $HOME/.kube
  cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  mkdir -p /home/vagrant/.kube
  cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
  chown -R vagrant:vagrant /home/vagrant/.kube
}

apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg-agent net-tools

# Add repo Docker-CE
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

# Install Docker-CE
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
usermod -aG docker vagrant

# Add repo Kubernetes
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

# Install Kubernetes
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
swapoff -a

echo "$LBIP $LBDNS" >> /etc/hosts
IP=$(ifconfig enp0s8 | grep inet | awk '{print $2}' | cut -d':' -f2)
echo "KUBELET_EXTRA_ARGS=\"--node-ip=$IP --cluster-dns=$CLUSTERIP\"" > /etc/default/kubelet
systemctl restart kubelet

# Master Node
echo $HOSTNAME | grep -q 'master'
if [ $? -eq 0 ]; then
  # Init kubeadm
  if [ "$HOSTNAME" == "master-1" ]; then
    kubeadm init --config=/vagrant/conf/weave/kubeadm-config.yaml | tee /vagrant/shared/kubeadm-init.log
    setup_kubectl

    # Apply CNI
    kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

    # Export to shared dir
    rm -rf /vagrant/shared/kubernetes
    cp -R /etc/kubernetes /vagrant/shared
    
  else
    # Import from shared dir
    mkdir -p /etc/kubernetes/pki/etcd
    cp /vagrant/shared/kubernetes/pki/ca.crt /etc/kubernetes/pki/
    cp /vagrant/shared/kubernetes/pki/ca.key /etc/kubernetes/pki/
    cp /vagrant/shared/kubernetes/pki/sa.pub /etc/kubernetes/pki/
    cp /vagrant/shared/kubernetes/pki/sa.key /etc/kubernetes/pki/
    cp /vagrant/shared/kubernetes/pki/front-proxy-ca.crt /etc/kubernetes/pki/
    cp /vagrant/shared/kubernetes/pki/front-proxy-ca.key /etc/kubernetes/pki/
    cp /vagrant/shared/kubernetes/pki/etcd/ca.crt /etc/kubernetes/pki/etcd/
    cp /vagrant/shared/kubernetes/pki/etcd/ca.key /etc/kubernetes/pki/etcd/
    cp /vagrant/shared/kubernetes/admin.conf /etc/kubernetes/

    # Replace api endpoint for init
    cp /vagrant/conf/weave/kubeadm-config.yaml /etc/kubeadm-config.yaml
    sed -i "s/192\.168\.50\.11/$IP/g" /etc/kubeadm-config.yaml

    kubeadm init --config=/etc/kubeadm-config.yaml | tee /vagrant/shared/kubeadm-init.$HOSTNAME.log
    setup_kubectl
    
    # install helm on master node
    curl https://baltocdn.com/helm/signing.asc |  apt-key add -
    apt-get install apt-transport-https --yes
    echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
    apt-get update
    apt-get install helm -y
  fi

# Worker Node
else
  eval $(grep "kubeadm join" /vagrant/shared/kubeadm-init.log)
fi
