#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd $SCRIPTDIR

# Uninstall AI-DEVOPS
echo " "
echo "---Uninstallation Start---"
echo " "
echo "---1. Delete cluster-local-gateway---"
kubectl delete -f 1.cluster-local-gateway.yaml
echo "---2. Delete kubeflow-istio-resource---"
kubectl delete -f 2.kubeflow-istio-resource.yaml
echo "---3. Delete add-anonymous-user-filter.yaml---"
kubectl delete -f 3.add-anonymous-user-filter.yaml
echo "---4. Delete application---"
kubectl delete -f 4.application.yaml
echo "---5. Delete kubeflow-apps---"
kubectl delete -f 5.kubeflow-apps.yaml
echo "---6. Delete katib---"
kubectl delete -f 6.katib.yaml
echo "---7. Delete kfserving---"
kubectl delete -f 7.kfserving.yaml
echo "---8. Delete minio---"
kubectl delete -f 8.minio.yaml
echo "---9. Delete knative---"
kubectl delete -f 9.knative.yaml
echo "---10. Delete pytorch-operator---"
kubectl delete -f 10.pytorchjob.yaml
echo "---11. Delete tf-operator---"
kubectl delete -f 11.tfjob.yaml
echo "---12. Delete notebook-controller---"
kubectl delete -f 12.notebook.yaml


