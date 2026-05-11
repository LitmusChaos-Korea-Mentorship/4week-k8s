# 02. Service와 네트워킹

목표: Pod IP가 아닌 Service를 통해 애플리케이션에 안정적으로 접속하는 방법을 실습합니다.

예상 시간: 25분

## 1. 이전 단계 상태 확인

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

## 2. ClusterIP Service 생성

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

중요 포인트:

- Service는 label selector로 Pod를 찾습니다.
- `web-clusterip`는 `app=web` label을 가진 Pod들로 트래픽을 보냅니다.

Endpoint 확인:

```bash
kubectl get endpoints web-clusterip
```

## 3. port-forward로 로컬 접속

터미널 하나에서 실행합니다.

```bash
kubectl port-forward service/web-clusterip 8080:80
```

다른 터미널에서 확인합니다.

```bash
curl -I http://localhost:8080
```

확인 후 port-forward 터미널에서 `Ctrl+C`를 누릅니다.

## 4. NodePort Service 생성

`00-setup/kind-config.yaml`에서 kind 노드의 `30080` 포트를 호스트 `30080` 포트로 매핑해 두었습니다.

```bash
kubectl apply -f service-nodeport.yaml
kubectl get service web-nodeport
```

로컬에서 접속 확인:

```bash
curl -I http://localhost:30080
```

## 5. Service와 Pod 연결 구조 확인

```bash
kubectl get service web-clusterip -o yaml
kubectl get pods --show-labels
```

확인할 부분:

- Service의 `spec.selector.app` 값
- Pod의 `metadata.labels.app` 값

둘이 일치해야 Service가 Pod로 트래픽을 보낼 수 있습니다.

## 체크포인트

```bash
kubectl get svc
kubectl get endpoints
curl -I http://localhost:30080
```

HTTP 응답 헤더가 보이면 성공입니다.
