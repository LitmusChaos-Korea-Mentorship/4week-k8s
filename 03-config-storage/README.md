# 03. ConfigMap, Secret, Volume

목표: 컨테이너 이미지 밖에서 설정을 주입하고, 간단한 Volume을 사용하는 방법을 실습합니다.

예상 시간: 25분

## 1. 개념 정리

### ConfigMap과 Secret

ConfigMap은 일반 설정값을 이미지 밖에서 주입할 때 씁니다.

예:

- 실행 모드
- 기능 플래그
- 외부 API 주소
- 설정 파일

Secret은 민감 정보를 주입할 때 씁니다.

예:

- API token
- password
- private key

주의:

- Secret은 단순 base64 인코딩 형태로 보일 수 있습니다.
- 운영에서는 RBAC, etcd 암호화, 외부 secret manager 연동까지 고려해야 합니다.

### Volume

컨테이너 파일 시스템은 기본적으로 컨테이너 생명주기와 강하게 묶여 있습니다. Volume은 Pod에 파일 저장 공간이나 설정 파일을 연결할 때 사용합니다.

Pod 안의 여러 컨테이너는 같은 Volume을 각자 다른 경로에 마운트할 수 있습니다.

```text
app container       -> /var/log/app 에 로그 기록
log-agent container -> /logs 로 같은 Volume을 마운트해서 로그 수집
```

이렇게 하면 두 컨테이너가 파일을 통해 데이터를 주고받을 수 있습니다. 다만 같은 파일을 동시에 쓰는 구조는 충돌과 데이터 손상을 만들 수 있으므로 주의해야 합니다.

이번 실습의 `emptyDir`:

- Pod가 생성될 때 비어 있는 디렉터리로 시작합니다.
- 같은 Pod 안에서는 컨테이너 재시작 후에도 유지될 수 있습니다.
- Pod가 삭제되면 데이터도 사라집니다.

영구 저장이 필요하면 `PersistentVolume`과 `PersistentVolumeClaim`을 사용합니다.

## 2. ConfigMap과 Secret 생성

```bash
kubectl config set-context --current --namespace=k8s-lab
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
```

확인:

```bash
kubectl get configmap
kubectl get secret
kubectl describe configmap app-config
```

Secret 값은 기본 출력에서 가려집니다. 학습 목적으로만 디코딩해 봅니다.

```bash
kubectl get secret app-secret -o jsonpath='{.data.APP_TOKEN}' | base64 -d
echo
```

중요 포인트:

- ConfigMap은 일반 설정값에 씁니다.
- Secret은 토큰, 비밀번호 같은 민감 값에 씁니다.
- Secret은 etcd에 저장되므로 운영에서는 RBAC, 암호화, 외부 Secret 관리까지 같이 고려해야 합니다.

## 3. 설정을 환경 변수로 주입

```bash
kubectl apply -f deployment-config-demo.yaml
kubectl rollout status deployment/config-demo
kubectl get pods -l app=config-demo
```

Pod 안에서 환경 변수 확인:

```bash
POD_NAME=$(kubectl get pod -l app=config-demo -o jsonpath='{.items[0].metadata.name}')
kubectl exec "$POD_NAME" -- printenv APP_MODE
kubectl exec "$POD_NAME" -- printenv APP_TOKEN
```

## 4. ConfigMap을 파일로 마운트

`deployment-config-demo.yaml`은 ConfigMap을 `/etc/app/config` 경로에도 파일로 마운트합니다.

```bash
kubectl exec "$POD_NAME" -- ls -l /etc/app/config
kubectl exec "$POD_NAME" -- cat /etc/app/config/message
```

## 5. emptyDir Volume 확인

같은 Deployment에는 `emptyDir` Volume이 `/cache`에 연결되어 있습니다.

```bash
kubectl exec "$POD_NAME" -- sh -c 'date > /cache/created-at.txt'
kubectl exec "$POD_NAME" -- ls -l /cache
kubectl exec "$POD_NAME" -- ls -l /cache/created-at.txt
kubectl exec "$POD_NAME" -- cat /cache/created-at.txt
```

컨테이너 프로세스가 살아 있는 동안에는 파일이 유지됩니다. 하지만 Pod가 삭제되어 새로 만들어지면 `emptyDir` 내용은 사라집니다.

```bash
kubectl delete pod "$POD_NAME"
kubectl rollout status deployment/config-demo
NEW_POD=$(kubectl get pod -l app=config-demo -o jsonpath='{.items[0].metadata.name}')
kubectl exec "$NEW_POD" -- ls -l /cache
kubectl exec "$NEW_POD" -- sh -c 'ls -l /cache/created-at.txt || true'
```

새 Pod에서 `/cache/created-at.txt`가 `No such file or directory`로 나오면 `emptyDir` 데이터가 Pod 삭제와 함께 사라진 것입니다.

중요 포인트:

- `emptyDir`은 Pod 생명주기와 같이 갑니다.
- 데이터베이스 같은 영구 데이터는 PersistentVolume/PersistentVolumeClaim을 사용해야 합니다.
- 이번 2시간 실습에서는 영구 볼륨은 개념만 짚고 넘어갑니다.

## 체크포인트

```bash
kubectl get deployment config-demo
kubectl exec "$NEW_POD" -- printenv APP_MODE
kubectl exec "$NEW_POD" -- cat /etc/app/config/message
```
