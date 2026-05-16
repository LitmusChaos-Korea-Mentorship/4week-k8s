# 02. Service와 네트워킹

목표: Pod IP가 아닌 Service를 통해 애플리케이션에 안정적으로 접속하는 방법을 실습합니다.

예상 시간: 25분

## 1. 개념 정리

Service는 Pod들 앞에 고정된 네트워크 접속 지점을 만들어 줍니다. 이 단계의 핵심은 "Pod IP가 계속 바뀌어도 사용자는 안정적인 주소로 접근할 수 있어야 한다"는 문제를 이해하는 것입니다.

### Pod와 network namespace

Pod 안의 컨테이너들은 같은 network namespace를 공유합니다. 그래서 같은 Pod 안의 컨테이너들은 같은 Pod IP를 사용하고, 서로 `localhost`로 통신할 수 있습니다.

의미:

- 한 컨테이너가 `localhost:8080`에서 뜨면, 다른 컨테이너도 같은 Pod 안에서 `localhost:8080`으로 접근할 수 있습니다.
- 같은 Pod 안에서 두 컨테이너가 같은 포트를 동시에 열 수 없습니다. 예를 들어 두 컨테이너가 모두 `0.0.0.0:8080`을 사용하려 하면 포트 충돌이 납니다.
- Pod 바깥에서 접근할 때는 보통 Pod IP를 직접 쓰지 않고 Service를 사용합니다.

이 구조는 프록시 sidecar에 자주 쓰입니다. 애플리케이션 컨테이너는 `localhost`의 프록시에 요청을 보내고, 프록시 컨테이너가 인증, 라우팅, 재시도, 관측 데이터를 처리할 수 있습니다.

### Pod IP가 불안정한 이유

Deployment가 Pod를 2개 만들었다고 가정해보겠습니다.

```text
Deployment/web
  ├─ Pod web-abc  app=web  10.244.0.10
  └─ Pod web-def  app=web  10.244.0.11
```

각 Pod는 클러스터 내부 네트워크에서 고유한 IP를 받습니다. 하지만 Pod는 일시적인 실행 단위라 삭제되거나 재배포되면 새 Pod가 만들어지고 IP도 바뀔 수 있습니다.

```text
Pod web-abc  10.244.0.10  삭제
Pod web-xyz  10.244.0.23  새로 생성
```

따라서 클라이언트가 Pod IP를 직접 기억하고 접근하는 구조는 안정적이지 않습니다. Deployment가 Pod를 계속 바꾸더라도 클라이언트가 바라보는 주소는 그대로여야 합니다. 이 역할을 Service가 합니다.

### Service가 트래픽을 보내는 방식

Service는 label selector로 대상 Pod를 찾습니다. 아래 Service는 `app=web` label을 가진 Pod들을 대상으로 삼습니다.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-clusterip
spec:
  type: ClusterIP
  selector:
    app: web
  ports:
    - name: http
      port: 80
      targetPort: 80
```

중요한 필드:

- `metadata.name`: Service 이름입니다. 같은 namespace 안에서는 DNS 이름으로도 사용됩니다.
- `spec.type`: Service를 어디까지 노출할지 정합니다.
- `spec.selector`: 트래픽을 보낼 Pod를 label로 찾습니다.
- `ports.port`: Service가 받는 포트입니다.
- `ports.targetPort`: 실제 Pod 컨테이너로 전달할 포트입니다.

흐름은 다음과 같습니다.

```text
Client
  -> Service/web-clusterip:80
  -> Endpoint 목록 중 하나 선택
  -> Pod app=web:80
```

Service가 선택한 실제 Pod 목록은 Endpoint 또는 EndpointSlice로 확인할 수 있습니다.

```bash
kubectl get endpoints web-clusterip
kubectl get pods --show-labels
```

Service selector와 Pod label이 맞지 않으면 Service는 만들어져도 트래픽을 보낼 Pod를 찾지 못합니다. 이때 Service의 Endpoint가 비어 있게 됩니다.

### ClusterIP

`ClusterIP`는 Service의 기본 타입입니다. 클러스터 내부에서만 접근 가능한 가상 IP와 DNS 이름을 만듭니다.

```text
Pod -> web-clusterip -> app=web Pod 중 하나
```

같은 namespace 안의 Pod에서는 Service 이름만으로 접근할 수 있습니다.

```bash
curl http://web-clusterip
```

다른 namespace에서 접근할 때는 namespace를 포함한 DNS 이름을 사용할 수 있습니다.

```bash
curl http://web-clusterip.k8s-lab.svc.cluster.local
```

여기서 중요한 점은 `web-clusterip`가 특정 Pod 이름이 아니라 Service 이름이라는 것입니다. Pod가 바뀌어도 Service 이름은 유지됩니다.

### NodePort

`NodePort`는 Node의 특정 포트를 열어서 클러스터 바깥에서 Service로 들어올 수 있게 합니다.

예를 들어 `nodePort: 30080`이면 개념상 다음 흐름이 됩니다.

```text
외부 Client
  -> NodeIP:30080
  -> Service/web-nodeport:80
  -> Pod app=web:80
```

NodePort의 포트는 보통 `30000-32767` 범위에서 사용합니다. 이번 실습에서는 `service-nodeport.yaml`에서 `30080`을 고정합니다.

```yaml
spec:
  type: NodePort
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080
```

필드의 의미:

- `nodePort: 30080`: Node 바깥에서 들어오는 포트입니다.
- `port: 80`: Service 내부 포트입니다.
- `targetPort: 80`: Pod 컨테이너 포트입니다.

일반적인 VM이나 서버 기반 클러스터라면 `NodeIP:30080`으로 접근합니다. kind에서는 Node가 실제 VM이 아니라 Docker 컨테이너입니다. 그래서 호스트의 `localhost:30080`으로 접근하려면 kind 클러스터 생성 시 Docker 포트 매핑을 미리 걸어야 합니다.

이번 실습의 [00-setup/kind-config.yaml](../00-setup/kind-config.yaml)은 다음 포트를 매핑합니다.

```yaml
extraPortMappings:
  - containerPort: 30080
    hostPort: 30080
    protocol: TCP
