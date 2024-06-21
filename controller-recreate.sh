#!/bin/bash
set -eE

if [[ $# != 2 ]]; then
  echo Usage: $0 type controller
  echo Example: $0 sts mon-sts
  exit 1
fi

type=$1
name=$2

if ! kubectl get $type $name &>/dev/null ; then
  echo Unable to retrieve info about the $type controller $name
  exit 1
fi

function clean {
  echo Rollbacking controller objects...
  if [[ ! -z $STS ]]; then
    echo $STS | kubectl apply -f -
  fi
}

STS=$(kubectl get $type $name -ojson)

trap clean ERR SIGINT SIGQUIT EXIT

kubectl delete $type $name --cascade=false

echo Controller deleted. You can modify any pod created by the $type $name
echo Press any key when you are done to proceed and rollback controller $name
read

echo Operation ended gracefully
