#!/bin/bash
set -eE

# Check if arguments are provided
if [[ $# != 2 ]]; then
  echo "Usage: $0 <type> <controller>"
  echo "Example: $0 sts mon-sts"
  exit 1
fi

type=$1
name=$2

# Check if the Kubernetes controller exists
if ! kubectl get "$type" "$name" &>/dev/null; then
  echo "Unable to retrieve info about the $type controller $name."
  exit 1
fi

# Function to clean up and rollback
function clean {
  echo "Rolling back controller objects..."
  if [[ -n $STS ]]; then
    echo "$STS" | kubectl apply -f -
  fi
}

# Store the current state of the controller
STS=$(kubectl get "$type" "$name" -ojson)

# Set up the trap for clean-up on error or exit
trap clean ERR SIGINT SIGQUIT EXIT

# Delete the controller without deleting associated resources (pods)
kubectl delete "$type" "$name" --cascade=false

echo "Controller deleted. You can modify any pod created by the $type $name."

# Optionally, interact with the user or automate the rollback step
echo "Press any key when you are done to proceed and rollback controller $name."
read -r

echo "Operation ended."