```

그래서 브라우저나 `curl`로 다음 주소를 확인할 수 있습니다.

```bash
curl -I http://localhost:30080
```

### port-forward

`port-forward`는 Service 타입이 아닙니다. `kubectl`이 로컬 PC의 포트와 Kubernetes 리소스를 임시로 연결하는 디버깅 방법입니다.

```bash
kubectl port-forward service/web-clusterip 8080:80
curl http://localhost:8080
```

이 명령은 로컬 `localhost:8080`으로 들어온 요청을 Service의 `80` 포트로 전달합니다. Service를 외부에 공개하는 설정을 바꾸지 않고 잠깐 접속을 확인할 때 유용합니다. 터미널에서 `Ctrl+C`를 누르면 연결이 종료됩니다.

### Service 타입 비교

| 타입 | 접근 범위 | 주 사용처 |
| --- | --- | --- |
| `ClusterIP` | 클러스터 내부 | Pod끼리 통신 |
| `NodePort` | 클러스터 외부에서 Node IP와 포트로 접근 | 로컬 실습, 간단한 외부 노출 |
| `LoadBalancer` | 클라우드 로드밸런서 주소로 접근 | 운영 환경 외부 노출 |
| `ExternalName` | 외부 DNS 이름으로 연결 | 외부 서비스를 클러스터 내부 이름처럼 사용 |

이번 실습에서는 `ClusterIP`, `NodePort`, `port-forward`를 다룹니다. `ClusterIP`로 내부 통신을 확인하고, `port-forward`로 로컬 디버깅을 해보고, `NodePort`로 kind 노드 포트 매핑을 통한 외부 접근 흐름을 확인합니다.

## 2. 이전 단계 상태 확인

`01-pods-deployments`에서 만든 `web` Deployment를 사용합니다.

```bash
kubectl config set-context --current --namespace=k8s-lab
kubectl get deployment web
kubectl get pods -l app=web -o wide
```

없다면 다시 생성합니다.

```bash
kubectl apply -f ../01-pods-deployments/deployment-web.yaml
```

## 3. ClusterIP Service 생성

```bash
kubectl apply -f service-clusterip.yaml
kubectl get service
kubectl describe service web-clusterip
```

ClusterIP는 클러스터 내부에서만 접근 가능한 Service입니다.

클러스터 안에서 접속 테스트:

```bash
kubectl run curl-test --rm -it --image=curlimages/curl --restart=Never -- \
  curl -I http://web-clusterip
```

만약 이전 테스트 Pod가 남아 있어서 `pods "curl-test" already exists` 오류가 나오면 삭제 후 다시 실행합니다.

```bash
kubectl get pod curl-test
kubectl delete pod curl-test
kubectl run curl-test --rm -it --image=curlimages/curl --restart=Never -- \
  curl -I http://web-clusterip
```

중요 포인트:

- Service는 label selector로 Pod를 찾습니다.
- `web-clusterip`는 `app=web` label을 가진 Pod들로 트래픽을 보냅니다.

Endpoint 확인:

```bash
kubectl get endpoints web-clusterip
```

## 4. port-forward로 로컬 접속

터미널 하나에서 실행합니다.

```bash
kubectl port-forward service/web-clusterip 8080:80
```

다른 터미널에서 확인합니다.

```bash
curl -I http://localhost:8080
```

확인 후 port-forward 터미널에서 `Ctrl+C`를 누릅니다.

## 5. NodePort Service 생성

`00-setup/kind-config.yaml`에서 kind 노드의 `30080` 포트를 호스트 `30080` 포트로 매핑해 두었습니다.

```bash
kubectl apply -f service-nodeport.yaml
kubectl get service web-nodeport
```

로컬에서 접속 확인:

```bash
curl -I http://localhost:30080
```

## 6. Service와 Pod 연결 구조 확인

```bash
kubectl get service web-clusterip -o yaml
kubectl get pods --show-labels
```

확인할 부분:

- Service의 `spec.selector.app` 값
- Pod의 `metadata.labels.app` 값

둘이 일치해야 Service가 Pod로 트래픽을 보낼 수 있습니다.

`selector`의 값은 정해진 목록에서 고르는 것이 아니라, Pod에 붙어 있는 label 중에서 선택합니다. 현재 클러스터에서 사용할 수 있는 label은 다음 명령으로 확인합니다.

```bash
kubectl get pods --show-labels
```

예를 들어 출력에 다음 label이 보인다고 가정합니다.

```text
app=web
app=config-demo
```

그러면 Service selector는 다음처럼 쓸 수 있습니다.

```yaml
selector:
  app: web
```

또는 다른 Pod를 대상으로 삼으려면 다음처럼 바꿀 수 있습니다.

```yaml
selector:
  app: config-demo
```

label은 여러 개를 함께 조건으로 사용할 수도 있습니다.

```yaml
selector:
  app: api
  tier: backend
```

이 경우에는 `app=api`이면서 `tier=backend`인 Pod만 Service 대상이 됩니다. 단, selector가 맞더라도 Service의 `targetPort`가 대상 Pod 컨테이너가 실제로 열고 있는 포트와 맞아야 트래픽이 정상 전달됩니다.

## 체크포인트

```bash
kubectl get svc
kubectl get endpoints
curl -I http://localhost:30080
```

HTTP 응답 헤더가 보이면 성공입니다.
