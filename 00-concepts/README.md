# 00. Kubernetes 기본 개념

목표: 실습에서 사용할 Kubernetes 리소스의 역할과 서로의 관계를 먼저 이해합니다.

예상 시간: 20분

## 1. Kubernetes가 해결하는 문제

컨테이너를 한두 개 직접 실행할 때는 `docker run`만으로도 충분합니다. 하지만 운영 환경에서는 다음 문제가 생깁니다.

- 컨테이너가 죽으면 누가 다시 띄울 것인가?
- 여러 개 복제본을 어떻게 균등하게 배치할 것인가?
- 새 버전을 어떻게 중단 없이 배포할 것인가?
- Pod IP가 계속 바뀌는데 사용자는 어디로 접속할 것인가?
- 환경별 설정값과 비밀번호를 이미지 안에 넣지 않으려면 어떻게 할 것인가?

Kubernetes는 이런 문제를 선언형 리소스와 컨트롤러로 해결합니다. 사용자는 YAML로 원하는 상태를 선언하고, Kubernetes는 실제 상태가 그 선언에 맞도록 계속 조정합니다.

## 2. 전체 구조

### Cluster

Kubernetes가 애플리케이션을 실행하는 전체 환경입니다. 실습에서는 `minikube`가 로컬 단일 노드 클러스터를 만듭니다.

### Control Plane

클러스터의 두뇌 역할입니다. API 요청을 받고, 리소스 상태를 저장하고, 스케줄링과 컨트롤러 동작을 담당합니다.

주요 구성:

- `kube-apiserver`: `kubectl` 요청을 받는 API 서버
- `etcd`: 클러스터 상태 저장소
- `scheduler`: Pod를 어느 Node에 둘지 결정
- `controller-manager`: Deployment, ReplicaSet 같은 컨트롤러 실행

### Node

실제 컨테이너가 실행되는 머신입니다. minikube에서는 보통 `minikube`라는 Node 1개가 생깁니다.

주요 구성:

- `kubelet`: Node에서 Pod 실행 상태를 관리
- container runtime: Docker/containerd 같은 컨테이너 실행 환경
- `kube-proxy`: Service 네트워킹 처리

## 3. kubectl

`kubectl`은 Kubernetes API 서버와 통신하는 CLI 도구입니다.

자주 쓰는 형태:

```bash
kubectl get <resource>
kubectl describe <resource> <name>
kubectl apply -f <file.yaml>
kubectl delete -f <file.yaml>
kubectl logs <pod-name>
kubectl exec -it <pod-name> -- sh
```

중요한 관점:

- `get`: 현재 상태를 간단히 확인
- `describe`: 이벤트와 상세 상태 확인
- `logs`: 컨테이너 표준 출력 확인
- `apply`: YAML에 선언한 원하는 상태를 클러스터에 반영

## 4. Namespace

Namespace는 하나의 클러스터 안에서 리소스를 논리적으로 나누는 공간입니다.

이번 실습에서는 `k8s-lab` namespace를 만들고 그 안에 리소스를 배치합니다.

```bash
kubectl create namespace k8s-lab
kubectl config set-context --current --namespace=k8s-lab
```

왜 필요한가:

- 팀, 환경, 실습 리소스를 분리할 수 있습니다.
- 같은 이름의 리소스도 namespace가 다르면 공존할 수 있습니다.
- RBAC, ResourceQuota 같은 운영 정책의 기준이 됩니다.

주의:

- Node, PersistentVolume 같은 일부 리소스는 namespace에 속하지 않는 cluster-scoped 리소스입니다.
- Service와 Namespace를 합쳐서 "nameservice"라고 부르지는 않습니다. 실습에서는 Namespace와 Service를 각각 다룹니다.

## 5. Pod

Pod는 Kubernetes에서 배포되는 가장 작은 실행 단위입니다.

특징:

- 보통 컨테이너 1개를 담지만, 필요하면 여러 컨테이너를 함께 담을 수 있습니다.
- Pod 안의 컨테이너들은 같은 네트워크 namespace와 Volume을 공유합니다.
- Pod IP는 Pod가 재생성되면 바뀔 수 있습니다.

직접 Pod를 만드는 예:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
    - name: nginx
      image: nginx:1.25
```

운영에서는 Pod를 직접 관리하기보다 Deployment가 Pod를 만들고 유지하게 합니다.

## 6. Label과 Selector

Label은 리소스에 붙이는 key-value 메타데이터입니다.

```yaml
metadata:
  labels:
    app: web
```

Selector는 label을 기준으로 리소스를 찾는 조건입니다.

```yaml
selector:
  matchLabels:
    app: web
```

이번 실습에서 중요한 연결:

- Deployment는 selector로 자신이 관리할 Pod를 찾습니다.
- Service는 selector로 트래픽을 보낼 Pod를 찾습니다.

Label과 selector가 맞지 않으면 리소스는 만들어져도 트래픽이 가지 않거나 Deployment가 Pod를 제대로 관리하지 못합니다.

## 7. Deployment와 ReplicaSet

Deployment는 Pod 복제본 수와 배포 전략을 관리합니다.

Deployment가 하는 일:

- 원하는 Pod 개수 유지
- Pod가 죽으면 새 Pod 생성
- 이미지 버전 변경 시 rolling update 수행
- 이전 버전으로 rollback 가능

ReplicaSet은 Deployment 아래에서 실제 Pod 복제본 수를 맞추는 리소스입니다. 실무에서는 보통 ReplicaSet을 직접 만들지 않고 Deployment를 사용합니다.

흐름:

```text
Deployment -> ReplicaSet -> Pod
```

예:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: nginx
          image: nginx:1.25
```

