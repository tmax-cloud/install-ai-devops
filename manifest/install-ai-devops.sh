#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd $SCRIPTDIR

# Apply configuration
source ./ai-devops.config

echo "DISCOVERY_URL = $DISCOVERY_URL"
echo "CLIENT_SECRET = $CLIENT_SECRET"
echo "CUSTOM_DOMAIN = $CUSTOM_DOMAIN"
echo "GATEKEEPER_VERSION = $GATEKEEPER_VERSION"
echo "LOG_LEVEL = $LOG_LEVEL"

if [ $REGISTRY != "{REGISTRY}" ]; then
  echo "REGISTRY = $REGISTRY"
fi

sed -i 's@{DISCOVERY_URL}@'${DISCOVERY_URL}'@g' 10.notebook.yaml
sed -i 's/{CLIENT_SECRET}/'${CLIENT_SECRET}'/g' 10.notebook.yaml
sed -i 's/{CUSTOM_DOMAIN}/'${CUSTOM_DOMAIN}'/g' 10.notebook.yaml
sed -i 's/{GATEKEEPER_VERSION}/'${GATEKEEPER_VERSION}'/g' 10.notebook.yaml
sed -i 's/{LOG_LEVEL}/'${LOG_LEVEL}'/g' 10.notebook.yaml


