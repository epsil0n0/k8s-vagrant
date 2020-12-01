#!/bin/bash -xe

apt-get update
apt-get install -y haproxy

rm -rf /etc/haproxy/haproxy.cfg
cp /vagrant/conf/haproxy.cfg /etc/haproxy/

systemctl restart haproxy
