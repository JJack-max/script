# Rancher Docker Installation Guide

This document provides instructions for installing Rancher and related services using Docker and Helm.

## Rancher Installation

To install Rancher using Docker, run the following command:

```bash
sudo docker run -d --restart=unless-stopped `
  -p 80:80 -p 443:443 `
  -v /opt/rancher:/var/lib/rancher `
  -v /etc/localtime:/etc/localtime:ro `
  -v /etc/timezone:/etc/timezone:ro `
  --privileged `
  --name rancher `
  --add-host rancher-partner.payforex.net:192.168.200.1 `
  rancher/rancher:v2.8.2
```

## Node Preparation

Install NFS common package on each node:

```bash
sudo apt-get install -y nfs-common
```

## NFS Subdirectory External Provisioner

Install the NFS subdirectory external provisioner:

```bash
helm install -n nfs nfs-subdir-external-provisioner `
  nfs-subdir-external-provisioner/nfs-subdir-external-provisioner `
  --set nfs.server=192.168.100.40 `
  --set nfs.path=/export `
  --set-string nfs.mountOptions="" ## Cancel default vers=4.1 as Sakura cloud NFS does not support 4.1
```

## Redis Deployment

Create Redis secret and install using Helm:

```bash
kubectl create namespace redis
```

```bash
kubectl create secret generic redis `
  --from-literal=redis-password='Abc12345' `
  -n redis
```

```bash
helm install redis oci://registry-1.docker.io/bitnamicharts/redis --namespace redis -f 1.helm-redis-values.yaml
```

## MongoDB Deployment

Create MongoDB secret and install using Helm:

```bash
kubectl create namespace mongodb
```

```bash
kubectl create secret generic mongodb `
  --from-literal=mongodb-root-password='R6l24H2YZz' `
  --from-literal=mongodb-password='Abc12345' `
  -n mongodb
```

```bash
helm repo update
```

```bash
helm install --version 12.1.16 mongodb bitnami/mongodb --namespace mongodb -f 2.helm-mongodb-values.yaml
```

## ActiveMQ Deployment

Create ActiveMQ secret and apply configuration:

```bash
kubectl create namespace activemq
```

```bash
kubectl create secret generic activemq `
  --from-literal=activemq-admin-password="JpjfmcKW3QbJauYd" `
  --from-literal=activemq-password="Qbc12345" `
  -n activemq
```

```bash
kubectl apply -f 4.kubectl-activemq.yaml
```

## Elasticsearch Deployment

Install Elasticsearch using Helm:

```bash
kubectl create namespace elasticsearch
```

```bash
helm install elasticsearch elastic/elasticsearch --namespace elasticsearch -f 5.helm-elasticsearch-values.yaml
```

## sakura cloud docker hub
```bash
kubectl create secret docker-registry nexus `
  --docker-server=sakura-test-partner-reg-01.sakuracr.jp `
  --docker-username=qbc-release `
  --docker-password=m6dx7zqNyMG5GMJ6qg7U `
  -n commons-aml
```