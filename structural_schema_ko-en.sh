#!/bin/sh 

echo "==============================================================="
echo "STEP 1. DELETE EXISTING CRD"
echo "==============================================================="
# Delete experiments.kubeflow.org
kubectl delete crd experiments.kubeflow.org 
# Delete notebooks.kubeflow.tmax.io
kubectl delete crd notebooks.kubeflow.tmax.io
# Delete tfjobs.kubeflow.org
kubectl delete crd tfjobs.kubeflow.org  
# Delete pytorchjobs.kubeflow.org 
kubectl delete crd pytorchjobs.kubeflow.org 
# Delete inferenceservices.serving.kubeflow.org 
kubectl delete crd inferenceservices.serving.kubeflow.org 

echo "==============================================================="
echo "STEP 2. CREATE CRD"
echo "==============================================================="

# Create CRD 
kubectl create -f ko-en.yaml
