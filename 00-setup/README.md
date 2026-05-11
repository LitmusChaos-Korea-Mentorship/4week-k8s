# 00. 실습 환경 준비

목표: Docker, kind, kubectl, Helm을 설치하고 로컬 Kubernetes 클러스터를 시작합니다.

예상 시간: 20-30분

이 실습은 `kind`를 기본으로 사용합니다. kind는 "Kubernetes IN Docker"의 줄임말로, Docker 컨테이너를 Kubernetes Node처럼 실행해서 로컬 클러스터를 만드는 도구입니다.

kind 자체가 컨테이너를 실행하는 것은 아니고 Docker를 사용해 Node 컨테이너를 띄웁니다. 따라서 모든 OS에서 Docker가 먼저 실행 중이어야 합니다. Windows에서는 보통 Docker Desktop의 WSL Integration을 켠 뒤 WSL2 Ubuntu 안에서 실습합니다.

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
- kind
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
kind version
kubectl version --client
helm version --short
```

Docker가 실행 중이 아니면 `kind create cluster`가 실패합니다.

## 클러스터 시작

도구 설치가 끝나면 OS와 관계없이 같은 명령으로 kind 클러스터를 시작합니다. 이 실습은 NodePort 확인을 위해 [kind-config.yaml](./kind-config.yaml)에 `30080`, `30081` 포트를 매핑합니다.

```bash
kind create cluster --name k8s-lab --config kind-config.yaml
```

`kind-config.yaml`은 실습 재현성을 위해 kind node 이미지를 `kindest/node:v1.30.13`으로 고정합니다. 최신 kind가 기본으로 선택하는 Kubernetes 버전이 WSL의 cgroup 설정과 맞지 않으면 kubelet이 시작되지 않을 수 있기 때문입니다.

상태 확인:

```bash
kubectl config use-context kind-k8s-lab
kubectl cluster-info
kubectl get nodes -o wide
```

정상 예시:

```text
NAME                    STATUS   ROLES           AGE   VERSION
k8s-lab-control-plane   Ready    control-plane   1m    v1.xx.x
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
kind get clusters
kubectl get nodes
helm version --short
```

## 참고 공식 문서

- kind quick start: https://kind.sigs.k8s.io/docs/user/quick-start/
- kubectl 설치: https://kubernetes.io/docs/tasks/tools/
- Helm 설치: https://helm.sh/docs/intro/install/
