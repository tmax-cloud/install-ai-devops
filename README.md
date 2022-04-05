
# ai-devops 설치 가이드

## 구성 요소 및 버전
* Kubeflow v1.2.0 (https://github.com/kubeflow/kubeflow)
* Jupyter (https://github.com/jupyter/notebook)
* Katib v0.11.0 (https://github.com/kubeflow/katib)
* KFServing v0.5.1 (https://github.com/kubeflow/kfserving)
* Training Job
    * TFJob v1.0.0 (https://github.com/kubeflow/tf-operator)
    * PytorchJob v1.0.0 (https://github.com/kubeflow/pytorch-operator)
* Notebook-controller b0.2.1 (https://github.com/tmax-cloud/notebook-controller-go)
* ...

## Prerequisites
1. Storage class
    * 아래 명령어를 통해 storage class가 설치되어 있는지 확인한다.
        ```bash
        $ kubectl get storageclass
        ```
    * 만약 storage class가 없다면 storage class를 설치해준다.
    * Storage class는 있지만 default로 설정된 것이 없다면 아래 명령어를 실행한다.(storage class로 rook-ceph이 설치되어 있을 경우에만 해당)
        ```bash
        $ kubectl patch storageclass csi-cephfs-sc -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
        ```
    * csi-cephfs-sc는 rook-ceph를 설치했을 때 생성되는 storage class이며 다른 storage class를 default로 사용해도 무관하다.
2. Istio
    * v1.5.1
        * https://github.com/tmax-cloud/install-istio/blob/5.0/README.md
3. Cert-manager
    * ai-devops에서 사용하는 certificate와 cluster-issuer와 같은 CR 관리를 위해 필요하다.         
        * https://github.com/tmax-cloud/install-cert-manager/blob/main/README.md
4. (Optional) GPU plug-in
    * Kubernetes cluster 내 node에 GPU가 탑재되어 있으며 AI DevOps 기능을 사용할 때 GPU가 요구될 경우에 필요하다.
        * https://github.com/tmax-cloud/install-nvidia-gpu-infra/blob/5.0/README.md   


## 폐쇄망 설치 가이드
설치를 진행하기 전 아래의 과정을 통해 필요한 이미지 및 yaml 파일을 준비한다.
1. 이미지 준비
    * 아래 링크를 참고하여 폐쇄망에서 사용할 registry를 구축한다.
        *  https://github.com/tmax-cloud/install-registry/blob/5.0/README.md
    * 자신이 사용할 registry의 IP와 port를 입력한다.
        ```bash
        $ export REGISTRY_ADDRESS=192.168.9.216:5000
        ```
    * 아래 명령어를 수행하여 Kubeflow 설치 시 필요한 이미지들을 위에서 구축한 registry에 push하고 이미지들을 tar 파일로 저장한다. tar 파일은 images 디렉토리에 저장된다.
        ```bash
        $ wget https://raw.githubusercontent.com/tmax-cloud/install-ai-devops/5.1/image-push.sh
        $ wget https://raw.githubusercontent.com/tmax-cloud/install-ai-devops/5.1/imagelist
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
           $ wget https://raw.githubusercontent.com/tmax-cloud/install-ai-devops/5.1/image-save.sh
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
    * AI-devops 설치와 삭제에 필요한 manifest/ 디렉토리의 모든 파일을 다운로드 받는다.
3. 앞으로의 진행
    * Step 0 ~ 6 중 Step 0, 2, 3, 5, 6은 비고를 참고하여 진행한다. 나머지는 그대로 진행하면 된다.

## Install Steps
0. [HyperAuth 연동](https://github.com/tmax-cloud/install-ai-devops/tree/5.1#step-0-hyperauth-%EC%97%B0%EB%8F%99)
1. [ai-devops.config 설정](https://github.com/tmax-cloud/install-ai-devops/tree/5.1#step-1-ai-devopsconfig-%EC%84%A4%EC%A0%95)
2. [installer 실행](https://github.com/tmax-cloud/install-ai-devops/tree/5.1#step-2-installer-%EC%8B%A4%ED%96%89)
3. [배포 확인 및 기타 작업](https://github.com/tmax-cloud/install-ai-devops/tree/5.1#step-3-%EB%B0%B0%ED%8F%AC-%ED%99%95%EC%9D%B8-%EB%B0%8F-%EA%B8%B0%ED%83%80-%EC%9E%91%EC%97%85)

## Step 0. HyperAuth 연동
* 목적 : `Notebook과 Hyperauth 연동을 통해 OIDC 인증관리를 적용한다.`
* 생성 순서 : 
    * HyperAuth에서 Client를 생성하고 관련 설정을 진행한다. Client가 이미 생성되어있는 경우에는 생성단계를 건너뛰고 config 수정 단계부터 진행한다.
        * hyperauth에서 client 생성    
            * Client ID = notebook-gatekeeper           
            * Client protocol = openid-connect
            * Access type = confidential        
            * Valid Redirect URIs: '*'
        * Client > notebook-gatekeeper > Credentials > client_secret 확인
        * Client > notebook-gatekeeper > Roles > add role로 'notebook-gatekeeper-manager' role 생성
        * Client > notebook-gatekeeper > Mappers > create로 mapper 생성
            * Name = notebook-gatekeeper
            * Mapper Type = Audience
            * Included Client Audience = notebook-gatekeeper
        * notebook을 사용하고자 하는 사용자의 계정의 Role Mappings 설정에서 notebook-gatekeeper-manager Client role을 할당한다.       

## Step 1. ai-devops.config 설정
* 목적 : `manifest/ai-devops.config 파일에 설치에 필요한 환경 정보를 작성한다.`
* 생성 순서 : ai-devops가 설치되는 환경에 따라 알맞은 config 파일을 작성한다.        
    * CLIENT_SECRET = 위의 단계에서 확인한 notebook-gatekeeper 클라이언트의 시크릿 값 EX) bac5oef-d3fjief-gjeifsjle-dj457f
    * DISCOVERY_URL = https://{{HyperAuth_URL}}/auth/realms/tmax
        * {{HyperAuth_URL}} 부분에 환경에 맞는 하이퍼어쓰 주소를 입력한다.
        * EX) https://hyperauth.tmaxcloud.org/auth/realms/tmax
    * CUSTOM_DOMAIN = 인그레스로 접근할수 있도록 환경에 맞는 커스텀 도메인 주소를 입력한다. EX) tmaxcloud.org
    * REGISTRY = 폐쇄망 설치시 앞서 설치한 Image repository 주소
        * 중요) 설치 환경이 폐쇄망이 아닐시 {REGISTRY} 값을 수정하지 않는다.
        * EX) 172.2.2.6:5000
* 비고
    * 재강조) 폐쇄망 환경일 경우 {REGISTRY} 값을 수정하지 않는다.         

## Step 2. Installer 실행
* 목적 : `AI-devops 설치를 위한 스크립트를 실행한다.`
* 생성 순서 : 
    * 아래 명령어를 수행하여 인스톨러에 권한을 부여하고 실행한다.
        ```bash
        $ sudo chmod +x manifest/install-ai-devops.sh        
        $ ./manifest/install-ai-devops.sh
        ```   
   
## Step 3. 배포 확인 및 기타 작업
* 목적 : `AI-devops 배포를 확인하고 문제가 있을 경우 정상화한다.`
* 생성 순서 : 
    * 아래 명령어를 수행하여 kubeflow namespace와 knative-serving namespace의 모든 pod가 정상적인지 확인한다.
        ```bash
        $ kubectl get pod -n kubeflow
        $ kubectl get pod -n knative-serving
        ```
    * katib-db-manager와 katib-mysql pod만 running 상태가 아니라면 10분가량 시간을 두고 기다리면 running 상태도 바뀔 가능성이 높음 (내부 liveness probe 로직 문제로 여러번 restarts)  
* 참고 :
    * KFServing과 Istio 1.5.1과의 호환을 위해 istio namespace의 mtls를 disable처리 하였음.    

## 기타1 : AI-devops 삭제
* 목적 : `AI-devops 설치 시에 배포된 모든 리소스를 삭제 한다.`
* 생성 순서 : 
    * 아래 명령어를 수행하여 AI-devops 모듈을 삭제한다.
        ```bash
        $ sudo chmod +x manifest/uninstall-ai-devops.sh
        $ ./manifest/install-ai-devops.sh
        ```

  
## 기타2 : HyperCloud5.1 ai-devops Spec 정보
|Namespace|Pod|Container 수|Container|Container image|Request| |Limit| |
|:----|:----|:----|:----|:----|:----|:----|:----|:----|
| | | | | |cpu|memory|cpu|memory|
|istio-system|cluster-local-gateway|1|istio-proxy|istio/proxyv2:1.3.1|10m|40Mi|1|128Mi|
|kubeflow|application-controller|1|manager|gcr.io/kubeflow-images-public/kubernetes-sigs/application:1.0-beta|70m|200Mi|1|2Gi|
| |katib-controller|1|katib-controller|docker.io/kubeflowkatib/katib-controller:v0.11.0|30m|400Mi|1|4Gi|
| |katib-db-manager|1|katib-db-manager|docker.io/kubeflowkatib/katib-db-manager:v0.11.0|20m|100Mi|1|2Gi|
| |katib-mysql|1|katib-mysql|mysql:8.0.27|1|2Gi|1|4Gi|
| |katib-ui|1|katib-ui|docker.io/kubeflowkatib/katib-ui:v0.11.0|20m|100Mi|1|1Gi|
| |kfserving-controller-manager|2|manager|gcr.io/kfserving/kfserving-controller:v0.5.1|100m|200Mi|100m|300Mi|
| | | |kube-rbac-proxy|gcr.io/kubebuilder/kube-rbac-proxy:v0.4.0|10m|40Mi|1|400Mi|
| |minio|1|minio|gcr.io/ml-pipeline/minio:RELEASE.2019-08-14T20-37-41Z-license-compliance|20m|100Mi|1|1Gi|
| |notebook-controller-deployment|1|notebook-controller|tmaxcloudck/notebook-controller-go:b0.1.0|20m|300Mi|1|3Gi|
| |profiles-deployment|2|manager|gcr.io/kubeflow-images-public/profile-controller:vmaster-ga49f658f|20m|250Mi|1|2.5Gi|
| | | |kfam|gcr.io/kubeflow-images-public/kfam:vmaster-g9f3bfd00|20m|250Mi|1|2.5Gi|
| |pytorch-operator|1|pytorch-operator|gcr.io/kubeflow-images-public/pytorch-operator:vmaster-g518f9c76|20m|150Mi|1|1.5Gi|
| |tf-job-operator|1|tf-job-operator|gcr.io/kubeflow-images-public/tf_operator:vmaster-gda226016|20m|150Mi|1|1.5Gi|
|knative-serving|activator|1|activator|gcr.io/knative-releases/knative.dev/serving/cmd/activator:v0.14.3|300m|60Mi|1000m|600Mi|
| |autoscaler|1|autoscaler|gcr.io/knative-releases/knative.dev/serving/cmd/autoscaler:v0.14.3|30m|40Mi|300m|400Mi|
| |istio-webhook|1|webhook|gcr.io/knative-releases/knative.dev/net-istio/cmd/webhook:v0.14.1|20m|20Mi|200m|200Mi|
| |controller|1|controller|gcr.io/knative-releases/knative.dev/serving/cmd/controller:v0.14.3|100m|100Mi|1|1000Mi|
| |networking-istio|1|networking-istio|gcr.io/knative-releases/knative.dev/net-istio/cmd/controller:v0.14.1|30m|40Mi|300|400Mi|
| |webhook|1|webhook|gcr.io/knative-releases/knative.dev/serving/cmd/webhook:v0.14.3|20m|20Mi|200m|200Mi|







