# 4week-k8s: Kubernetes 기본 개념과 2시간 실습

이 자료는 Ubuntu 환경에서 Kubernetes의 핵심 개념을 빠르게 이해하고, `minikube`로 직접 배포/노출/설정/Helm/운영 명령을 실습하는 2시간 내외 워크숍입니다.

## 왜 minikube인가?

이 실습은 `minikube`를 기본으로 사용합니다.

- `minikube`는 로컬 단일 노드 Kubernetes 학습에 적합하고, `kubectl`, Service, Ingress, Dashboard, addons 흐름을 초심자가 확인하기 쉽습니다.
- `kind`는 CI, 빠른 클러스터 생성/삭제, 멀티 노드 테스트에는 좋지만 Docker 컨테이너 안에 노드를 띄우는 구조라 초심자에게 Service 노출과 로컬 접속 설명이 더 헷갈릴 수 있습니다.
- 결론: 이번 2시간 실습은 `minikube`로 진행하고, 이후 CI나 멀티 노드 테스트 주제로 확장할 때 `kind`를 추가하는 편이 낫습니다.

## 전체 구성

| 단계 | 폴더 | 목표 | 예상 시간 |
| --- | --- | --- | --- |
| 0 | `00-concepts` | Kubernetes 기본 개념과 실습 리소스 관계 이해 | 20분 |
| 1 | `00-setup` | Docker, kubectl, minikube, Helm 설치 및 클러스터 시작 | 20분 |
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
cd /home/ubuntu/data/4week-k8s
```

각 단계는 폴더 안의 `README.md`를 순서대로 따라가면 됩니다.
개념 설명은 [00-concepts/README.md](/home/ubuntu/data/4week-k8s/00-concepts/README.md)에 자세히 정리했습니다.

## 실습 종료 후 정리

```bash
minikube delete
```

클러스터만 지우며, 설치한 `kubectl`, `minikube`, `helm`, Docker 패키지는 삭제하지 않습니다.
