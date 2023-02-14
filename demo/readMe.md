# ai-devops를 사용한 AI 개발 시나리오 가이드

## 시나리오 소개 
  1. Kubeflow-fairing 라이브러리를 활용한 분산 트레이닝 및 서빙 시나리오
  2. Tekton을 활용한 ML pipeline 생성 시나리오
  3. KServe를 활용한 Multi model serving 시나리오
  4. KALE 기본 시나리오
  5. KALE을 활용한 분산 학습 시나리오


### 시나리오에 활용한 AI-DEVOPS 컴포넌트 버전 정보  
  - katib v0.14.0
  - kserve v0.10.0
  - knative-serving v1.2.5
  - training-operator v1.5.0
  - notebook-controller b0.2.8
  - profile-controller v1.6.1
  - cluster-local-gateway v1.14.1
---

### 작업을 위한 namespace 및 notebook 생성(1~3번 시나리오 공통 사항)
  - 4,5번 시나리오는 각 시나리오별 가이드를 참고하여 생성한다.
  1. Profile 생성
  - ai-devops에서는 작업하려는 namespace를 profile이라는 crd를 통해 관리한다.
  - ai-devops 기능을 사용하기 위한 role, rolebinding등의 k8s리소스 배포 뿐만아니라 istio-injection 활성화와 같은 작업을 자동으로 진행한다.
  - UI의 Import YAML 버튼을 활용하여 demo profile을 생성한다. 
![0.profile.PNG](./img/0.profile.PNG) 
  - 참고 : [0.profile.yaml](./0.profile.yaml)

  2. Notebook 생성
  - ai-devops에서는 ML Model 코딩을 위한 web 기반의 python IDE인 JupyterNotebook을 사용할 수 있다.
![1.notebook.PNG](./img/1.notebook.PNG)
  - 참고 : [1.notebook.yaml](./1.notebook.yaml)
  - 폐쇄망 환경의 경우 : [1.notebook_closednw.yaml](./1.notebook_closednw.yaml)
    * 폐쇄망 환경의 경우에는 1.notebook_closednw.yaml 파일의 image registry 부분을 수정한다.(필수)

*시나리오에서는 여러 커스텀 패키지가 포함된 custom jupyterNotebook image를 사용하였다. (brightfly/kubeflow-jupyter-lab:tf2.0-cpu)

*폐쇄망 환경의 경우 시나리오에서 사용되는 파이썬 패키지가 포함되어 있고 fairing 코드가 수정된 custom jupyterNotebook image를 사용하였다. (tmaxcloudck/kubeflow-jupyter-lab:v0.1)

  - 정상적인 배포를 확인하기 위해, action->connect 버튼을 눌러 jupyter진입을 확인하자.

![1.notebook-connect.PNG](./img/1.notebook-connect.PNG)

  - notebook 접속이 정상적으로 완료되면 필요한 파일을 다운로드한 후 1~3번 시나리오를 진행한다.


### 참고1. 리소스 개별 생성 및 상태 조회
  - 1~2번 시나리오에서는 experiment, tfjob, isvc와 같은 개별 리소스를 노트북 서버 내 ipynb을 run하여 생성된 pipelinerun yaml 파일을 배포하여 생성하거나, kubeflow-fairing 라이브러리의 deployer 등을 이용하여 배포하고 있다. 또한 리소스 상태 조회도 client를 통해 노트북 서버에서 진행하고 있다.
  - 각 리소스의 생성이나 상태 조회를 개별적으로 진행하고 싶다면 다음과 같이 하이퍼클라우드 콘솔을 이용한다.

  1. hyper-parameter tuning을 위한 katib 사용하기 (Katib 메뉴)
  - hyper-parameter란 ML 모델 학습에 필요한 컨트롤 변수로, learningRate, dropoutRate, optimizer, neuralNetworkLayerNumber 등이 있다.
  - Katib를 통해 hyper-parameter 값들에 따른 모델 학습의 정확도(Accuracy)를 알 수 있으며, 본격적인 모델 학습에 이 값들이 사용된다.
  - 예시에는 살펴볼 hyper-parameter로 learningRate, dropoutRate를 설정하였다.

