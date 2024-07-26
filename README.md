# Kubernetes Controller Recreate
**Controller-recreate.sh** is a Bash script designed to safely delete and recreate Kubernetes controllers. This script ensures that the specified controller is recreated exactly as it was, once the operation is completed or if the script encounters a problem, or if the user kills it prematurely (except in the case of a kill -9).

### Features
Safely deletes and recreates Kubernetes controllers (e.g., StatefulSets, Deployments).
Captures the current state of the controller before deletion.
Provides a rollback mechanism to restore the controller to its previous state.
Handles errors and interrupts to ensure the controller is recreated if the script is terminated unexpectedly.

### Requirements
kubectl installed and configured to interact with your Kubernetes cluster.


### Usage
Clone this repository and make the script executable:
Run the script with the appropriate arguments:

` ./controller-recreate.sh <type> <controller-name> `
- _type_: The type of the Kubernetes controller (sts for StatefulSet, deploy for Deployment).
- _controller-name_: The name of the Kubernetes controller.
  
