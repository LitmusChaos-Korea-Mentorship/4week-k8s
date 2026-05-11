# 00. 실습 환경 준비

목표: Docker, kubectl, minikube, Helm을 설치하고 로컬 Kubernetes 클러스터를 시작합니다.

예상 시간: 20-30분

이 실습은 `minikube`의 Docker driver를 기본으로 사용합니다. 따라서 모든 OS에서 Docker가 먼저 실행 중이어야 합니다.

## OS별 설치 가이드

본인 환경에 맞는 문서를 선택하세요.

| 환경 | 문서 | 권장 대상 |
| --- | --- | --- |
| Ubuntu | [ubuntu.md](./ubuntu.md) | 수업 기본 환경, Ubuntu VM, WSL2 Ubuntu |
| Linux 공통 | [linux.md](./linux.md) | Fedora, Arch, Debian 등 Ubuntu 외 Linux |
| macOS | [macos.md](./macos.md) | Mac Intel, Apple Silicon |
| Windows | [windows.md](./windows.md) | Windows 사용자, WSL2 Ubuntu 권장 |

## 공통 요구사항

필수 도구:

- Docker 또는 Docker Desktop
- minikube
- kubectl
- Helm 3

권장 리소스:

- CPU: 2 core 이상
- Memory: 4GB 이상
- Disk: 20GB 이상 여유 공간

공통 확인 명령:

```bash
docker version
docker ps
minikube version
kubectl version --client
helm version --short
```

Docker가 실행 중이 아니면 `minikube start --driver=docker`가 실패합니다.

## 클러스터 시작

도구 설치가 끝나면 OS와 관계없이 같은 명령으로 minikube 클러스터를 시작합니다.

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

## kubectl 기본 사용법

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

## 체크포인트

다음 명령이 모두 성공하면 다음 단계로 이동합니다.

```bash
docker ps
minikube status
kubectl get nodes
helm version --short
```

## 참고 공식 문서

- minikube start: https://minikube.sigs.k8s.io/docs/start/
- minikube Docker driver: https://minikube.sigs.k8s.io/docs/drivers/docker/
- kubectl 설치: https://kubernetes.io/docs/tasks/tools/
- Helm 설치: https://helm.sh/docs/intro/install/

