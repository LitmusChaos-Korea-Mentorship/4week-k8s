# 05. 운영 기본 명령과 정리

목표: 실습 중 문제가 생겼을 때 확인하는 명령을 익히고, 생성한 리소스를 정리합니다.

예상 시간: 5분

## 1. 전체 리소스 확인

```bash
kubectl config set-context --current --namespace=k8s-lab
kubectl get all
kubectl get configmap,secret
```

전체 namespace까지 보고 싶으면:

```bash
kubectl get pods -A
```

## 2. 로그 확인

nginx Deployment 로그:

```bash
kubectl logs deployment/web
```

config-demo 로그:

```bash
kubectl logs deployment/config-demo --tail=20
```

실시간 로그:

```bash
kubectl logs deployment/config-demo -f
```

확인 후 `Ctrl+C`로 종료합니다.

## 3. describe로 이벤트 확인

```bash
kubectl describe deployment web
kubectl describe pod -l app=web
```

문제가 있을 때는 보통 아래 순서로 봅니다.

```bash
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl get events --sort-by=.lastTimestamp
```

## 4. exec로 컨테이너 내부 확인

```bash
POD_NAME=$(kubectl get pod -l app=config-demo -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it "$POD_NAME" -- sh
```

컨테이너 안에서 확인:

```bash
printenv APP_MODE
cat /etc/app/config/message
exit
```

## 5. YAML 출력과 dry-run

명령형으로 리소스를 만들기 전에 YAML을 확인할 수 있습니다.

```bash
kubectl create deployment dryrun-demo --image=nginx:1.25 --dry-run=client -o yaml
```

서버 적용 전 검증:

```bash
kubectl apply -f ../01-pods-deployments/deployment-web.yaml --dry-run=server
```

## 6. 실습 리소스 정리

namespace를 지우면 그 안의 실습 리소스가 함께 삭제됩니다.

```bash
kubectl delete namespace k8s-lab
```

삭제 확인:

```bash
kubectl get namespace k8s-lab
```

클러스터를 완전히 지우려면:

```bash
minikube delete
```

## 마무리 질문

아래 질문에 답할 수 있으면 이번 실습의 핵심을 잡은 것입니다.

- Pod와 Deployment의 차이는 무엇인가?
- Namespace는 어떤 기준으로 쓰는가?
- Service가 필요한 이유는 무엇인가?
- ClusterIP와 NodePort의 차이는 무엇인가?
- ConfigMap과 Secret은 각각 언제 쓰는가?
- Helm chart와 release의 차이는 무엇인가?
- `kubectl describe`와 `kubectl logs`는 언제 쓰는가?