## 8. Service

Service는 Pod들 앞에 고정된 네트워크 접속 지점을 만들어 줍니다.

왜 필요한가:

- Pod IP는 바뀔 수 있습니다.
- Pod가 여러 개면 어느 Pod로 보낼지 분산이 필요합니다.
- 클러스터 내부/외부에서 접근할 안정적인 주소가 필요합니다.

주요 타입:

- `ClusterIP`: 클러스터 내부에서만 접근 가능한 기본 타입
- `NodePort`: Node의 특정 포트를 열어 외부에서 접근
- `LoadBalancer`: 클라우드 로드밸런서를 붙여 외부 노출
- `ExternalName`: 외부 DNS 이름에 대한 별칭

이번 실습에서는 `ClusterIP`, `NodePort`, `port-forward`를 다룹니다.

## 9. ConfigMap과 Secret

ConfigMap은 일반 설정값을 이미지 밖에서 주입할 때 씁니다.

예:

- 실행 모드
- 기능 플래그
- 외부 API 주소
- 설정 파일

Secret은 민감 정보를 주입할 때 씁니다.

예:

- API token
- password
- private key

주의:

- Secret은 단순 base64 인코딩 형태로 보일 수 있습니다.
- 운영에서는 RBAC, etcd 암호화, 외부 secret manager 연동까지 고려해야 합니다.

## 10. Volume

컨테이너 파일 시스템은 기본적으로 컨테이너 생명주기와 강하게 묶여 있습니다. Volume은 Pod에 파일 저장 공간이나 설정 파일을 연결할 때 사용합니다.

이번 실습의 `emptyDir`:

- Pod가 생성될 때 비어 있는 디렉터리로 시작합니다.
- 같은 Pod 안에서는 컨테이너 재시작 후에도 유지될 수 있습니다.
- Pod가 삭제되면 데이터도 사라집니다.

영구 저장이 필요하면 `PersistentVolume`과 `PersistentVolumeClaim`을 사용합니다.

## 11. Helm

Helm은 Kubernetes 패키지 매니저입니다.

Kubernetes YAML이 많아지면 다음 문제가 생깁니다.

- Deployment, Service, ConfigMap 등을 한 번에 설치/삭제하고 싶다.
- 환경별 값만 바꿔서 재사용하고 싶다.
- 설치 이력과 rollback을 관리하고 싶다.

Helm은 chart라는 패키지 단위로 YAML 템플릿과 기본값을 묶습니다.

주요 용어:

- Chart: Kubernetes 리소스 템플릿 묶음
- Release: Chart를 클러스터에 설치한 실행 인스턴스
- Values: Chart에 주입하는 설정값
- Repository: Chart 저장소

자주 쓰는 명령:

```bash
helm repo add <name> <url>
helm repo update
helm install <release> <chart>
helm list
helm upgrade <release> <chart>
helm uninstall <release>
```

## 12. 실습 리소스 관계

이번 실습에서 만드는 주요 관계는 다음과 같습니다.

```text
k8s-lab Namespace
  ├─ Deployment/web
  │   └─ ReplicaSet
  │       └─ Pod app=web
  ├─ Service/web-clusterip -> selector app=web
  ├─ Service/web-nodeport  -> selector app=web
  ├─ ConfigMap/app-config
  ├─ Secret/app-secret
  ├─ Deployment/config-demo
  │   └─ Pod app=config-demo
  └─ Helm Release
      └─ chart가 생성한 Kubernetes 리소스
```

이 구조를 먼저 이해하면 뒤의 명령어가 단순 암기가 아니라 "어떤 리소스를 보고 있는지"로 연결됩니다.

## 13. Chaos Engineering

Chaos Engineering은 장애를 일부러 주입해서 시스템이 예상대로 버티고 회복하는지 검증하는 방식입니다. 핵심은 무작정 부수는 것이 아니라, 가설을 세우고 작은 범위에서 통제된 실험을 실행하는 것입니다.

기본 흐름:

```text
정상 상태 정의 -> 가설 수립 -> 작은 장애 주입 -> 관찰 -> 결과 기록 -> 개선
```

예:

- 정상 상태: `web` Deployment의 replicas 3개가 모두 Running이고 Service가 HTTP 200을 반환한다.
- 가설: Pod 1개가 삭제되어도 Deployment가 새 Pod를 만들고 Service는 계속 응답한다.
- 장애 주입: Pod 1개 삭제
- 관찰: Pod 재생성 시간, Service 응답 실패 여부, 이벤트와 로그
- 개선: replicas, readinessProbe, PodDisruptionBudget, autoscaling, alert 조정

처음에는 `kubectl delete pod`로 수동 실험을 해보는 것이 좋습니다. 그 다음 LitmusChaos 같은 도구를 사용하면 동일한 실험을 선언형으로 반복 실행하고 결과를 `ChaosResult` 같은 리소스로 남길 수 있습니다.

주의:

- 운영 환경에서 바로 실행하지 않습니다.
- 실험 대상 namespace와 label selector를 명확히 제한합니다.
- 실험 전에 종료 조건과 rollback 방법을 정합니다.
- 데이터 손실 가능성이 있는 실험은 별도 환경에서 먼저 검증합니다.
