#!/bin/bash
ip=$(ip addr show eth1 | sed -n 's=.* inet \(.*\)/.*=\1=p')
echo "Server URL: http://$ip:8080/"
docker run -p 8080:8080 -p 7918:7918 -v /tmp/ucddata:/ucddata ucdserver-docker
