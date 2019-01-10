/root/bylee/stolon/bin/stolonctl --cluster-name=kube-stolon --store-backend=kubernetes --kube-resource-kind=configmap init
kubectl create -f role.yaml
kubectl create -f role-binding.yaml
kubectl create -f 00-default-admin-access.yaml
kubectl create -f secret.yaml
kubectl create -f ag_local-01.yaml
kubectl create -f ag_local-02.yaml
kubectl create -f stolon-sentinel.yaml
