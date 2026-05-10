# 01. Pod와 Deployment

목표: Pod가 무엇인지 확인하고, Deployment로 복제본과 롤링 업데이트를 관리합니다.

예상 시간: 30분

## 1. Namespace 생성

실습 리소스를 분리하기 위해 namespace를 만듭니다.

```bash
kubectl create namespace k8s-lab
kubectl config set-context --current --namespace=k8s-lab
```

확인:

```bash
kubectl config view --minify | grep namespace
```

## 2. 단일 Pod 실행

```bash
kubectl apply -f pod-nginx.yaml
kubectl get pods -o wide
```

상세 확인:

```bash
kubectl describe pod nginx-pod
```

Pod 안의 컨테이너에 명령 실행:

```bash
kubectl exec -it nginx-pod -- nginx -v
```

Pod 삭제:

```bash
kubectl delete -f pod-nginx.yaml
```

중요 포인트:

- Pod를 직접 만들면 죽었을 때 운영자가 직접 다시 만들어야 합니다.
- 실제 운영에서는 보통 Deployment가 Pod를 관리합니다.

## 3. Deployment 생성

```bash
kubectl apply -f deployment-web.yaml
kubectl get deployments
kubectl get replicasets
kubectl get pods -o wide
```

Deployment가 Pod 2개를 유지하는지 확인합니다.

```bash
kubectl get pods -l app=web
```

## 4. 자기 회복 확인

Pod 하나를 강제로 삭제합니다.

```bash
POD_NAME=$(kubectl get pod -l app=web -o jsonpath='{.items[0].metadata.name}')
kubectl delete pod "$POD_NAME"
kubectl get pods -l app=web -w
```

새 Pod가 자동으로 생기면 `Ctrl+C`로 watch를 종료합니다.

중요 포인트:

- Deployment는 원하는 상태, 즉 replicas 2개를 계속 맞춥니다.
- Pod 이름이 바뀌어도 label이 같으면 같은 애플리케이션 묶음으로 다룰 수 있습니다.

## 5. 스케일 조정

```bash
kubectl scale deployment web --replicas=4
kubectl get pods -l app=web
```

다시 2개로 줄입니다.

```bash
kubectl scale deployment web --replicas=2
kubectl get pods -l app=web
```

## 6. 롤링 업데이트

nginx 이미지를 업데이트합니다.

```bash
kubectl set image deployment/web nginx=nginx:1.27
kubectl rollout status deployment/web
kubectl describe deployment web
```

업데이트 이력:

```bash
kubectl rollout history deployment/web
```

문제가 있었다고 가정하고 이전 버전으로 롤백합니다.

```bash
kubectl rollout undo deployment/web
kubectl rollout status deployment/web
```

## 체크포인트

```bash
kubectl get deployment web
kubectl get pods -l app=web
kubectl rollout history deployment/web
```

`web` Deployment가 `READY 2/2` 상태면 다음 단계로 이동합니다.

