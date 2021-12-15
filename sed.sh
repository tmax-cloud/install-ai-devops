#!/bin/bash

registry=""
dir=""

if [ $# -eq 2 ];  then
	registry=$1
	dir=$2
else 
	echo "[$0] ERROR!! Invalid argument count"
	echo "[$0] [Usage] $0 192.168.6.110:5000 ${KF_DIR}/kustomize"
	exit 1
fi

echo "[$0] Modify images in Kustomize manifest files"

sed -i "s/image: \"gcr.io\/ml-pipeline\/minio/image: \"${registry}\/gcr.io\/ml-pipeline\/minio/g" ${dir}/pipeline\/upstream\/env\/platform-agnostic\/minio\/minio-deployment.yaml
sed -i "s/image: \"docker.io\/istio\/proxyv2/image: \"${registry}\/docker.io\/istio\/proxyv2/g" ${dir}/istio-1-3-1\/cluster-local-gateway-1-3-1\/base\/deployment.yaml
sed -i "s/newName: gcr.io\/kubeflow-images-public\/kubernetes-sigs\/application/newName: ${registry}\/gcr.io\/kubeflow-images-public\/kubernetes-sigs\/application/g" ${dir}/application/v3/kustomization.yaml
sed -i "s/newName: gcr.io\/kubeflow-images-public\/profile-controller/newName: ${registry}\/gcr.io\/kubeflow-images-public\/profile-controller/g" ${dir}/stacks/ibm/application/profiles/base/kustomization.yaml
sed -i "s/newName: gcr.io\/kubeflow-images-public\/kfam/newName: ${registry}\/gcr.io\/kubeflow-images-public\/kfam/g" ${dir}/stacks/ibm/application/profiles/base/kustomization.yaml
sed -i "s/\"image\": \"docker.io\/kubeflowkatib\/file-metrics-collector/\"image\": \"${registry}\/docker.io\/kubeflowkatib\/file-metrics-collector/g" ${dir}/katib\/components\/controller\/katib-config.yaml
sed -i "s/\"image\": \"docker.io\/kubeflowkatib\/tfevent-metrics-collector/\"image\": \"${registry}\/docker.io\/kubeflowkatib\/tfevent-metrics-collector/g" ${dir}/katib\/components\/controller\/katib-config.yaml
sed -i "s/\"image\": \"docker.io\/kubeflowkatib\/suggestion-hyperopt/\"image\": \"${registry}\/docker.io\/kubeflowkatib\/suggestion-hyperopt/g" ${dir}/katib\/components\/controller\/katib-config.yaml
sed -i "s/\"image\": \"docker.io\/kubeflowkatib\/suggestion-chocolate/\"image\": \"${registry}\/docker.io\/kubeflowkatib\/suggestion-chocolate/g" ${dir}/katib\/components\/controller\/katib-config.yaml
sed -i "s/\"image\": \"docker.io\/kubeflowkatib\/suggestion-hyperband/\"image\": \"${registry}\/docker.io\/kubeflowkatib\/suggestion-hyperband/g" ${dir}/katib\/components\/controller\/katib-config.yaml
sed -i "s/\"image\": \"docker.io\/kubeflowkatib\/suggestion-skopt/\"image\": \"${registry}\/docker.io\/kubeflowkatib\/suggestion-skopt/g" ${dir}/katib\/components\/controller\/katib-config.yaml
sed -i "s/\"image\": \"docker.io\/kubeflowkatib\/suggestion-goptuna/\"image\": \"${registry}\/docker.io\/kubeflowkatib\/suggestion-goptuna/g" ${dir}/katib\/components\/controller\/katib-config.yaml
sed -i "s/\"image\": \"docker.io\/kubeflowkatib\/suggestion-enas/\"image\": \"${registry}\/docker.io\/kubeflowkatib\/suggestion-enas/g" ${dir}/katib\/components\/controller\/katib-config.yaml
sed -i "s/\"image\": \"docker.io\/kubeflowkatib\/suggestion-darts/\"image\": \"${registry}\/docker.io\/kubeflowkatib\/suggestion-darts/g" ${dir}/katib\/components\/controller\/katib-config.yaml
sed -i "s/\"image\": \"docker.io\/kubeflowkatib\/earlystopping-medianstop/\"image\": \"${registry}\/docker.io\/kubeflowkatib\/earlystopping-medianstop/g" ${dir}/katib\/components\/controller\/katib-config.yaml
sed -i "s/newName: docker.io\/kubeflowkatib\/katib-controller/newName: ${registry}\/docker.io\/kubeflowkatib\/katib-controller/g" ${dir}/katib/installs/katib-standalone/kustomization.yaml
sed -i "s/newName: docker.io\/kubeflowkatib\/katib-db-manager/newName: ${registry}\/docker.io\/kubeflowkatib\/katib-db-manager/g" ${dir}/katib/installs/katib-standalone/kustomization.yaml
sed -i "s/newName: docker.io\/kubeflowkatib\/katib-ui/newName: ${registry}\/docker.io\/kubeflowkatib\/katib-ui/g" ${dir}/katib/installs/katib-standalone/kustomization.yaml
sed -i "s/newName: docker.io\/kubeflowkatib\/cert-generator/newName: ${registry}\/docker.io\/kubeflowkatib\/cert-generator/g" ${dir}/katib/installs/katib-standalone/kustomization.yaml
sed -i "s/image: mysql/image: ${registry}\/mysql/g" ${dir}/katib/components/mysql/mysql.yaml
sed -i "s/image: docker.io\/kubeflowkatib\/mxnet-mnist/image: ${registry}\/docker.io\/kubeflowkatib\/mxnet-mnist/g" ${dir}/katib\/components\/controller\/trial-templates.yaml
sed -i "s/image: docker.io\/kubeflowkatib\/enas-cnn-cifar10-cpu/image: ${registry}\/docker.io\/kubeflowkatib\/enas-cnn-cifar10-cpu/g" ${dir}/katib\/components\/controller\/trial-templates.yaml
sed -i "s/image: docker.io\/kubeflowkatib\/pytorch-mnist/image: ${registry}\/docker.io\/kubeflowkatib\/pytorch-mnist/g" ${dir}/katib\/components\/controller\/trial-templates.yaml
sed -i "s/newName: argoproj\/argoui/newName: ${registry}\/argoproj\/argoui/g" ${dir}/argo/base_v3/kustomization.yaml
sed -i "s/newName: argoproj\/workflow-controller/newName: ${registry}\/argoproj\/workflow-controller/g" ${dir}/argo/base_v3/kustomization.yaml
sed -i "s/image: argoproj\/argocli/image: ${registry}\/argoproj\/argocli/g" ${dir}/argo\/base\/deployment.yaml
sed -i "s/image: argoproj\/workflow-controller/image: ${registry}\/argoproj\/workflow-controller/g" ${dir}/argo\/base\/deployment.yaml
sed -i "s/argoproj\/argoexec/${registry}\/argoproj\/argoexec/g" ${dir}/argo\/base\/deployment.yaml
sed -i "s/newName: gcr.io\/kubeflow-images-public\/notebook-controller/newName: ${registry}\/gcr.io\/kubeflow-images-public\/notebook-controller/g" ${dir}/stacks/ibm/application/notebook-controller/kustomization.yaml
sed -i "s/image: tmaxcloudck\/notebook-controller-go/image: ${registry}\/tmaxcloudck\/notebook-controller-go/g" ${dir}/jupyter\/notebook-controller\/base\/deployment.yaml
sed -i "s/newName: gcr.io\/kubeflow-images-public\/pytorch-operator/newName: ${registry}\/gcr.io\/kubeflow-images-public\/pytorch-operator/g" ${dir}/pytorch-job/pytorch-operator/base/kustomization.yaml
sed -i "s/newName: gcr.io\/kubeflow-images-public\/tf_operator/newName: ${registry}\/gcr.io\/kubeflow-images-public\/tf_operator/g" ${dir}/tf-training/tf-job-operator/base/kustomization.yaml
sed -i "s/newName: gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/activator/newName: ${registry}\/gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/activator/g" ${dir}/knative/installs/generic/kustomization.yaml
sed -i "s/newName: gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/autoscaler/newName: ${registry}\/gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/autoscaler/g" ${dir}/knative/installs/generic/kustomization.yaml
sed -i "s/newName: gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/webhook/newName: ${registry}\/gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/webhook/g" ${dir}/knative/installs/generic/kustomization.yaml
sed -i "s/newName: gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/controller/newName: ${registry}\/gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/controller/g" ${dir}/knative/installs/generic/kustomization.yaml
sed -i "s/newName: gcr.io\/knative-releases\/knative.dev\/net-istio\/cmd\/controller/newName: ${registry}\/gcr.io\/knative-releases\/knative.dev\/net-istio\/cmd\/controller/g" ${dir}/knative/installs/generic/kustomization.yaml
sed -i "s/newName: gcr.io\/knative-releases\/knative.dev\/net-istio\/cmd\/webhook/newName: ${registry}\/gcr.io\/knative-releases\/knative.dev\/net-istio\/cmd\/webhook/g" ${dir}/knative/installs/generic/kustomization.yaml
sed -i "s/newName: gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/activator/newName: ${registry}\/gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/activator/g" ${dir}/knative/knative-serving-install/base/kustomization.yaml
sed -i "s/newName: gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/autoscaler/newName: ${registry}\/gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/autoscaler/g" ${dir}/knative/knative-serving-install/base/kustomization.yaml
sed -i "s/newName: gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/webhook/newName: ${registry}\/gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/webhook/g" ${dir}/knative/knative-serving-install/base/kustomization.yaml
sed -i "s/newName: gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/controller/newName: ${registry}\/gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/controller/g" ${dir}/knative/knative-serving-install/base/kustomization.yaml
sed -i "s/newName: gcr.io\/knative-releases\/knative.dev\/net-istio\/cmd\/controller/newName: ${registry}\/gcr.io\/knative-releases\/knative.dev\/net-istio\/cmd\/controller/g" ${dir}/knative/knative-serving-install/base/kustomization.yaml
sed -i "s/newName: gcr.io\/knative-releases\/knative.dev\/net-istio\/cmd\/webhook/newName: ${registry}\/gcr.io\/knative-releases\/knative.dev\/net-istio\/cmd\/webhook/g" ${dir}/knative/knative-serving-install/base/kustomization.yaml
sed -i "s/queueSidecarImage: 'gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/queue/queueSidecarImage: '${registry}\/gcr.io\/knative-release\/knative.dev\/serving\/cmd\/queue/g" ${dir}/knative\/knative-serving-install\/base\/config-map.yaml
sed -i "s/image: gcr.io\/knative-releases\/knative.dev\/serving\/cmd\/queue/image: '${registry}\/gcr.io\/knative-release\/knative.dev\/serving\/cmd\/queue/g" ${dir}/knative\/knative-serving-install\/base\/image.yaml
sed -i "s/\"image\" : \"kfserving\/agent/\"image\" : \"${registry}\/kfserving\/agent/g" ${dir}/kfserving\/upstream\/kfserving.yaml
sed -i "s/\"image\" : \"kfserving\/alibi-explainer/\"image\" : \"${registry}\/kfserving\/alibi-explainer/g" ${dir}/kfserving\/upstream\/kfserving.yaml
sed -i "s/\"image\" : \"kfserving\/aix-explainer/\"image\" : \"${registry}\/kfserving\/aix-explainer/g" ${dir}/kfserving\/upstream\/kfserving.yaml
sed -i "s/\"image\" : \"kfserving\/art-explainer/\"image\" : \"${registry}\/kfserving\/art-explainer/g" ${dir}/kfserving\/upstream\/kfserving.yaml
sed -i "s/\"image\": \"tensorflow\/serving/\"image\": \"${registry}\/tensorflow\/serving/g" ${dir}/kfserving\/upstream\/kfserving.yaml
sed -i "s/\"image\": \"mcr.microsoft.com\/onnxruntime\/server/\"image\": \"${registry}\/mcr.microsoft.com\/onnxruntime\/server/g" ${dir}/kfserving\/upstream\/kfserving.yaml
sed -i "s/\"image\": \"gcr.io\/kfserving\/sklearnserver/\"image\": \"${registry}\/gcr.io\/kfserving\/sklearnserver/g" ${dir}/kfserving\/upstream\/kfserving.yaml
sed -i "s/\"image\": \"docker.io\/seldonio\/mlserver/\"image\": \"${registry}\/docker.io\/seldonio\/mlserver/g" ${dir}/kfserving\/upstream\/kfserving.yaml
sed -i "s/\"image\": \"gcr.io\/kfserving\/xgbserver/\"image\": \"${registry}\/gcr.io\/kfserving\/xgbserver/g" ${dir}/kfserving\/upstream\/kfserving.yaml
sed -i "s/\"image\": \"gcr.io\/kfserving\/pytorchserver/\"image\": \"${registry}\/gcr.io\/kfserving\/pytorchserver/g" ${dir}/kfserving\/upstream\/kfserving.yaml
sed -i "s/\"image\": \"kfserving\/torchserve-kfs/\"image\": \"${registry}\/kfserving\/torchserve-kfs/g" ${dir}/kfserving\/upstream\/kfserving.yaml
sed -i "s/\"image\": \"nvcr.io\/nvidia\/tritonserver/\"image\": \"${registry}\/nvcr.io\/nvidia\/tritonserver/g" ${dir}/kfserving\/upstream\/kfserving.yaml
sed -i "s/\"image\": \"kfserving\/pmmlserver/\"image\": \"${registry}\/kfserving\/pmmlserver/g" ${dir}/kfserving\/upstream\/kfserving.yaml
sed -i "s/\"image\": \"kfserving\/lgbserver/\"image\": \"${registry}\/kfserving\/lgbserver/g" ${dir}/kfserving\/upstream\/kfserving.yaml
sed -i "s/\"image\" : \"gcr.io\/kfserving\/storage-initializer/\"image\" : \"${registry}\/gcr.io\/kfserving\/storage-initializer/g" ${dir}/kfserving\/upstream\/kfserving.yaml
sed -i "s/image: gcr.io\/kfserving\/kfserving-controller/image: ${registry}\/gcr.io\/kfserving\/kfserving-controller/g" ${dir}/kfserving\/upstream\/kfserving.yaml
sed -i "s/image: gcr.io\/kubebuilder\/kube-rbac-proxy/image: ${registry}\/gcr.io\/kubebuilder\/kube-rbac-proxy/g" ${dir}/kfserving\/upstream\/kfserving.yaml
sed -i "s/gcr.io\/kubeflow-images-public\/tensorflow-1.15.2-notebook-cpu/${registry}\/gcr.io\/kubeflow-images-public\/tensorflow-1.15.2-notebook-cpu/g" ${dir}/jupyter/jupyter-web-app/base/configs/spawner_ui_config.yaml
sed -i "s/gcr.io\/kubeflow-images-public\/tensorflow-1.15.2-notebook-gpu/${registry}\/gcr.io\/kubeflow-images-public\/tensorflow-1.15.2-notebook-gpu/g" ${dir}/jupyter/jupyter-web-app/base/configs/spawner_ui_config.yaml
sed -i "s/gcr.io\/kubeflow-images-public\/tensorflow-2.1.0-notebook-cpu/${registry}\/gcr.io\/kubeflow-images-public\/tensorflow-2.1.0-notebook-cpu/g" ${dir}/jupyter/jupyter-web-app/base/configs/spawner_ui_config.yaml
sed -i "s/gcr.io\/kubeflow-images-public\/tensorflow-2.1.0-notebook-gpu/${registry}\/gcr.io\/kubeflow-images-public\/tensorflow-2.1.0-notebook-gpu/g" ${dir}/jupyter/jupyter-web-app/base/configs/spawner_ui_config.yaml

echo "[$0] Done"
