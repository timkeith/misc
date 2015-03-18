#!/bin/bash
set -e
set -x

docker pull clmdocker01.ratl.swg.usma.ibm.com/ibmbid/$1
docker tag clmdocker01.ratl.swg.usma.ibm.com/ibmbid/$1 $1
docker tag clmdocker01.ratl.swg.usma.ibm.com/ibmbid/$1 ibmbid/$1
docker rmi clmdocker01.ratl.swg.usma.ibm.com/ibmbid/$1
