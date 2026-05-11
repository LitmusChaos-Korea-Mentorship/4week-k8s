# 04. Helm 기본 실습

목표: Helm chart를 설치하고 release를 조회, 업그레이드, 삭제합니다.

예상 시간: 10분

## 1. Helm 상태 확인

```bash
helm version --short
kubectl config set-context --current --namespace=k8s-lab
```

namespace가 없다면 만듭니다.

```bash
kubectl create namespace k8s-lab
kubectl config set-context --current --namespace=k8s-lab
```

## 2. Chart repository 추가

Bitnami chart repository를 추가합니다.

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm search repo bitnami/nginx
```

중요 포인트:

- repository는 chart 저장소입니다.
- chart는 Kubernetes YAML 템플릿 묶음입니다.
- release는 chart를 클러스터에 설치한 결과입니다.

## 3. nginx chart 설치

```bash
helm install lab-nginx bitnami/nginx \
  --set service.type=NodePort \
  --set service.nodePorts.http=30081
```

확인:

```bash
helm list
kubectl get all -l app.kubernetes.io/instance=lab-nginx
kubectl get service lab-nginx
```

`00-setup/kind-config.yaml`에서 kind 노드의 `30081` 포트를 호스트 `30081` 포트로 매핑해 두었습니다. 로컬에서 접속을 확인합니다.

```bash
curl -I http://localhost:30081
```

## 4. Values 확인과 업그레이드

현재 release에 적용된 값:

```bash
helm get values lab-nginx
```

replica 수를 2개로 변경합니다.

```bash
helm upgrade lab-nginx bitnami/nginx \
  --set replicaCount=2 \
  --set service.type=NodePort \
  --set service.nodePorts.http=30081
```

확인:

```bash
helm history lab-nginx
kubectl get pods -l app.kubernetes.io/instance=lab-nginx
```

## 5. Release 삭제

```bash
helm uninstall lab-nginx
helm list
kubectl get all -l app.kubernetes.io/instance=lab-nginx
```

중요 포인트:

- `helm uninstall`은 release가 생성한 Kubernetes 리소스를 정리합니다.
- repository 등록 정보는 삭제하지 않습니다.
- 직접 만든 `web`, `config-demo` 리소스는 Helm release가 아니므로 삭제되지 않습니다.

## 체크포인트

아래 질문에 답할 수 있으면 됩니다.

- Chart와 release의 차이는 무엇인가?
- `helm install`과 `helm upgrade`는 각각 언제 쓰는가?
- Helm으로 설치한 리소스와 `kubectl apply`로 만든 리소스는 어떻게 구분할 수 있는가?
