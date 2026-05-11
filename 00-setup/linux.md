# Linux 공통 설치 가이드

Ubuntu가 아닌 Linux 배포판에서는 패키지 매니저만 다르고 전체 흐름은 같습니다.

```text
Docker 설치 및 실행
-> minikube 설치
-> kubectl 설치
-> Helm 설치
-> minikube start --driver=docker
```

## 1. Docker 준비

배포판별 패키지 매니저로 Docker 또는 호환 컨테이너 런타임을 설치합니다.

예:

- Debian 계열: Ubuntu 절차와 거의 같습니다.
- Fedora 계열: `dnf`로 Docker 또는 Moby Engine을 설치할 수 있습니다.
- Arch 계열: `pacman` 또는 AUR 패키지를 사용할 수 있습니다.

가장 중요한 체크포인트는 현재 사용자가 Docker를 실행할 수 있는지입니다.

```bash
docker version
docker ps
```

권한 오류가 나면 Docker 그룹 설정을 확인합니다.

```bash
groups
sudo usermod -aG docker "$USER"
newgrp docker
```

## 2. minikube 설치

x86-64 Linux:

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64
minikube version
```

ARM64 Linux:

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-arm64
sudo install minikube-linux-arm64 /usr/local/bin/minikube
rm minikube-linux-arm64
minikube version
```

## 3. kubectl 설치

x86-64 Linux:

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
kubectl version --client
```

ARM64 Linux:

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
kubectl version --client
```

## 4. Helm 설치

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version --short
```

## 5. 클러스터 시작

```bash
minikube start --driver=docker --cpus=2 --memory=4096
```

확인:

```bash
minikube status
kubectl get nodes -o wide
```

## 문제 해결

Docker daemon 상태 확인:

```bash
docker ps
```

systemd 기반 배포판:

```bash
sudo systemctl status docker
sudo systemctl start docker
```

minikube를 처음부터 다시 만들기:

```bash
minikube delete
minikube start --driver=docker --cpus=2 --memory=4096
```

