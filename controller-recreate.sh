#!/bin/bash
set -eE

function usage {
    echo "Usage: $0 <type> <controller> [namespace]"
    echo "Example: $0 sts mon-sts default"
    exit 1
}

# Check if sufficient arguments are provided
if [[ $# -lt 2 ]]; then
    usage
fi

type=$1
name=$2
namespace=${3:-default}  # Default to 'default' namespace if not provided

# Check if the Kubernetes controller exists in the specified namespace
if ! kubectl get "$type" "$name" -n "$namespace" &>/dev/null; then
    echo "Error: Unable to retrieve $type $name in namespace $namespace." \
         "Ensure the resource exists and the namespace is correct."
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
STS=$(kubectl get "$type" "$name" -n "$namespace" -ojson)

# Set up traps for errors and interrupts
trap clean ERR SIGINT SIGQUIT

# Delete the controller without deleting associated resources (pods)
kubectl delete "$type" "$name" --cascade=false -n "$namespace"

echo "Controller deleted. You can modify any pod created by the $type $name."

# Interact with the user for rollback confirmation
echo "Do you want to rollback the controller $name? [y/N]"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    clean
else
    echo "Rollback skipped."
fi

echo "Operation ended."
