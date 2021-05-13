
# ai-devops 설치 가이드
* 폐쇄망과 인터넷 연결망에서의 설치가 완전히 분리되어 가이드되어 있으니 참고한다.

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
4. Cert-manager
    * ai-devops에서 사용하는 certificate와 cluster-issuer와 같은 CR 관리를 위해 필요하다.        
6. (Optional) GPU plug-in
    * Kubernetes cluster 내 node에 GPU가 탑재되어 있으며 AI DevOps 기능을 사용할 때 GPU가 요구될 경우에 필요하다.
        * https://github.com/tmax-cloud/install-nvidia-gpu-infra/blob/5.0/README.md        

## 폐쇄망 설치 install step
0. [git clone 및 image 저장](https://github.com/tmax-cloud/install-ai-devops/tree/kt-patch#step-0-git-clone-%EB%B0%8F-image-%EC%A0%80%EC%9E%A5)
1. [OLM 및 kubeflow-operator 설치](https://github.com/tmax-cloud/install-ai-devops/tree/kt-patch#step-1-olm-%EB%B0%8F-kubeflow-operator-%EC%84%A4%EC%B9%98)
2. [Subscription 리소스 배포](https://github.com/tmax-cloud/install-ai-devops/tree/kt-patch#step-2-subscription-%EB%A6%AC%EC%86%8C%EC%8A%A4-%EB%B0%B0%ED%8F%AC)
3. [kubeflow-operator 배포](https://github.com/tmax-cloud/install-ai-devops/tree/kt-patch#step-3-kubeflow-operator-%EB%B0%B0%ED%8F%AC)
4. [kubeflow 배포](https://github.com/tmax-cloud/install-ai-devops/tree/kt-patch#step-4-kubeflow-%EB%B0%B0%ED%8F%AC)
5. [배포 확인 및 기타 작업](https://github.com/tmax-cloud/install-ai-devops/tree/kt-patch#step-5-%EB%B0%B0%ED%8F%AC-%ED%99%95%EC%9D%B8-%EB%B0%8F-%EA%B8%B0%ED%83%80-%EC%9E%91%EC%97%85)

## Step 0. git clone 및 image 저장
   * 아래 링크를 참고하여 폐쇄망에서 사용할 registry를 구축한다.
   * https://github.com/tmax-cloud/install-registry/blob/5.0/README.md
   * 자신이 사용할 registry의 IP와 port를 입력한다.
      ```bash
      $ export REGISTRY_ADDRESS=XXX.XXX.XXX.XXX:XXXX (e.g.192.168.6.181:5000)
      ```
   * 아래 명령어를 수행하여 clone을 수행하고, Kubeflow 설치 시 필요한 이미지들을 위에서 구축한 registry에 push하고 이미지들을 tar 파일로 저장한다. tar 파일은 images 디렉토리에 저장된다.
      ```bash         
      $ git clone -b 5.0 https://github.com/tmax-cloud/install-ai-devops.git 
      $ cd install-ai-devops
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
## Step 1. OLM 및 kubeflow-operator 설치
   * 다음 git repository(https://github.com/tmax-cloud/install-OLM/blob/main/README.md) 폐쇄망 구축가이드를 참고하여 olm과 kubeflow-operator를 설치한다. 
   * 단, 위 레포지토리의 폐쇄망 구축가이드 3번 부터는 install-ai-devops 의 private 디렉토리를 이용하여 아래 명령어를 통해 진행한다.
   * 반드시 레포지토리의 폐쇄망 구축가이드 2번까지 진행후 밑단의 설치가이드를 통해 crd와 OLM까지 설치후 진행한다.
   * 먼저 아래 명령어를 통해 kubeflow-operator의 manifest(CRD, CSV를 관리하는 Catalog Registry image를 빌드하고 푸시한다.
      ```bash
      $ export REGISTRY_ADDRESS=XXX.XXX.XXX.XXX:XXXX (e.g.192.168.6.181:5000)
      $ cd private
      $ cp bin/* /bin/
      $ sed -i 's/{registry}/'${REGISTRY_ADDRESS}'/g' catalog_build.sh
      $ sed -i 's/{registry}/'${REGISTRY_ADDRESS}'/g' kubeflow/csv.yaml
      $ sh catalog_build.sh
      ```
   * Operator POD 내에서 사용하는 container 이미지를 폐쇄망 registry에 푸시한다.
      ```bash
      $ sh image_kubeflow.sh
      ```
   * OLM 환경에 Custom Catalog를 배포한다. 
      ```bash
      $ sed -i 's/{registry}/'${REGISTRY_ADDRESS}'/g' custom_catalogsource.yaml
      $ kubectl apply -f custom_catalogsource.yaml      
      ```    
## Step 2. Subscription 리소스 배포
   * 해당 Custom Catalog 내에 kubeflow-operator를 설치하기 위해 subscription 리소스를 배포한다.
      ```bash
      $ cd ..
      $ kubectl kubeflow_subscription.yaml
      ```
   * 설치되기까지 시간이 10분가량 소요될 수 있으며 정상적으로 완료되었는지 확인하기 위해 아래 명령어를 수행하여 kubeflow operator pod의 정상 동작을 확인한다.
      ```bash
      $ kubectl get pod -n operators
      ```
      ![스크린샷, 2021-04-14 11-55-55](https://user-images.githubusercontent.com/77767091/114647647-69848300-9d18-11eb-92ac-ec543473c16c.png) 
## Step 3. kubeflow-operator 배포
   * 해당 Custom Catalog 내에 kubeflow-operator를 설치하기 위해 subscription 리소스를 배포한다.
      ```bash
      $ cd ..
      $ kubectl kubeflow_subscription.yaml
      ```
   * 설치되기까지 시간이 10분가량 소요될 수 있으며 정상적으로 완료되었는지 확인하기 위해 아래 명령어를 수행하여 kubeflow operator pod의 정상 동작을 확인한다.
      ```bash
      $ kubectl get pod -n operators
      ```
      ![스크린샷, 2021-04-14 11-55-55](https://user-images.githubusercontent.com/77767091/114647647-69848300-9d18-11eb-92ac-ec543473c16c.png)
## Step 4. kubeflow 배포
   * kfdef CR을 이용하여 kubeflow를 배포한다. 먼저 설치 디렉토리를 생성하고 그 안에 앞서 다운받은 ai-devops-5.0.tar.gz 파일을 이동시킨 후 압축을 해제한다.
   * 압축 해제된 yaml 파일들에서 이미지를 pull 받을 레지스트리를 변경한다.
   * kfDef-hypercloud_local.yaml의 {repos_address} 부분을 변경하고 kubeflow namespace와 kfdef를 생성하여 kubeflow를 배포한다.
   * ${KF_DIR}이 설치 디렉토리이며 ${KF_NAME}, ${BASE_DIR}은 임의로 변경 가능하다. 
      ```bash
      $ export KF_NAME=ai-devops
      $ export BASE_DIR=/home/${USER}
      $ export KF_DIR=${BASE_DIR}/${KF_NAME}
      $ mkdir -p ${KF_DIR}
      $ tar xvfz ai-devops-5.0.tar.gz (이 명령어 실행전 생성한 디렉토리로 ai-devops-5.0.tar.gz 파일을 이동시킨다.)
      $ export REPOS_ADDRESS=현재디렉토리경로/ai-devops-5.0 (pwd 명령어를 통해 현재 디렉토리 경로 부분을 채워넣는다. e.g /home/ck/ai-devops/ai-devops-5.0)
      $ sed -i 's/{repos_address}/'${REPOS_ADDRESS}'/g' kfDef-hypercloud_local.yaml
      $ KUBEFLOW_NAMESPACE=kubeflow
      $ kubectl create ns ${KUBEFLOW_NAMESPACE}
      $ kubectl create -f kfDef-hypercloud_local.yaml -n ${KUBEFLOW_NAMESPACE}      
      ```
## Step 5. 배포 확인 및 기타 작업
* 목적 : `Kubeflow 배포를 확인하고 문제가 있을 경우 정상화한다.`
* 생성 순서 : 
    * 아래 명령어를 수행하여 kubeflow namespace의 모든 pod가 정상적인지 확인한다.
        ```bash
        $ kubectl get pod -n kubeflow
        ```
    * 모든 pod의 상태가 정상이라면 KFServing과 Istio 1.5.1과의 호환을 위해 아래 명령어를 수행하여 Istio의 mTLS 기능을 disable한다.
        ```bash
        $ echo '{"apiVersion":"security.istio.io/v1beta1","kind":"PeerAuthentication","metadata":{"annotations":{},"name":"default","namespace":"istio-system"},"spec":{"mtls":{"mode":"DISABLE"}}}' |cat > disable-mtls.json
        $ kubectl apply -f disable-mtls.json
        ```      

## Install Steps
0. [olm 설치](https://github.com/tmax-cloud/install-ai-devops/tree/kt-patch#step-0-olm-%EC%84%A4%EC%B9%98)
1. [kubeflow operator 설치](https://github.com/tmax-cloud/install-ai-devops/tree/kt-patch#step-1-kubeflow-operator-%EC%84%A4%EC%B9%98)
2. [설치 디렉토리 생성](https://github.com/tmax-cloud/install-ai-devops/tree/kt-patch#step-2-%EC%84%A4%EC%B9%98-%EB%94%94%EB%A0%89%ED%86%A0%EB%A6%AC-%EC%83%9D%EC%84%B1)
3. [Kubeflow 배포](https://github.com/tmax-cloud/install-ai-devops/tree/kt-patch#step-3-kubeflow-%EB%B0%B0%ED%8F%AC)
4. [배포 확인 및 기타 작업](https://github.com/tmax-cloud/install-ai-devops/tree/kt-patch#step-4-%EB%B0%B0%ED%8F%AC-%ED%99%95%EC%9D%B8-%EB%B0%8F-%EA%B8%B0%ED%83%80-%EC%9E%91%EC%97%85)

## Step 0. OLM 설치
* 목적 : `kubeflow operator를 관리하기 위한 toolkit으로 사용한다.`
* 생성 순서 : 다음 Git Repository/가이드를 참고하여 OLM을 설치한다.
            https://github.com/tmax-cloud/install-OLM/blob/main/README.md   

## Step 1. kubeflow operator 설치
* 목적 : `Kubeflow operator는 kubeflow를 배포하고 모니터링 하는 등 lifecycle을 관리한다.`
* 생성 순서 : 
    * 아래 명령어를 실행하여 kubeflow operator를 생성한다.
        ```bash
        $ kubectl create -f https://operatorhub.io/install/kubeflow.yaml
        ```
    * 설치되기까지 시간이 10분가량 소요될 수 있으며 정상적으로 완료되었는지 확인하기 위해 아래 명령어를 수행하여 kubeflow operator pod의 정상 동작을 확인한다.
        ```bash
        $ kubectl get pod -n operators
        ```
      ![스크린샷, 2021-04-14 11-55-55](https://user-images.githubusercontent.com/77767091/114647647-69848300-9d18-11eb-92ac-ec543473c16c.png)  
                
## Step 2. 설치 디렉토리 생성
* 목적 : `kfDef configuration yaml이 저장될 설치 디렉토리를 생성하고 해당 경로로 이동한다.`
* 생성 순서 : 
    * 아래 명령어를 수행하여 설치 디렉토리를 생성하고 해당 경로로 이동한다.
        ```bash
        $ export KF_NAME=
        $ export BASE_DIR=/home/${USER}
        $ export KF_DIR=${BASE_DIR}/${KF_NAME}
        $ mkdir -p ${KF_DIR}
        $ cd ${KF_DIR}
        ```
    * ${KF_DIR}이 설치 디렉토리이며 ${KF_NAME}, ${BASE_DIR}은 임의로 변경 가능하다.
   
## Step 3. Kubeflow 배포
* 목적 : `앞서 설치한 kubeflow operator를 통해 Kubeflow를 배포한다.`
* 생성 순서 : 
    * kubeflow operator는 kfDef를 CR로 사용하기 때문에 아래 명령어를 수행하여 kfDef configuration을 repository에서 다운로드한다.
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
    * 위 명령어중 yq는 https://github.com/mikefarah/yq 를 참고하여 설치하거나 그렇지 않을 경우 다음 명령어를 사용한다.
        ```bash
        $ perl -pi -e $'s@metadata:@metadata:\\\n  name: '"${KUBEFLOW_DEPLOYMENT_NAME}"'@' ${KFDEF}        
        ```
    * 아래 명령어를 통해 namespace를 생성하고 kfDef CR을 생성하여 kubeflow를 배포한다.
        ```bash
        $ KUBEFLOW_NAMESPACE=kubeflow
        $ kubectl create ns ${KUBEFLOW_NAMESPACE}
        $ kubectl create -f ${KFDEF} -n ${KUBEFLOW_NAMESPACE}
        ```
       
## Step 4. 배포 확인 및 기타 작업
* 목적 : `Kubeflow 배포를 확인하고 문제가 있을 경우 정상화한다.`
* 생성 순서 : 
    * 아래 명령어를 수행하여 kubeflow namespace의 모든 pod가 정상적인지 확인한다.
        ```bash
        $ kubectl get pod -n kubeflow
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
        $ kubectl delete kfdef kubeflow -n kubeflow
        ```

