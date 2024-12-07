#!/usr/bin/env bash

set -eE


function usage {

    echo "Usage: $0 <type> <controller> [namespace]"

    echo "Example: $0 sts mon-sts default"

    exit 1

}


# Validate input arguments

if [[ $# -lt 2 ]] || [[ $1 == "-h" || $1 == "--help" ]]; then

    usage

fi


# Input parameters

type=$1

name=$2

namespace=${3:-default}


# Validate Kubernetes resource type

allowed_types=("sts" "deploy" "rs" "ds")

if [[ ! " ${allowed_types[@]} " =~ " $type " ]]; then

    echo "Error: Invalid type '$type'. Allowed types: ${allowed_types[*]}"

    exit 2

fi



# Check if namespace exists

if ! kubectl get namespace "$namespace" &>/dev/null; then

    echo "Error: Namespace '$namespace' does not exist."

    exit 3

fi



# Check if the resource exists

if ! kubectl get "$type" "$name" -n "$namespace" &>/dev/null; then

    echo "Error: Unable to retrieve $type $name in namespace $namespace."

    exit 4

fi



# Function to clean up and rollback

function clean {

    echo "Rolling back controller objects..."

    if [[ -n $controller_state ]]; then

        echo "$controller_state" | kubectl apply -f - || {

            echo "Error: Failed to rollback the controller."

            exit 5

        }

    fi

}



# Capture current state of the controller

controller_state=$(kubectl get "$type" "$name" -n "$namespace" -ojson)

if [[ -z $controller_state ]]; then

    echo "Error: Failed to fetch the current state of the controller."

    exit 6

fi



# Trap errors and interrupts for rollback

trap clean ERR SIGINT SIGQUIT



# Delete the controller safely

echo "Deleting controller '$type' named '$name' in namespace '$namespace'..."

kubectl delete "$type" "$name" --cascade=false -n "$namespace"



echo "Controller deleted. You can now modify the pods as needed."



# Rollback confirmation

read -rp "Do you want to rollback the controller '$name' to its previous state? [y/N]: " response

if [[ "$response" =~ ^[Yy]$ ]]; then

    clean

    echo "Rollback completed successfully."

else

    echo "Rollback skipped. Proceed with manual actions if needed."

fi


echo "Operation ended."
