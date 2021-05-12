# 1. 번들 이미지 작성을 위한 Dockerfile 구성
opm alpha bundle generate --directory ./kubeflow --package kubeflow_custom --channels alpha --default alpha
# 2. 번들 이미지 빌드
docker build -t 192.168.6.100:5000/my-manifest-bundle:0.1.1 -f bundle.Dockerfile .
# 3. 번들 이미지 푸시
docker push 192.168.6.100:5000/my-manifest-bundle:0.1.1



# 4. 번들 이미지를 Catalog Registry 이미지에 추가하여 빌드
opm index add --bundles 192.168.6.100:5000/my-manifest-bundle:0.1.1 --tag 192.168.6.100:5000/my-index-registry:0.1.1 -c="docker"
#opm index add --bundles 192.168.6.100:5000/my-manifest-bundle:0.0.6 -from-index 192.168.6.100:5000/my-index:5.0.0 -c="docker" --tag 192.168.6.100:5000/my-index:5.0.1 -c="docker"
# 5. Catalog Registry 이미지를 푸시
docker push 192.168.6.100:5000/my-index-registry:0.1.1
