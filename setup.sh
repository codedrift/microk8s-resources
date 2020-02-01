#!/bin/bash

sudo snap install microk8s --classic --channel=1.17/stable
sudo usermod -a -G microk8s $USER
su - $USER

microk8s.status --wait-ready


microk8s.enable dashboard

# ensure root user is in sudoers before executing this
microk8s.enable rbac

# microk8s.kubectl get nodes

echo "alias kubectl='microk8s.kubectl'" >> .bash_aliases

microk8s.kubectl apply -f service-user.yml
microk8s.kubectl apply -f admin-role-binding.yml

# get token for default namespace
microks.kubectl -n default describe secret $(kubectl -n default get secret | grep admin-user | awk '{print $1}')



# this is used to tunnel https to the dashboard (not recommended to keep it permanent)

# create tls for dashboard ingress
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /tmp/tls.key -out /tmp/tls.crt -subj "/CN=dashboard.microk8s.codedrift.net"

# add tls to secrets
kubectl create secret tls tls-secret --key /tmp/tls.key --cert /tmp/tls.crt -n kube-system
# get token
kubectl -n default  describe secret $(kubectl -n default get secret | grep admin-user | awk '{print $1}')

# cert manager tutorial
# https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nginx-ingress-with-cert-manager-on-digitalocean-kubernetes