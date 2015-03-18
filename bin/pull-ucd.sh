#!/bin/bash
set -e
set -x

docker pull clmdocker01.ratl.swg.usma.ibm.com/ibmbid/ucdserver-base
docker tag clmdocker01.ratl.swg.usma.ibm.com/ibmbid/ucdserver-base ucdserver-base
docker rmi clmdocker01.ratl.swg.usma.ibm.com/ibmbid/ucdserver-base

docker pull clmdocker01.ratl.swg.usma.ibm.com/ibmbid/ucdserver-docker
docker tag clmdocker01.ratl.swg.usma.ibm.com/ibmbid/ucdserver-docker ucdserver-docker
docker rmi clmdocker01.ratl.swg.usma.ibm.com/ibmbid/ucdserver-docker

docker pull clmdocker01.ratl.swg.usma.ibm.com/ibmbid/ucdagent
docker tag clmdocker01.ratl.swg.usma.ibm.com/ibmbid/ucdagent ucdagent
docker rmi clmdocker01.ratl.swg.usma.ibm.com/ibmbid/ucdagent