if [ $REGISTRY != "{REGISTRY}" ]; then
  sed -i "s/image: \"docker.io\/istio\/proxyv2/image: \"${registry}\/docker.io\/istio\/proxyv2/g" 1.cluster-local-gateway.yaml
  sed -i "s/image: gcr.io\/kubeflow-images-public\/kubernetes-sigs\/application/image: ${registry}\/gcr.io\/kubeflow-images-public\/kubernetes-sigs\/application/g" 4.application.yaml
  sed -i "s/image: gcr.io\/kubeflow-images-public\/profile-controller/image: ${registry}\/gcr.io\/kubeflow-images-public\/profile-controller/g" 5.kubeflow-apps.yaml
  sed -i "s/image: gcr.io\/kubeflow-images-public\/kfam/image: ${registry}\/gcr.io\/kubeflow-images-public\/kfam/g" 5.kubeflow-apps.yaml
  sed -i "s/\"image\": \"docker.io\/kubeflowkatib\/file-metrics-collector/\"image\": \"${registry}\/docker.io\/kubeflowkatib\/file-metrics-collector/g" 6.katib.yaml
  sed -i "s/\"image\": \"docker.io\/kubeflowkatib\/tfevent-metrics-collector/\"image\": \"${registry}\/docker.io\/kubeflowkatib\/tfevent-metrics-collector/g" 6.katib.yaml
  sed -i "s/\"image\": \"docker.io\/kubeflowkatib\/suggestion-hyperopt/\"image\": \"${registry}\/docker.io\/kubeflowkatib\/suggestion-hyperopt/g" 6.katib.yaml
  sed -i "s/\"image\": \"docker.io\/kubeflowkatib\/suggestion-chocolate/\"image\": \"${registry}\/docker.io\/kubeflowkatib\/suggestion-chocolate/g" 6.katib.yaml
  sed -i "s/\"image\": \"docker.io\/kubeflowkatib\/suggestion-hyperband/\"image\": \"${registry}\/docker.io\/kubeflowkatib\/suggestion-hyperband/g" 6.katib.yaml
  sed -i "s/\"image\": \"docker.io\/kubeflowkatib\/suggestion-skopt/\"image\": \"${registry}\/docker.io\/kubeflowkatib\/suggestion-skopt/g" 6.katib.yaml
  sed -i "s/\"image\": \"docker.io\/kubeflowkatib\/suggestion-goptuna/\"image\": \"${registry}\/docker.io\/kubeflowkatib\/suggestion-goptuna/g" 6.katib.yaml
  sed -i "s/\"image\": \"docker.io\/kubeflowkatib\/suggestion-enas/\"image\": \"${registry}\/docker.io\/kubeflowkatib\/suggestion-enas/g" 6.katib.yaml
  sed -i "s/\"image\": \"docker.io\/kubeflowkatib\/suggestion-darts/\"image\": \"${registry}\/docker.io\/kubeflowkatib\/suggestion-darts/g" 6.katib.yaml
  sed -i "s/\"image\": \"docker.io\/kubeflowkatib\/earlystopping-medianstop/\"image\": \"${registry}\/docker.io\/kubeflowkatib\/earlystopping-medianstop/g" 6.katib.yaml
  sed -i "s/image: docker.io\/kubeflowkatib\/katib-controller/image: ${registry}\/docker.io\/kubeflowkatib\/katib-controller/g" 6.katib.yaml
  sed -i "s/image: docker.io\/kubeflowkatib\/katib-db-manager/image: ${registry}\/docker.io\/kubeflowkatib\/katib-db-manager/g" 6.katib.yaml
  sed -i "s/image: docker.io\/kubeflowkatib\/katib-ui/image: ${registry}\/docker.io\/kubeflowkatib\/katib-ui/g" 6.katib.yaml
  sed -i "s/image: docker.io\/kubeflowkatib\/cert-generator/image: ${registry}\/docker.io\/kubeflowkatib\/cert-generator/g" 6.katib.yaml
  sed -i "s/image: mysql/image: ${registry}\/mysql/g" 6.katib.yaml
  sed -i "s/image: docker.io\/kubeflowkatib\/mxnet-mnist/image: ${registry}\/docker.io\/kubeflowkatib\/mxnet-mnist/g" 6.katib.yaml
  sed -i "s/image: docker.io\/kubeflowkatib\/enas-cnn-cifar10-cpu/image: ${registry}\/docker.io\/kubeflowkatib\/enas-cnn-cifar10-cpu/g" 6.katib.yaml
  sed -i "s/image: docker.io\/kubeflowkatib\/pytorch-mnist/image: ${registry}\/docker.io\/kubeflowkatib\/pytorch-mnist/g" 6.katib.yaml
  sed -i "s/\"image\" : \"kfserving\/agent/\"image\" : \"${registry}\/kfserving\/agent/g" 7.kfserving.yaml
  sed -i "s/\"image\" : \"kfserving\/alibi-explainer/\"image\" : \"${registry}\/kfserving\/alibi-explainer/g" 7.kfserving.yaml
  sed -i "s/\"image\" : \"kfserving\/aix-explainer/\"image\" : \"${registry}\/kfserving\/aix-explainer/g" 7.kfserving.yaml
  sed -i "s/\"image\" : \"kfserving\/art-explainer/\"image\" : \"${registry}\/kfserving\/art-explainer/g" 7.kfserving.yaml
  sed -i "s/\"image\": \"tensorflow\/serving/\"image\": \"${registry}\/tensorflow\/serving/g" 7.kfserving.yaml
  sed -i "s/\"image\": \"mcr.microsoft.com\/onnxruntime\/server/\"image\": \"${registry}\/mcr.microsoft.com\/onnxruntime\/server/g" 7.kfserving.yaml
  sed -i "s/\"image\": \"gcr.io\/kfserving\/sklearnserver/\"image\": \"${registry}\/gcr.io\/kfserving\/sklearnserver/g" 7.kfserving.yaml
  sed -i "s/\"image\": \"docker.io\/seldonio\/mlserver/\"image\": \"${registry}\/docker.io\/seldonio\/mlserver/g" 7.kfserving.yaml
  sed -i "s/\"image\": \"gcr.io\/kfserving\/xgbserver/\"image\": \"${registry}\/gcr.io\/kfserving\/xgbserver/g" 7.kfserving.yaml
  sed -i "s/\"image\": \"gcr.io\/kfserving\/pytorchserver/\"image\": \"${registry}\/gcr.io\/kfserving\/pytorchserver/g" 7.kfserving.yaml
  sed -i "s/\"image\": \"kfserving\/torchserve-kfs/\"image\": \"${registry}\/kfserving\/torchserve-kfs/g" 7.kfserving.yaml
  sed -i "s/\"image\": \"nvcr.io\/nvidia\/tritonserver/\"image\": \"${registry}\/nvcr.io\/nvidia\/tritonserver/g" 7.kfserving.yaml
  sed -i "s/\"image\": \"kfserving\/pmmlserver/\"image\": \"${registry}\/kfserving\/pmmlserver/g" 7.kfserving.yaml
  sed -i "s/\"image\": \"kfserving\/lgbserver/\"image\": \"${registry}\/kfserving\/lgbserver/g" 7.kfserving.yaml
  sed -i "s/\"image\" : \"gcr.io\/kfserving\/storage-initializer/\"image\" : \"${registry}\/gcr.io\/kfserving\/storage-initializer/g" 7.kfserving.yaml
  sed -i "s/image: gcr.io\/kfserving\/kfserving-controller/image: ${registry}\/gcr.io\/kfserving\/kfserving-controller/g" 7.kfserving.yaml
  sed -i "s/image: gcr.io\/kubebuilder\/kube-rbac-proxy/image: ${registry}\/gcr.io\/kubebuilder\/kube-rbac-proxy/g" 7.kfserving.yaml
  sed -i "s/image: \"gcr.io\/ml-pipeline\/minio/image: \"${registry}\/gcr.io\/ml-pipeline\/minio/g" 8.minio.yaml
  sed -i "s/image: gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/activator/image: ${registry}\/gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/activator/g" 9.knative.yaml
  sed -i "s/image: gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/autoscaler/image: ${registry}\/gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/autoscaler/g" 9.knative.yaml
  sed -i "s/image: gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/webhook/image: ${registry}\/gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/webhook/g" 9.knative.yaml
  sed -i "s/image: gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/controller/image: ${registry}\/gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/controller/g" 9.knative.yaml
  sed -i "s/image: gcr.io\/knative-releases\/knative.dev\/net-istio\/cmd\/controller/image: ${registry}\/gcr.io\/knative-releases\/knative.dev\/net-istio\/cmd\/controller/g" 9.knative.yaml
  sed -i "s/image: gcr.io\/knative-releases\/knative.dev\/net-istio\/cmd\/webhook/image: ${registry}\/gcr.io\/knative-releases\/knative.dev\/net-istio\/cmd\/webhook/g" 9.knative.yaml
  sed -i "s/image: gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/activator/image: ${registry}\/gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/activator/g" 9.knative.yaml
  sed -i "s/image: gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/autoscaler/image: ${registry}\/gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/autoscaler/g" 9.knative.yaml
  sed -i "s/image: gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/webhook/image: ${registry}\/gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/webhook/g" 9.knative.yaml
  sed -i "s/image: gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/controller/image: ${registry}\/gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/controller/g" 9.knative.yaml
  sed -i "s/image: gcr.io\/knative-releases\/knative.dev\/net-istio\/cmd\/controller/image: ${registry}\/gcr.io\/knative-releases\/knative.dev\/net-istio\/cmd\/controller/g" 9.knative.yaml
  sed -i "s/image: gcr.io\/knative-releases\/knative.dev\/net-istio\/cmd\/webhook/image: ${registry}\/gcr.io\/knative-releases\/knative.dev\/net-istio\/cmd\/webhook/g" 9.knative.yaml
  sed -i "s/queueSidecarImage: 'gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/queue/queueSidecarImage: '${registry}\/gcr.io\/knative-release\/knative.dev\/serving\/cmd\/queue/g" 9.knative.yaml
  sed -i "s/image: gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/queue/image: '${registry}\/gcr.io\/knative-release\/knative.dev\/serving\/cmd\/queue/g" 9.knative.yaml
  sed -i "s/image: gcr.io\/kubeflow-images-public\/pytorch-operator/image: ${registry}\/gcr.io\/kubeflow-images-public\/pytorch-operator/g" 10.pytorchjob.yaml
  sed -i "s/image: gcr.io\/kubeflow-images-public\/tf_operator/image: ${registry}\/gcr.io\/kubeflow-images-public\/tf_operator/g" 11.tfjob.yaml
  sed -i "s/image: tmaxcloudck\/notebook-controller-go/image: ${registry}\/tmaxcloudck\/notebook-controller-go/g" 12.notebook.yaml
  sed -i "s/image: docker.io\/tmaxcloudck\/kale-tekton-standalone/image: ${registry}\/docker.io\/tmaxcloudck\/kale-tekton-standalone/g" 12.notebook.yaml
fi 


#  Install AI-DEVOPS
echo " "
echo "---Installation Start---"
echo " "
echo "---1. Install cluster-local-gateway---"
kubectl apply -f 1.cluster-local-gateway.yaml
echo "---2. Install kubeflow-istio-resource---"
kubectl apply -f 2.kubeflow-istio-resource.yaml
echo "---3. Install training-operator---"
kubectl create -f 3.training-operator.yaml
echo "---4. Install profile-kfam---"
kubectl apply -f 4.profile-kfam.yaml
echo "---5. Install kubeflow-roles---"
kubectl apply -f 5.kubeflow-roles.yaml
echo "---6. Install katib---"
kubectl create -f 6.katib.yaml
echo "---7. Install kfserving---"
kubectl create -f 7.kfserving.yaml
echo "---8. Install minio---"
kubectl apply -f 8.minio.yaml
echo "---9. Install knative---"
kubectl apply -f 9.knative.yaml
echo "---10. Install notebook---"
kubectl install -f 10.notebook.yaml




