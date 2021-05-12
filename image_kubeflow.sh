docker pull aipipeline/kubeflow-operator:v1.2.0

docker tag aipipeline/kubeflow-operator:v1.2.0 192.168.6.100:5000/kubeflow-operator:v1.2.0

docker push 192.168.6.100:5000/kubeflow-operator:v1.2.0
