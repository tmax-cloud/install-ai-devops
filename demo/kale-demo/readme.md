# kale demo

## profile 생성

```yaml
apiVersion: kubeflow.org/v1
kind: Profile
metadata:
  name: kaledemo
spec:
  owner:
    kind: User
    name: anonymous@kubeflow.org
  resourceQuotaSpec: {}
```

## kale notebook 생성

- 필요하다면 image는 다른 것으로 바꾼다. (예: jupyterlab-kale:b1.0.0 대신 jupyterlab-kale:torch, jupyterlab-kale:titanic 사용)
- 필요하다면 image pull secret을 추가하고, katib-controller의 service account에도 image pull secret을 추가한다.
  - 단, 이 경우 kale compile and run 시에 생성되는 pod에서 image pull secret이 적용되지 않을 수도 있다.

```yaml
apiVersion: kubeflow.tmax.io/v1
kind: Notebook
metadata:
  labels:
    app: kaledemo-notebook
  name: kaledemo-notebook
  namespace: kaledemo
spec:
  template:
    spec:
      containers:
      - image: 'docker.io/tmaxcloudck/jupyterlab-kale:b1.0.0'
        imagePullPolicy: Always
        name: kaledemo
        resources:
          requests:
            cpu: "0.5"
            memory: 1.0Gi
        volumeMounts:
        - mountPath: /home/jovyan
          name: kaledemo-pvc
        - mountPath: /dev/shm
          name: dshm
      serviceAccountName: default-editor
      volumes:
      - name: kaledemo-pvc
        persistentVolumeClaim:
          claimName: kaledemo-pvc
      - emptyDir:
          medium: Memory
        name: dshm
  volumeClaim:
  - name: kaledemo-pvc
    size: 10Gi
```

## kale notebook에서 코드 테스트, compile and run

```terminal
git clone https://github.com/kubeflow-kale/examples
(혹은, 다른 git repository를 clone한다.)
```

- ipynb 코드 테스트 후 kale panel을 열고, advanced settings에서 image를 입력하고, compile and run을 한다.
  - 이 image는 kale 기반 이미지여야 하고, 코드 실행에 필요한 모든 package가 설치되어 있어야 한다.
  - image를 새로 만들 경우 아래 Dockerfile을 참고하되, docker 환경에서 build, push하는 것이 권장된다.
    - podman에서 build하는 경우 일부 step에서 실패할 수 있다.

    ```Dockerfile
    FROM docker.io/tmaxcloudck/jupyterlab-kale:b1.0.0
    USER root
    WORKDIR /kale/backend
    RUN pip3 install "torch"
    RUN pip3 install "torchvision"
    (혹은, 다른 필요한 python package들을 설치한다.)
    ```

## console에서 확인

- pipeline run 메뉴에서 log를 확인한다.

## 주의사항

- kale panel에서 compile and run을 재시도하는 경우, 그전에 연관된 pipeline run, pipeline, task run, task, pvc를 모두 삭제하고 잠시 기다린다.
- notebook을 재생성하려는 경우, 그전에 기존 notebook과 pvc를 모두 삭제하고 잠시 기다린다.
