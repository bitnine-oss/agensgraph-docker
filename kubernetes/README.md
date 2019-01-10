# preparations

- master, work01, work02 node
- Location of docker image to be used in kubernetes

  https://hub.docker.com/r/bitnine/stolon
  tag : master-ag1.3.1, latest

## docker installation (for centos7.x)
```{}
# work on master, work01, work02 node
$ yum install-y yum-utils device-mapper-persistent-data lvm2
$ yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
$ yum install-y docker-ce
$ systemctl enabledocker && systemctl start docker
```

## kubernetes installation
```{}
# work on master, work01, work02 node
$ cat<<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
$ setenforce 0
$ yum install-y kubelet kubeadm kubectl
$ systemctl enablekubelet && systemctl start kubelet

$ cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

-- modified docker driver
$ docker info | grep -i cgroup
$ cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
$ sed -i "s/cgroup-driver=systemd/cgroup-driver=cgroupfs/g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
$ systemctl daemon-reload && systemctl restart kubelet
```
## Preparing stolon related files
```{}
# work on master node 
git clone https://github.com/bitnineQA/agensgraph-docker.git
-> $PATH/agensgraph-docker/kubernetes/bin , $PATH/agensgraph-docker/kubernetes/stolon 
```

# kubernetes setup

```{}
# master node 
$ swapoff -a
$ kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=<server ip>
... skip ...
-> The following token result is used on work node
kubeadm join <server ip>:6443 --token zmqf4v.9pa4vi8ph6j9umc8 --discovery-token-ca-cert-hash sha256:29e42e37e0456059ada08b60bb4694b7bd6bdec36fa9f4aa235c963414cc91d4


# Installing the Network Plug-in
$ kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```
```{}
# work on work01, work02 node
$ swapoff -a
$ kubeadm join <server ip>:6443 --token zmqf4v.9pa4vi8ph6j9umc8 --discovery-token-ca-cert-hash sha256:29e42e37e0456059ada08b60bb4694b7bd6bdec36fa9f4aa235c963414cc91d4
```
```{}
# work on master node 
$ export KUBECONFIG=/etc/kubernetes/admin.conf
-- example
$ kubectl get pods --all-namespaces -o wide
$ kubectl get nodes -o wide
```
```{}
# work on work node 
$ scp root@<server ip>:/etc/kubernetes/admin.conf .
-- example
$ kubectl --kubeconfig ./admin.conf get pods --all-namespaces -o wide
$ kubectl --kubeconfig ./admin.conf get nodes -o wide
```

# stolon setup

```{}
$ cd $PATH/agensgraph-docker/kubernetes/stolon

-- Initializing cluster
$ PATH/bin/stolonctl --cluster-name=kube-stolon --store-backend=kubernetes --kube-resource-kind=configmap init
$ kubectl get pods --all-namespaces -o wide (check status)

-- setup k8s RBAC 
$ kubectl create -f role.yaml
$ kubectl create -f role-binding.yaml
$ kubectl create -f 00-default-admin-access.yaml
$ kubectl get pods --all-namespaces -o wide (Check Status)

-- create secret
$ kubectl create -f secret.yaml
$ kubectl get pods --all-namespaces -o wide (Check Status)

-- setup volume
$ kubectl create -f ag_local-01.yaml
$ kubectl create -f ag_local-02.yaml
$ kubectl get pods --all-namespaces -o wide (Check Status)

-- create sentinel (Check docker image path)
$ kubectl create -f stolon-sentinel.yaml
$ kubectl get pods --all-namespaces -o wide (Check Status)

-- create keeper (Check docker image path)
$ kubectl create -f stolon-keeper.yaml
$ kubectl get pods --all-namespaces -o wide (Check Status)

-- create porxy (Check docker image path)
$ kubectl create -f stolon-proxy.yaml
$ kubectl get pods --all-namespaces -o wide (Check Status)

-- create proxy-service (Check docker image path)
$ kubectl create -f stolon-proxy-service.yaml
$ kubectl get pods --all-namespaces -o wide (Check Status)
```

```{}
$PATH/bin/stolonctl  --cluster-name=kube-stolon --store-backend=kubernetes --kube-resource-kind=configmap status
```
```{}
--connetion
# kubectl get svc
NAME                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
kubernetes             ClusterIP   10.96.0.1      <none>        443/TCP    22m
stolon-proxy-service   ClusterIP   10.107.37.68   <none>        5432/TCP   27s
 

# $PATH/agensgraph/bin/agens --host 10.107.37.68  --port 5432 postgres -U stolon -W
Password for user stolon: password1
agens (10.3, server 9.6.2)
Type "help" for help.
 
postgres=# create graph p;
CREATE GRAPH
postgres=# create (p:person {name: 'test'});
```

# fail-over test

```{}
-- kill master
$ kubectl delete statefulset stolon-keeper --cascade=false
$ kubectl delete pod stolon-keeper-1
 
-- check master node selection in sentinel log
$ kubectl logs -f stolon-sentinel-7955cd85f5-fhtk4
no keeper info available db=cb96f42d keeper=keeper1
no keeper info available db=cb96f42d keeper=keeper1
master db is failed db=cb96f42d keeper=keeper1
trying to find a standby to replace failed master
electing db as the new master db=087ce88a keeper=keeper0
 
-- check result
$ agens --host 10.107.37.68  --port 5432 postgres -U stolon -W
Password for user stolon: password1
agens (10.3, server 9.6.2)
Type "help" for help.
 
postgres=# match (p) return p;
              p               
------------------------------
 person[3.1]{"name": "test"}
(1 row)
```
