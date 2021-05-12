opm alpha bundle generate --directory ./kubeflow --package kubeflow_custom --channels alpha --default alpha
docker build -t {registry}/ai-devops-bundle:1.2.0 -f bundle.Dockerfile .
docker push {registry}/ai-devops-bundle:1.2.0

opm index add --bundles {registry}/ai-devops-bundle:1.2.0 --tag {regsitry}/ai-devops-index-registry:1.2.0 -c="docker"
docker push {registry}/ai-devops-index-registry:1.2.0 
