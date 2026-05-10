# 00. Ubuntu 실습 환경 준비

목표: Docker, kubectl, minikube, Helm을 설치하고 로컬 Kubernetes 클러스터를 시작합니다.

예상 시간: 25분

## 1. 시스템 패키지 준비

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg apt-transport-https
```

## 2. Docker 준비

minikube가 컨테이너를 실행하려면 Docker 같은 컨테이너 실행 환경이 필요합니다.

Ubuntu 실습에서는 **Docker Engine**을 기본으로 설치합니다. Docker Desktop을 이미 쓰고 있다면 Docker Engine 설치를 건너뛰고 `docker version`으로 실행 상태만 확인해도 됩니다.

맥/윈도우 환경에서는 Docker Desktop을 설치하고 실행 중인지 확인해야 합니다. 단, 이 문서의 실습 명령어는 Ubuntu 기준입니다.

### 2-1. Docker Engine 설치

minikube는 여러 드라이버를 지원하지만, 이 실습은 Docker 드라이버를 사용합니다.

```bash
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

현재 사용자가 `sudo` 없이 Docker를 실행할 수 있도록 그룹에 추가합니다.

```bash
sudo usermod -aG docker "$USER"
newgrp docker
```

확인:

```bash
docker version
docker run --rm hello-world
```

### 2-2. Docker Desktop 사용 시 확인

Docker Desktop을 사용하는 환경에서는 앱이 실행 중이어야 합니다.

확인:

```bash
docker version
docker ps
```

Docker Desktop이 꺼져 있으면 minikube가 Docker 드라이버로 클러스터를 만들 수 없습니다.

## 3. minikube 설치

minikube는 로컬에 Kubernetes 클러스터를 만들어 주는 도구입니다.

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64
```

확인:

```bash
minikube version
```

## 4. kubectl 설치

kubectl은 Kubernetes API 서버와 통신하는 CLI 도구입니다.

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
```

확인:

```bash
kubectl version --client
```

## 5. Helm 설치

Helm은 Kubernetes 패키지 매니저입니다. 이번 실습에서는 Helm chart를 설치하고 release를 관리하는 기본 흐름을 확인합니다.

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

확인:

```bash
helm version --short
```

## 6. 클러스터 시작

```bash
minikube start --driver=docker --cpus=2 --memory=4096
```

상태 확인:

```bash
minikube status
kubectl cluster-info
kubectl get nodes -o wide
```

정상 예시:

```text
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   1m    v1.xx.x
```

## 7. kubectl 기본 사용법

```bash
kubectl get namespaces
kubectl get pods -A
kubectl config current-context
```

자주 쓰는 명령 형태:

```bash
kubectl get <resource>
kubectl describe <resource> <name>
kubectl apply -f <file.yaml>
kubectl delete -f <file.yaml>
```

## 8. 설치 명령 빠른 요약

이미 Docker가 준비된 환경에서 핵심 도구만 빠르게 설치할 때는 아래 순서만 보면 됩니다.

```bash
# minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64
minikube version

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
kubectl version --client

# helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version --short
```

## 체크포인트

다음 명령이 모두 성공하면 다음 단계로 이동합니다.

```bash
docker ps
minikube status
kubectl get nodes
helm version --short
```

## 문제 해결

Docker 권한 오류가 나면:

```bash
groups
newgrp docker
```

그래도 안 되면 터미널을 새로 열고 다시 확인합니다.

minikube가 이미 실행 중이면:

```bash
minikube status
```

필요할 때만 재시작합니다.

```bash
minikube stop
minikube start --driver=docker --cpus=2 --memory=4096
```
