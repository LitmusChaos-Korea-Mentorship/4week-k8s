# Windows 설치 가이드

Windows는 두 가지 방식 중 하나를 선택합니다.

- 권장: WSL2 Ubuntu 안에서 Ubuntu 절차로 진행
- 대안: Windows native 환경에서 Docker Desktop과 winget 사용

Kubernetes 실습 명령어가 Linux shell 기준이므로, 수업에서는 **WSL2 Ubuntu 방식**을 권장합니다.

## 1. 권장 방식: WSL2 Ubuntu

PowerShell을 관리자 권한으로 열고 WSL을 설치합니다.

```powershell
wsl --install -d Ubuntu
```

설치 후 재부팅이 필요할 수 있습니다. Ubuntu 터미널을 열고 다음을 확인합니다.

```bash
uname -a
```

Docker Desktop for Windows를 설치하고 실행합니다. Docker Desktop 설정에서 WSL integration을 켭니다.

확인:

```bash
docker version
docker ps
```

이후 Ubuntu 터미널 안에서 [ubuntu.md](./ubuntu.md)의 절차를 따라 `minikube`, `kubectl`, `Helm`을 설치합니다.

주의:

- Windows PowerShell이 아니라 WSL2 Ubuntu 터미널에서 실습 명령을 실행합니다.
- Docker Desktop이 꺼져 있으면 WSL 안에서도 Docker 명령이 실패할 수 있습니다.

## 2. 대안: Windows native 방식

PowerShell을 열고 Docker Desktop이 실행 중인지 확인합니다.

```powershell
docker version
docker ps
```

winget으로 도구를 설치합니다.

```powershell
winget install Kubernetes.minikube
winget install Kubernetes.kubectl
winget install Helm.Helm
```

새 PowerShell을 열고 확인합니다.

```powershell
minikube version
kubectl version --client
helm version --short
```

클러스터 시작:

```powershell
minikube start --driver=docker --cpus=2 --memory=4096
```

확인:

```powershell
minikube status
kubectl get nodes -o wide
```

Windows native 방식은 경로, shell 문법, quoting이 Linux 실습 명령과 다를 수 있습니다. 수업 자료의 명령을 그대로 따라가려면 WSL2 Ubuntu를 사용하는 편이 좋습니다.

## 문제 해결

Docker Desktop이 실행 중인지 확인합니다.

```powershell
docker ps
```

WSL2에서 Docker 명령이 실패하면 Docker Desktop의 WSL integration 설정을 확인합니다.

WSL 배포판 확인:

```powershell
wsl -l -v
```

minikube를 처음부터 다시 만들기:

```powershell
minikube delete
minikube start --driver=docker --cpus=2 --memory=4096
```