![3.katib-experiment.PNG](./img/3.katib-experiment.PNG)
  - 참고 : [3.katib-experiment.yaml](3.katib-experiment.yaml)
  - 모든 작업이 완료된다면, status 항목에서 ML 모델의 정확도가 가장 높은 hyper-parameter를 알려준다.
  - 아래 결과를 해석하자면 validation-accuracy가 최대로 나온 수치는 0.8456이고, 이때의 learningRate는 0.01116... dropoutRate는 0.83610...를 의미한다.

![3.katib-result.PNG](./img/3.katib-result.PNG)

  2. Model 학습을 위한 tfjob 생성하기 (Training Jobs 메뉴)
  - hyper-parameter 탐색까지 끝났다면, 본격적인 Model 학습을 위해 tfJob을 생성한다.
  - Step 3에서 도출된 learningRate와 dropoutRate를 사용하여 모델을 학습한다. (learningRate 0.01116, dropoutRate 0.83610)
  - 시나리오에서는, 모델이 저장될 pvc를 notebook이 사용하는 pvc와 동일한 demo-pvc로 지정하였다.

![4.tfjob.PNG](./img/4.tfjob.PNG)
  - 참고 : [4.tfjob.yaml](4.tfjob.yaml)
  - 학습이 종료되면, pvc에 모델이 저장된다. 시나리오에서는 notebook UI를 통해 생성된 모델을 확인 가능하다.

![4.saved-model.PNG](./img/4.saved-model.PNG)

  3. Model 서빙을 위한 kfserving 사용하기 (KFServing 메뉴)
  - 실제 운영에 쓰일 model을 기반으로 server를 만들고, inference service를 제공한다.

![5.kfserving-inferenceservice.PNG](./img/5.kfserving-inferenceservice.PNG)
  - 참고 : [5.kfserving-inferenceservice.yaml](5.kfserving-inferenceservice.yaml)
  - demo-inferenceservice가 성공적으로 생성되었다면, curl 을 이용하여 inference 응답이 오는지 확인하자. (마스터 노드에서 테스트 진행)
  ```
  MODEL_NAME=demo-inferenceservice
  CLUSTER_IP=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  SERVICE_HOSTNAME=$(kubectl get inferenceservice ${MODEL_NAME} -n demo -o jsonpath='{.status.url}' | cut -d "/" -f 3)
  curl -v -H "Host: ${SERVICE_HOSTNAME}" http://$CLUSTER_IP/v1/models/$MODEL_NAME:predict -d '{
    "instances":[
      {
        "flatten_input":[
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        ]
      }
    ]
  }'
  ```

  - 참고 : [5.demo.sh](5.demo.sh)
  - 아래와 같은 응답이 오게 되는데, 간단하게 해석하자면 inference를 요청한 데이터는 class5(Sandal)일 확률이 0.961이라는 응답이다.

![5.curl.PNG](./img/5.curl.PNG)

*istio-ca-root-cert configmap을 찾지 못하는 에러가 뜬다면, istiod pod를 재부팅하고 진행하며 생성한 모든 리소스를 삭제하고 다시 시도하자.
  

### 참고2. 로컬 개발 환경의 docker registry 인증정보 사용
 - docker에 로그인 되어있는 로컬 개발환경에서 config.json을 복사하여, jupyterNotebook container에 붙여넣는다.
 - 보통 docker registry 인증정보는 로컬개발환경 /root/.docker/config.json 파일을 찾을 수 있다. ( 안나온다면 다음의 위치를 본다. ${HOME}/.docker/config.json )
 - jupyterNotebook에서 터미널을 열어 /home/jovyan/.docker/config.json으로 복사하자

![2.notebook-docker-auth.PNG](./img/2.notebook-docker-auth.PNG)








