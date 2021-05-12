docker pull aipipeline/kubeflow-operator:v1.2.0

docker tag aipipeline/kubeflow-operator:v1.2.0 {registry}/kubeflow-operator:v1.2.0

docker push {registry}/kubeflow-operator:v1.2.0
