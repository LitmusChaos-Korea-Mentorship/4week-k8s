# macOS 설치 가이드

macOS에서는 Docker Desktop과 Homebrew를 사용하는 방식이 가장 단순합니다.

## 1. Docker Desktop 설치

Docker Desktop for Mac을 설치하고 실행합니다.

확인:

```bash
docker version
docker ps
```

Docker Desktop이 실행 중이어야 minikube Docker driver를 사용할 수 있습니다.

## 2. Homebrew 설치 확인

```bash
brew --version
```

Homebrew가 없다면 https://brew.sh 의 설치 안내를 따릅니다.

## 3. minikube, kubectl, Helm 설치

```bash
brew install minikube
brew install kubectl
brew install helm
```

확인:

```bash
minikube version
kubectl version --client
helm version --short
```

Apple Silicon Mac에서도 Homebrew 설치 방식이면 보통 아키텍처를 자동으로 맞춰 설치합니다.

## 4. 클러스터 시작

```bash
minikube start --driver=docker --cpus=2 --memory=4096
```

확인:

```bash
minikube status
kubectl get nodes -o wide
```

## 문제 해결

Docker Desktop이 실행 중인지 확인합니다.

```bash
docker ps
```

Docker Desktop이 켜져 있는데도 minikube가 다른 driver를 선택하면 명시적으로 Docker driver를 지정합니다.

```bash
minikube start --driver=docker --cpus=2 --memory=4096
```

처음부터 다시 만들기:

```bash
minikube delete
minikube start --driver=docker --cpus=2 --memory=4096
```

