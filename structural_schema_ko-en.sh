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
# Delete trainedmodels.serving.kubeflow.org 
kubectl delete crd trainedmodels.serving.kubeflow.org 

echo "==============================================================="
echo "STEP 2. CREATE CRD"
echo "==============================================================="

# Create experiments.kubeflow.org
kubectl create -f ./crd-for-hypercloud/experiments/experiment_key.yaml
# Create notebooks.kubeflow.tmax.io
kubectl create -f ./crd-for-hypercloud/notebooks/notebooks_key.yaml
# Create tfjobs.kubeflow.org
kubectl create -f ./crd-for-hypercloud/tfjobs/tfjob_key.yaml
# Create pytorchjobs.kubeflow.org 
kubectl create -f ./crd-for-hypercloud/pytorchjobs/pytorchjob_key.yaml
# Create inferenceservices.serving.kubeflow.org
kubectl create -f ./crd-for-hypercloud/inferenceservices/inferenceservice_key.yaml
# Create trainedmodels.serving.kubeflow.org 
kubectl create -f ./crd-for-hypercloud/trainedmodels/trainedmodel_key.yaml
