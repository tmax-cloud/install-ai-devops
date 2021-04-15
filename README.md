
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

## Install Steps
0. [olm 설치](https://github.com/tmax-cloud/install-OLM/blob/main/README.md)
1. [kubeflow operator 설치]
2. [설치 디렉토리 생성]
3. [Kubeflow 배포]
4. [배포 확인 및 기타 작업]

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

