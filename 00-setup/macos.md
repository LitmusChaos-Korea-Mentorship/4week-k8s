# macOS 설치 가이드

macOS에서는 Docker Desktop과 Homebrew를 사용하는 방식이 가장 단순합니다.

## 1. Docker Desktop 설치

Docker Desktop for Mac을 설치하고 실행합니다.

확인:

```bash
docker version
docker ps
```

Docker Desktop이 실행 중이어야 kind 클러스터를 만들 수 있습니다.

## 2. Homebrew 설치 확인

```bash
brew --version
```

Homebrew가 없다면 https://brew.sh 의 설치 안내를 따릅니다.

## 3. kind, kubectl, Helm 설치

```bash
brew install kind
brew install kubectl
brew install helm
```

확인:

```bash
kind version
kubectl version --client
helm version --short
```

Apple Silicon Mac에서도 Homebrew 설치 방식이면 보통 아키텍처를 자동으로 맞춰 설치합니다.

## 4. 클러스터 시작

```bash
cd /path/to/4week-k8s/00-setup
kind create cluster --name k8s-lab --config kind-config.yaml
```

확인:

```bash
kubectl config use-context kind-k8s-lab
kubectl get nodes -o wide
```

## 문제 해결

Docker Desktop이 실행 중인지 확인합니다.

```bash
docker ps
```

처음부터 다시 만들기:

```bash
kind delete cluster --name k8s-lab
kind create cluster --name k8s-lab --config kind-config.yaml
```
