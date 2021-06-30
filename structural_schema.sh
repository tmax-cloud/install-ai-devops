#!/bin/sh 

echo "==============================================================="
echo "STEP 1. DELETE EXISTING CRD"
echo "==============================================================="
# Delete tfjobs.kubeflow.org
kubectl delete crd tfjobs.kubeflow.org  
# Delete pytorchjobs.kubeflow.org 
kubectl delete crd pytorchjobs.kubeflow.org 
# Delete inferenceservices.serving.kubeflow.org 
kubectl delete crd inferenceservices.serving.kubeflow.org 

echo "==============================================================="
echo "STEP 2. CREATE CRD"
echo "==============================================================="

# Create tfjobs.kubeflow.org
kubectl create -f ./crd-for-hypercloud/tfjobs/tfjob_original.yaml
# Create pytorchjobs.kubeflow.org 
kubectl create -f ./crd-for-hypercloud/pytorchjobs/pytorchjob_original.yaml
# Create inferenceservices.serving.kubeflow.org
kubectl create -f ./crd-for-hypercloud/inferenceservices/inferenceservice_original.yaml
