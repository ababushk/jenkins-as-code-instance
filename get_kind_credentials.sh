#!/bin/sh

# Credit to https://illya-chekrygin.com/2017/08/26/configuring-certificates-for-jenkins-kubernetes-plugin-0-12/
# curl -L https://github.com/kubernetes-sigs/kind/releases/download/v0.9.0/kind-linux-amd64 -o kind
# ./kind create-cluster

cat $HOME/.kube/config | grep certificate-authority-data | cut -f2 -d':' | tr -d ' ' | base64 -d > ca.crt
echo Certificate authority
cat ca.crt

cat $HOME/.kube/config | grep client-certificate-data | cut -f2 -d':' | tr -d ' ' | base64 -d > client.crt
echo Client certificate
cat client.crt

cat $HOME/.kube/config | grep client-key-data | cut -f2 -d':' | tr -d ' ' | base64 -d > client.key
echo Client key
cat client.key

openssl pkcs12 -export -passout pass:verysecure -out cert.pfx -inkey client.key -in client.crt -certfile ca.crt

cat cert.pfx | base64 > kind_cert.p12
# cat cert.pfx | base64 | docker secret create jenkins_access_to_kind_cert -
