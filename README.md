
# ai-devops 설치 가이드

## 구성 요소 및 버전
* Kubeflow v1.2.0 (https://github.com/kubeflow/kubeflow)
* Argo v2.12.10 (https://github.com/argoproj/argo)
* Jupyter (https://github.com/jupyter/notebook)
* Katib v0.10.0 (https://github.com/kubeflow/katib)
* KFServing v0.5.1 (https://github.com/kubeflow/kfserving)
* Training Job
    * TFJob v1.0.0 (https://github.com/kubeflow/tf-operator)
    * PytorchJob v1.0.0 (https://github.com/kubeflow/pytorch-operator)
* Notebook-controller b0.0.4
* ...

## Prerequisites
1. Storage class
    * 아래 명령어를 통해 storage class가 설치되어 있는지 확인한다.
        ```bash
        $ kubectl get storageclass
        ```
    * 만약 아무 storage class가 없다면 아래 링크로 이동하여 rook-ceph 설치한다.
        * https://github.com/tmax-cloud/install-rookceph/blob/main/README.md
    * Storage class는 있지만 default로 설정된 것이 없다면 아래 명령어를 실행한다.
        ```bash
        $ kubectl patch storageclass csi-cephfs-sc -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
        ```
    * csi-cephfs-sc는 위 링크로 rook-ceph를 설치했을 때 생성되는 storage class이며 다른 storage class를 default로 사용해도 무관하다.
2. Istio
    * v1.5.1
        * https://github.com/tmax-cloud/install-istio/blob/5.0/README.md
3. Prometheus
    * ai-devops의 모니터링 정보를 제공하기 위해 필요하다.
        * https://github.com/tmax-cloud/install-prometheus/blob/5.0/README.md
4. (Optional) GPU plug-in
    * Kubernetes cluster 내 node에 GPU가 탑재되어 있으며 AI DevOps 기능을 사용할 때 GPU가 요구될 경우에 필요하다.
        * https://github.com/tmax-cloud/install-nvidia-gpu-infra/blob/5.0/README.md

## 폐쇄망 설치 가이드
설치를 진행하기 전 아래의 과정을 통해 필요한 이미지 및 yaml 파일을 준비한다.
1. 이미지 준비
    * 아래 링크를 참고하여 폐쇄망에서 사용할 registry를 구축한다.
        * https://github.com/tmax-cloud/install-registry/blob/5.0/README.md
    * 자신이 사용할 registry의 IP와 port를 입력한다.
        ```bash
        $ export REGISTRY_ADDRESS=1.1.1.1:5000
        ```
    * 아래 명령어를 수행하여 Kubeflow 설치 시 필요한 이미지들을 위에서 구축한 registry에 push하고 이미지들을 tar 파일로 저장한다. tar 파일은 images 디렉토리에 저장된다.
        ```bash
        $ wget https://raw.githubusercontent.com/tmax-cloud/install-ai-devops/5/image-push.sh
        $ wget https://raw.githubusercontent.com/tmax-cloud/install-ai-devops/5/imagelist
        $ chmod +x ./image-push.sh
        $ ./image-push.sh ${REGISTRY_ADDRESS}
        ```
    * 아래 명령어를 수행하여 registry에 이미지들이 잘 push되었는지, 그리고 필요한 이미지들이 tar 파일로 저장되었는지 확인한다.
        ```bash
        $ curl -X GET ${REGISTRY_ADDRESS}/v2/_catalog
        $ ls ./images
        ```
    * (Optional) 만약 설치에 필요한 이미지들을 pull받아서 tar 파일로 저장하는 작업과 로드하여 push하는 작업을 따로 수행하고자 한다면 image-push.sh이 아니라 image-save.sh, image-load.sh를 각각 실행하면 된다. 
       * image-save.sh을 실행하면 설치에 필요한 이미지들을 pull 받아서 images 디렉토리에 tar 파일로 저장한다.
           ```bash
           $ wget https://raw.githubusercontent.com/tmax-cloud/install-ai-devops/5/image-save.sh
           $ chmod +x ./image-save.sh
           $ ./image-save.sh
           $ ls ./images
           ```
       * 위에서 저장한 images 디렉토리와 image-load.sh을 폐쇄망 환경으로 옮긴 후 실행하면 폐쇄망 내 구축한 registry에 이미지들을 push할 수 있다. image-load.sh은 images 디렉토리와 같은 경로에서 실행해야만 한다.
           ```bash
           $ chmod +x ./image-load.sh
           $ ./image-load.sh ${REGISTRY_ADDRESS}
           $ curl -X GET ${REGISTRY_ADDRESS}/v2/_catalog
           ```
2. Yaml 파일 및 script 파일 준비
    * 아래 명령어를 수행하여 Kubeflow 설치에 필요한 yaml 파일들과 script 파일들을 다운로드 받는다. 
        ```bash
        $ wget https://raw.githubusercontent.com/tmax-cloud/install-ai-devops/5/sed.sh
        $ wget https://raw.githubusercontent.com/tmax-cloud/install-ai-devops/5/kustomize_local.tar.gz
        $ wget https://raw.githubusercontent.com/tmax-cloud/install-ai-devops/5/kfctl_hypercloud_kubeflow.v1.0.2_local.yaml
        $ wget https://github.com/kubeflow/kfctl/releases/download/v1.2.0/kfctl_v1.2.0-0-gbc038f9_linux.tar.gz
        ```
3. 앞으로의 진행
    * Step 0 ~ 4 중 Step 0, 2, 3은 비고를 참고하여 진행한다. 나머지는 그대로 진행하면 된다.

## Install Steps
0. [olm 설치](https://github.com/tmax-cloud/install-OLM/blob/main/README.md)
1. [설치 디렉토리 생성](https://github.com/tmax-cloud/hypercloud-install-guide/blob/4.1/Kubeflow/README.md#step-1-%EC%84%A4%EC%B9%98-%EB%94%94%EB%A0%89%ED%86%A0%EB%A6%AC-%EC%83%9D%EC%84%B1)
2. [Kustomize 리소스 생성](https://github.com/tmax-cloud/hypercloud-install-guide/blob/4.1/Kubeflow/README.md#step-2-kustomize-%EB%A6%AC%EC%86%8C%EC%8A%A4-%EC%83%9D%EC%84%B1)
3. [Kubeflow 배포](https://github.com/tmax-cloud/hypercloud-install-guide/blob/4.1/Kubeflow/README.md#step-3-kubeflow-%EB%B0%B0%ED%8F%AC)
4. [배포 확인 및 기타 작업](https://github.com/tmax-cloud/hypercloud-install-guide/blob/4.1/Kubeflow/README.md#step-4-%EB%B0%B0%ED%8F%AC-%ED%99%95%EC%9D%B8-%EB%B0%8F-%EA%B8%B0%ED%83%80-%EC%9E%91%EC%97%85)

## Step 0. OLM 설치
* 목적 : `kubeflow operator를 관리하기 위한 toolkit으로 사용한다.`
* 생성 순서 : 다음 Git Repository/가이드를 참고하여 OLM을 설치한다.
            https://github.com/tmax-cloud/install-OLM/blob/main/README.md   
* 비고 : 
    * 폐쇄망 환경일 경우 위 repository의 폐쇄망 구축 가이드를 참고한다.

## Step 1. kubeflow operator 설치
* 목적 : `Kubeflow operator는 kubeflow를 배포하고 모니터링 하는 등 lifecycle을 관리한다.`
* 생성 순서 : 
    * 아래 명령어를 수행하여 kubeflow operator를 생성한다.
        ```bash
        $ kubectl create -f https://operatorhub.io/install/kubeflow.yaml
        ```
    * 설치되기까지 시간이 10분가량 소요될 있으며 정상적으로 완료되었는지 확인하기 위해 아래 명령어를 수행하여 kubeflow operator pod의 정상 동작을 확인한다.
        ```bash
        $ kubectl get pod -n operators
        ```
      ![스크린샷, 2021-04-14 11-55-55](https://user-images.githubusercontent.com/77767091/114647647-69848300-9d18-11eb-92ac-ec543473c16c.png)  
* 비고 : 
    * 폐쇄망 환경일 경우 설치 디렉토리 ${KF_DIR}에 미리 다운로드받은 sed.sh, kustomize_local.tar.gz 파일을 옮긴다.
    * 아래 명령어를 통해 Kustomize 리소스의 압축을 풀고 yaml 파일들에서 이미지들을 pull 받을 registry를 바꿔준다.
        ```bash
        $ tar xvfz kustomize_local.tar.gz
        $ chmod +x ./sed.sh
        $ ./sed.sh ${REGISTRY_ADDRESS} ${KF_DIR}/kustomize
        ```
        
## Step 2. 설치 디렉토리 생성
* 목적 : `Kubeflow의 설치 yaml이 저장될 설치 디렉토리를 생성하고 해당 경로로 이동한다.`
* 생성 순서 : 
    * 아래 명령어를 수행하여 설치 디렉토리를 생성하고 해당 경로로 이동한다.
        ```bash
        $ export KF_NAME=kubeflow
        $ export BASE_DIR=/home/${USER}
        $ export KF_DIR=${BASE_DIR}/${KF_NAME}
        $ mkdir -p ${KF_DIR}
        $ cd ${KF_DIR}
        ```
    * ${KF_DIR}이 설치 디렉토리이며 ${KF_NAME}, ${BASE_DIR}은 임의로 변경 가능하다.
   
## Step 3. Kubeflow 배포
* 목적 : `앞서 설치한 kubeflow operator를 통해 Kubeflow를 배포한다.`
* 생성 순서 : 
    * kubeflow operator는 kfDef를 CR로 사용하기 때문에 아래 명령어를 수행하여 kfDef configuration을 준비한다.
        ```bash
        $ export KFDEF_URL=https://raw.githubusercontent.com/tmax-cloud/kubeflow-manifests/ck-v1.2-patch/kfDef-hypercloud.yaml
        $ export KFDEF=$(echo "${KFDEF_URL}" | rev | cut -d/ -f1 | rev)
        $ curl -L ${KFDEF_URL} > ${KFDEF}
        ```
    * 아래 명령어를 통해 kfDef manifest에 반드시 설정되어야 하는 metadata.name 필드를 추가한다.(추가하지 않으면 invalid error 발생)
        ```bash
        $ export KUBEFLOW_DEPLOYMENT_NAME=kubeflow
        $ yq w ${KFDEF} 'metadata.name' ${KUBEFLOW_DEPLOYMENT_NAME} > ${KFDEF}.tmp && mv ${KFDEF}.tmp ${KFDEF}
        ```
    * https://github.com/mikefarah/yq를 참고하여 yq를 설치하거나 다음 명령어를 사용한다.
        ```bash
        $ perl -pi -e $'s@metadata:@metadata:\\\n  name: '"${KUBEFLOW_DEPLOYMENT_NAME}"'@' ${KFDEF}        
        ```
    * 아래 명령어를 통해 namespace를 생성하고 kfDef CR을 생성하여 kubeflow를 배포한다.
        ```bash
        $ KUBEFLOW_NAMESPACE=kubeflow
        $ kubectl create ns ${KUBEFLOW_NAMESPACE}
        $ kubectl create -f ${KFDEF} -n ${KUBEFLOW_NAMESPACE}
        ```
* 비고 :
    * 폐쇄망 환경일 경우 설치 디렉토리 ${KF_DIR}에 미리 다운로드받은 kfctl_hypercloud_kubeflow.v1.0.2_local.yaml 파일을 옮긴다.
    * 아래 명령어를 수행하여 Kubeflow를 배포한다.
        ```bash
        $ export CONFIG_FILE=${KF_DIR}/kfctl_hypercloud_kubeflow.v1.0.2_local.yaml
        $ kfctl apply -V -f ${CONFIG_FILE}
        ```
    * 기존 Kubeflow에서 수정된 점
        * Istio 1.5.1 호환을 위해 KFServing의 controller 수정
        * Workflow template을 사용하기 위한 argo controller 버전 업
        * Notebook CRD, controller 변경

## Step 4. 배포 확인 및 기타 작업
* 목적 : `Kubeflow 배포를 확인하고 문제가 있을 경우 정상화한다.`
* 생성 순서 : 
    * 아래 명령어를 수행하여 kubeflow namespace의 모든 pod가 정상적인지 확인한다.
        ```bash
        $ kubectl get pod -n kubeflow
        ```
    * 만약 아래 두 pod가 Running 상태가 아니라면 katib-mysql이라는 PVC의 mount에 문제가 있는 것이다.
        * katib-db-manager-...
        * katib-mysql-...
    * 아래 명령어 수행하여 PVC를 재생성한다.
        ```bash
        $ VOLUME_NAME=$(kubectl get pvc katib-mysql -n kubeflow -o yaml |grep volumeName |cut -c 15-)
        $ kubectl delete pvc katib-mysql -n kubeflow
        $ cat > katib-mysql.yaml <<EOF
        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
          labels:
            app.kubernetes.io/component: katib
            app.kubernetes.io/instance: katib-controller-0.10.0
            app.kubernetes.io/managed-by: kfctl
            app.kubernetes.io/name: katib-controller
            app.kubernetes.io/part-of: kubeflow
            app.kubernetes.io/version: 0.10.0
          name: katib-mysql
          namespace: kubeflow
        spec:
          accessModes:
          - ReadWriteOnce
          resources:
            requests:
              storage: 10Gi
          storageClassName: csi-cephfs-sc
          volumeMode: Filesystem
          volumeName: ${VOLUME_NAME}
        EOF
        $ kubectl apply -f katib-mysql.yaml
        ```
    * 모든 pod의 상태가 정상이라면 KFServing과 Istio 1.5.1과의 호환을 위해 아래 명령어를 수행하여 Istio의 mTLS 기능을 disable한다.
        ```bash
        $ echo '{"apiVersion":"security.istio.io/v1beta1","kind":"PeerAuthentication","metadata":{"annotations":{},"name":"default","namespace":"istio-system"},"spec":{"mtls":{"mode":"DISABLE"}}}' |cat > disable-mtls.json
        $ kubectl apply -f disable-mtls.json
        ```
## 기타 : kubeflow 삭제
* 목적 : `kubeflow 설치 시에 배포된 모든 리소스를 삭제 한다.`
* 생성 순서 : 
    * 아래 명령어를 수행하여 kubeflow 모듈을 삭제한다.
        ```bash
        $ export CONFIG_URI="https://raw.githubusercontent.com/tmax-cloud/kubeflow-manifests/kubeflow-manifests-v1.0.2/kfctl_hypercloud_kubeflow.v1.0.2.yaml"
        $ kfctl delete -V -f ${CONFIG_URI}
        ```
* 비고 :
    * kfctl 1.1버전 이상부터 리소스의 삭제가 정상적으로 이루어진다. kfctl 버전은 다음명령어를 통해 확인할 수 있다.
        ```bash
        $ kfctl version
        ```
## 기타2 : HyperCloud4.1 kubeflow Spec 정보
|    **Namespace**    |                   **Pod**                   |          **Container**          | Request<br/>(CPU) | **Request**<br/>(Memory) | **Limit**<br/>(CPU) | **Limit<br/>(Memory)** |             **Container 이미지<br/> IMAGE:TAG**              |
| :-----------------: | :-----------------------------------------: | :-----------------------------: | :---------------: | :----------------------: | :-----------------: | :--------------------: | :----------------------------------------------------------: |
|    **kubeflow**     |         admission-webhook-bootstrap         |            bootstrap            |        20m        |          100Mi           |          1          |          1Gi           |      gcr.io/kubeflow-images-public/ingress-setup:latest      |
|                     |        admission-webhook-deployment         |        admission-webhook        |        20m        |           20Mi           |          1          |         200Mi          | gcr.io/kubeflow-images-public/admission-webhook:v1.0.0-gaf96e4e3 |
|                     |           application-controller            |             manager             |        70m        |          200Mi           |          1          |          2Gi           | gcr.io/kubeflow-images-public/kubernetes-sigs/application:1.0-beta |
|                     |                   argo-ui                   |             argo-ui             |        20m        |          200Mi           |          1          |          2Gi           |                   argoproj/argocli:v2.8.0                    |
|                     |              centraldashboard               |        centraldashboard         |        20m        |          400Mi           |          1          |          4Gi           | gcr.io/kubeflow-images-public/centraldashboard:v1.0.0-g3ec0de71 |
|                     |         jupyter-web-app-deployment          |         jupyter-web-app         |        20m        |          400Mi           |          1          |          4Gi           | gcr.io/kubeflow-images-public/jupyter-web-app:v1.0.0-g2bd63238 |
|                     |            **katib-controller**             |        katib-controller         |        30m        |          400Mi           |          1          |          4Gi           | gcr.io/kubeflow-images-public/katib/v1alpha3/katib-controller:v0.8.0 |
|                     |            **katib-db-manager**             |        katib-db-manager         |        20m        |          100Mi           |          1          |          2Gi           | gcr.io/kubeflow-images-public/katib/v1alpha3/katib-db-manager:v0.8.0 |
|                     |               **katib-mysql**               |           katib-mysql           |         1         |           2Gi            |          1          |          4Gi           |                           mysql:8                            |
|                     |                  katib-ui                   |            katib-ui             |        20m        |          100Mi           |          1          |          1Gi           | gcr.io/kubeflow-images-public/katib/v1alpha3/katib-ui:v0.8.0 |
|                     |      **kfserving-controller-manager**       |             manager             |     **100m**      |        **200Mi**         |      **100m**       |       **300Mi**        |         gcr.io/kfserving/kfserving-controller:v0.4.0         |
|                     |                                             |         kube-rbac-proxy         |        10m        |           40Mi           |          1          |         400Mi          |          gcr.io/kubebuilder/kube-rbac-proxy:v0.4.0           |
|                     |               metacontroller                |         metacontroller          |     **500m**      |         **1Gi**          |        **4**        |        **4Gi**         |             metacontroller/metacontroller:v0.3.0             |
|                     |                 metadata-db                 |          db-container           |       100m        |           2Gi            |          1          |          4Gi           |                         mysql:8.0.3                          |
|                     |             metadata-deployment             |            container            |        20m        |          150Mi           |          1          |         1.5Gi          |        gcr.io/kubeflow-images-public/metadata:v0.1.11        |
|                     |          metadata-envoy-deployment          |            container            |        20m        |          150Mi           |          1          |         1.5Gi          |            gcr.io/ml-pipeline/envoy:metadata-grpc            |
|                     |          metadata-grpc-deployment           |            container            |        20m        |           20Mi           |          1          |         200Mi          |    gcr.io/tfx-oss-public/ml_metadata_store_server:v0.21.1    |
|                     |                 metadata-ui                 |           metadata-ui           |        20m        |          200Mi           |          1          |          2Gi           |    gcr.io/kubeflow-images-public/metadata-frontend:v0.1.8    |
|                     |                  **minio**                  |              minio              |        20m        |          100Mi           |          1          |          1Gi           |           minio/minio:RELEASE.2018-02-09T22-40-05Z           |
|                     |                 ml-pipeline                 |     ml-pipeline-api-server      |        20m        |          200Mi           |          1          |          2Gi           |             gcr.io/ml-pipeline/api-server:0.2.5              |
|                     | ml-pipeline-ml-pipeline-visualizationserver | ml-pipeline-visualizationserver |        20m        |          400Mi           |          1          |          4Gi           |        gcr.io/ml-pipeline/visualization-server:0.2.5         |
|                     |        ml-pipeline-persistenceagent         |  ml-pipeline-persistenceagent   |        20m        |          100Mi           |          1          |          1Gi           |          gcr.io/ml-pipeline/persistenceagent:0.2.5           |
|                     |        ml-pipeline-scheduledworkflow        |  ml-pipeline-scheduledworkflow  |        20m        |          150Mi           |          1          |         1.5Gi          |          gcr.io/ml-pipeline/scheduledworkflow:0.2.5          |
|                     |               ml-pipeline-ui                |         ml-pipeline-ui          |        20m        |          100Mi           |          1          |          1Gi           |              gcr.io/ml-pipeline/frontend:0.2.5               |
|                     |  ml-pipeline-viewer-controller-deployment   |  ml-pipeline-viewer-controller  |        20m        |          100Mi           |          1          |          1Gi           |        gcr.io/ml-pipeline/viewer-crd-controller:0.2.5        |
|                     |                    mysql                    |              mysql              |       100m        |           2Gi            |          1          |          4Gi           |                          mysql:5.6                           |
|                     |     **notebook-controller-deployment**      |       notebook-controller       |        20m        |          300Mi           |          1          |          3Gi           |          tmaxcloudck/notebook-controller-go:b0.0.2           |
|                     |           **profiles-deployment**           |             manager             |        20m        |          250Mi           |          1          |         2.5Gi          | gcr.io/kubeflow-images-public/profile-controller:v1.0.0-ge50a8531 |
|                     |                                             |              kfam               |        20m        |          250Mi           |          1          |         2.5Gi          |     gcr.io/kubeflow-images-public/kfam:v1.0.0-gf3e09203      |
|                     |            **pytorch-operator**             |        pytorch-operator         |        20m        |          150Mi           |          1          |         1.5Gi          | gcr.io/kubeflow-images-public/pytorch-operator:v1.0.0-g047cf0f |
|                     |          seldon-controller-manager          |             manager             |     **100m**      |         **20Mi**         |      **100m**       |        **30Mi**        |        docker.io/seldonio/seldon-core-operator:1.0.1         |
|                     |         spark-operatorsparkoperator         |          sparkoperator          |        20m        |           2Gi            |          1          |          4Gi           |   gcr.io/spark-operator/spark-operator:v1beta2-1.0.0-2.4.4   |
|                     |             spartakus-volunteer             |            volunteer            |        20m        |          100Mi           |          1          |          1Gi           |       gcr.io/google_containers/spartakus-amd64:v1.1.0        |
|                     |                 tensorboard                 |           tensorboard           |       **1**       |         **1Gi**          |        **4**        |        **4Gi**         |                 tensorflow/tensorflow:1.8.0                  |
|                     |             **tf-job-operator**             |         tf-job-operator         |        20m        |          150Mi           |          1          |         1.5Gi          |  gcr.io/kubeflow-images-public/tf_operator:v1.0.0-g92389064  |
|                     |           **workflow-controller**           |       workflow-controller       |        20m        |          200Mi           |          1          |          2Gi           |             argoproj/workflow-controller:v2.8.0              |
|  **cert-manager**   |                cert-manager                 |          cert-manager           |      **10m**      |         **32Mi**         |          1          |         320Mi          |       quay.io/jetstack/cert-manager-controller:v0.11.0       |
|                     |           cert-manager-cainjector           |           cainjector            |        20m        |          200Mi           |          1          |          2Gi           |       quay.io/jetstack/cert-manager-cainjector:v0.11.0       |
|                     |            cert-manager-webhook             |          cert-manager           |        20m        |           20Mi           |          1          |         200Mi          |        quay.io/jetstack/cert-manager-webhook:v0.11.0         |
| **knative-serving** |                **activator**                |            activator            |     **400m**      |        **188Mi**         |        **3**        |       **1624Mi**       | gcr.io/knative-releases/knative.dev/serving/cmd/activator@sha256:8e606671215cc029683e8cd633ec5de9eabeaa6e9a4392ff289883304be1f418 |
|                     |               **autoscaler**                |           autoscaler            |     **130m**      |        **168Mi**         |      **2300m**      |       **1424Mi**       | gcr.io/knative-releases/knative.dev/serving/cmd/autoscaler@sha256:ef1f01b5fb3886d4c488a219687aac72d28e72f808691132f658259e4e02bb27 |
|                     |             **autoscaler-hpa**              |         autoscaler-hpa          |     **100m**      |        **100Mi**         |        **1**        |       **1000Mi**       | gcr.io/knative-releases/knative.dev/serving/cmd/autoscaler-hpa@sha256:5e0fadf574e66fb1c893806b5c5e5f19139cc476ebf1dff9860789fe4ac5f545 |
|                     |               **controller**                |           controller            |     **100m**      |        **100Mi**         |        **1**        |       **1000Mi**       | gcr.io/knative-releases/knative.dev/serving/cmd/controller@sha256:5ca13e5b3ce5e2819c4567b75c0984650a57272ece44bc1dabf930f9fe1e19a1 |
|                     |            **networking-istio**             |        networking-istio         |     **100m**      |        **100Mi**         |        **1**        |       **1000Mi**       | gcr.io/knative-releases/knative.dev/serving/cmd/networking/istio@sha256:727a623ccb17676fae8058cb1691207a9658a8d71bc7603d701e23b1a6037e6c |
|                     |                 **webhook**                 |             webhook             |      **20m**      |         **20Mi**         |      **200m**       |       **200Mi**        | gcr.io/knative-releases/knative.dev/serving/cmd/webhook@sha256:1ef3328282f31704b5802c1136bd117e8598fd9f437df8209ca87366c5ce9fcb |
|  **istio-system**   |          **cluster-local-gateway**          |           istio-proxy           |      **10m**      |           40Mi           |          1          |         128Mi          |                docker.io/istio/proxyv2:1.5.1                 |
|                     |        **kfserving-ingressgateway**         |           istio-proxy           |      **10m**      |         **40Mi**         |      **100m**       |       **128Mi**        |                docker.io/istio/proxyv2:1.5.1                 |
