# 4week-k8s: Kubernetes 기본 개념과 2시간 실습

이 자료는 Kubernetes의 핵심 개념을 빠르게 이해하고, `kind`로 직접 배포/노출/설정/Helm/운영 명령을 실습하는 2시간 내외 워크숍입니다. 설치 가이드는 Linux, Ubuntu, Windows, macOS로 나누고, 이후 실습 명령은 Linux shell 기준으로 작성합니다.

## 왜 kind인가?

`kind`는 "Kubernetes IN Docker"의 줄임말입니다. Docker 컨테이너를 Kubernetes Node처럼 띄워서, 로컬 PC 안에 작은 Kubernetes 클러스터를 만드는 도구입니다. 실제 운영용 클러스터를 만드는 도구라기보다 학습, 테스트, CI 환경에서 빠르게 클러스터를 만들고 지우는 데 적합합니다.

이 실습은 `kind`를 기본으로 사용합니다. 이유는 실습 참가자마다 OS와 설치 상태가 달라도 Docker만 동작하면 거의 같은 명령으로 클러스터를 만들 수 있기 때문입니다.

- `kind`는 Docker 컨테이너 안에 Kubernetes 노드를 만들기 때문에 Windows WSL2, macOS, Linux에서 실습 환경을 비교적 같은 방식으로 재현할 수 있습니다.
- 클러스터 생성과 삭제가 `kind create cluster`, `kind delete cluster`로 명확해 실습 리소스를 초기화하기 쉽습니다.
- Docker Desktop의 Kubernetes 기능이나 minikube driver 설정에 의존하지 않아 환경 차이로 생기는 문제를 줄일 수 있습니다.
- NodePort 실습은 [00-setup/kind-config.yaml](./00-setup/kind-config.yaml)의 포트 매핑으로 `localhost`에서 확인합니다.

## 전체 구성

| 단계 | 폴더 | 목표 | 예상 시간 |
| --- | --- | --- | --- |
| 0 | `00-concepts` | Kubernetes 기본 개념과 실습 리소스 관계 이해 | 20분 |
| 1 | `00-setup` | Docker, kind, kubectl, Helm 설치 및 클러스터 시작 | 20분 |
| 2 | `01-pods-deployments` | Pod, Deployment, ReplicaSet, rollout 이해 | 25분 |
| 3 | `02-services-networking` | Namespace, ClusterIP, NodePort, port-forward로 앱 접속 | 20분 |
| 4 | `03-config-storage` | ConfigMap, Secret, Volume 기본 실습 | 20분 |
| 5 | `04-helm-basics` | Helm chart 설치, 조회, 업그레이드, 삭제 | 10분 |
| 6 | `05-operations-cleanup` | 로그, describe, exec, 리소스 정리 | 5분 |
| 선택 | `06-litmus-chaos` | Chaos Engineering 개념, 수동 Pod 삭제 실습, LitmusChaos 다음 시간 예고 | 20-25분 |

총 120분 기준입니다. 이미 도구가 설치되어 있으면 setup 시간을 줄이고 `00-concepts`와 실습 반복에 더 배정하면 됩니다.
LitmusChaos 설치와 실행은 다음 시간 심화 과정으로 분리합니다. 이번 자료에서는 Chaos Engineering 사고방식과 Kubernetes 기본 복구 동작을 먼저 확인합니다.

## 선수 지식

- Linux 기본 명령어: `cd`, `ls`, `cat`, `curl`
- Docker 이미지/컨테이너 개념을 들어본 정도
- YAML 들여쓰기 기본

## 실습 전 확인

```bash
cd /path/to/4week-k8s
```

이 저장소를 WSL에서 `/mnt/d/Litmus/4week-k8s`에 두었다면 다음처럼 이동합니다.

```bash
cd /mnt/d/Litmus/4week-k8s
```

각 단계는 폴더 안의 `README.md`를 순서대로 따라가면 됩니다.
개념 설명은 [00-concepts/README.md](./00-concepts/README.md)에 자세히 정리했습니다.

## 실습 종료 후 정리

```bash
./cleanup.sh
```

스크립트는 실습 중 켜둔 `kubectl port-forward` 프로세스를 종료하고, `k8s-lab`, `chaos-lab` namespace와 `k8s-lab` kind 클러스터를 정리합니다. 설치한 `kubectl`, `kind`, `helm`, Docker 패키지와 다른 Docker 컨테이너/이미지는 삭제하지 않습니다.

실행 권한이 없다는 메시지가 나오면 한 번만 권한을 부여합니다.

```bash
chmod +x cleanup.sh
./cleanup.sh
```
