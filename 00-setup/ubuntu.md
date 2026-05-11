# Ubuntu 설치 가이드

Ubuntu 실습 환경에서는 Docker Desktop보다 Docker Engine 설치를 기본으로 안내합니다.

WSL2 Ubuntu를 사용하는 Windows 사용자도 이 문서를 따르면 됩니다.

## 1. 시스템 패키지 준비

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg apt-transport-https
```

## 2. Docker Engine 설치

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

## 3. kind 설치

```bash
ARCH=$(uname -m)
[ "$ARCH" = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.31.0/kind-linux-amd64
[ "$ARCH" = aarch64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.31.0/kind-linux-arm64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
kind version
```

## 4. kubectl 설치

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
kubectl version --client
```

ARM64 Ubuntu라면 다운로드 경로의 `linux/amd64`를 `linux/arm64`로 바꿉니다.

## 5. Helm 설치

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version --short
```

## 6. 클러스터 시작

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

Docker 권한 오류:

```bash
groups
sudo usermod -aG docker "$USER"
newgrp docker
```

그래도 안 되면 터미널을 새로 열고 다시 확인합니다.

Docker daemon 상태 확인:

```bash
sudo systemctl status docker
sudo systemctl start docker
```
