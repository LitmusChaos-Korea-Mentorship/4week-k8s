# 06. Chaos Engineering 기초와 Pod Delete 실습

목표: Chaos Engineering의 기본 흐름을 익히고, Pod 삭제 장애를 수동으로 주입해 Kubernetes의 복구 동작을 관찰합니다.

예상 시간: 20-25분

이 단계는 선택 심화 실습입니다. 앞 단계에서 `kind`, `kubectl`, `helm` 설치와 기본 Deployment/Service 실습을 마친 뒤 진행하세요.

LitmusChaos 설치와 `pod-delete` 실험 실행은 다음 시간에 진행합니다. 이번 시간에는 Litmus를 설치하지 않고, 같은 장애 유형을 `kubectl delete pod`로 먼저 이해합니다.

다음 시간 참고 문서:

- Litmus Helm repository: https://github.com/litmuschaos/litmus-helm
- Litmus installation docs: https://litmuschaos.website.cncfstack.com/docs/3.11.0/getting-started/installation
- Pod Delete experiment docs: https://litmuschaos.github.io/litmus/experiments/categories/pods/pod-delete/

## 1. 실험 원칙

Chaos Engineering은 장애를 넣는 행위 자체가 목적이 아닙니다. 실험 전후로 무엇을 확인할지 정해야 합니다.

이번 실험의 가설:

```text
chaos-web Deployment는 replica가 3개이므로 Pod 1개가 삭제되어도 Service는 계속 응답하고,
Deployment controller는 새 Pod를 만들어 desired state로 복구한다.
```

관찰할 항목:

- Pod가 삭제되는지
- 새 Pod가 자동 생성되는지
- `chaos-web` Service가 계속 HTTP 응답을 반환하는지

중단 조건:

- 실험 대상 외 Pod가 삭제된다.
- Service 응답이 계속 실패한다.

## 2. 실습 namespace와 대상 앱 준비

```bash
kubectl create namespace chaos-lab
kubectl config set-context --current --namespace=chaos-lab
kubectl apply -f target-app.yaml
kubectl rollout status deployment/chaos-web
kubectl get pods -l app=chaos-web -o wide
```

Service 확인:

```bash
kubectl port-forward service/chaos-web 18080:80
```

다른 터미널에서:

```bash
curl -I http://localhost:18080
```

확인 후 port-forward 터미널에서 `Ctrl+C`를 누릅니다.

## 3. 수동 Chaos: Pod 하나 삭제

먼저 도구 없이 Kubernetes 기본 동작을 관찰합니다.

터미널 1:

```bash
kubectl get pods -l app=chaos-web -w
```

터미널 2:

```bash
TARGET_POD=$(kubectl get pod -l app=chaos-web -o jsonpath='{.items[0].metadata.name}')
kubectl delete pod "$TARGET_POD"
```

터미널 1에서 기존 Pod가 `Terminating` 되고 새 Pod가 생성되는지 봅니다. 확인 후 `Ctrl+C`로 종료합니다.

복구 확인:

```bash
kubectl get deployment chaos-web
kubectl get pods -l app=chaos-web
```

중요 포인트:

- Pod를 직접 만들었다면 삭제 후 자동 복구되지 않습니다.
- Deployment가 관리하는 Pod는 desired replicas에 맞게 다시 생성됩니다.
- 이 실험은 LitmusChaos의 `pod-delete`가 내부적으로 검증하려는 가장 기본적인 장애 상황입니다.

## 4. 장애 주입 중 서비스 응답 관찰

터미널 1:

```bash
kubectl port-forward service/chaos-web 18080:80
```

터미널 2:

```bash
while true; do
  date
  curl -s -o /dev/null -w "status=%{http_code} time=%{time_total}\n" http://localhost:18080
  sleep 1
done
```

터미널 3에서 Pod를 삭제합니다.

```bash
TARGET_POD=$(kubectl get pod -l app=chaos-web -o jsonpath='{.items[0].metadata.name}')
kubectl delete pod "$TARGET_POD"
```

관찰 포인트:

- HTTP status가 계속 200인지
- 일시 실패가 있다면 몇 초인지
- Pod가 Ready 상태로 돌아오는 데 얼마나 걸리는지