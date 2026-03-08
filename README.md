# PR-CI-Kind Project

**Цель:** PR-driven CI/CD для Kubernetes-приложения на kind с mock tests, smoke tests и Cursor Agent (restricted mode).

---

## Local run

```bash
# 1. Создать кластер
kind create cluster --name dev --wait 2m

# 2. Собрать образ
docker build -t local/app:dev ./app

# 3. Загрузить образ в kind
kind load docker-image local/app:dev --name dev

# 4. Задеплоить
kubectl apply -f k8s/

# 5. Smoke tests (пока кластер запущен)
./tests/smoke_test.sh

# 6. Проверить (опционально)
kubectl rollout status deployment/app
kubectl get pods -l app=app

# 7. Экспорт логов (для отладки)
kind export logs ./kind-logs --name dev

# 8. Удалить кластер
kind delete cluster --name dev
```

---

## PR workflow

1. Создай ветку и открой PR.
2. GitHub Actions автоматически запустит workflow при `opened`, `synchronize`, `reopened`.
3. Pipeline: mock tests → build → kind cluster → deploy → smoke tests.
4. При падении — артефакты `kind-logs` сохраняются.

---

## Failure triage

- **Mock tests failed** — проверь `tests/mock_test.sh`, структуру app/ и k8s/.
- **Build failed** — проверь `app/Dockerfile`, логи сборки.
- **Deploy failed** — проверь `k8s/` манифесты, `kubectl describe pod`.
- **Smoke failed** — проверь readiness probe, логи пода.
- **Артефакты:** при падении скачай `kind-logs` из вкладки Actions → Artifacts.

---

## How Cursor Agent is used safely

1. **Restricted mode:** агент только изменяет файлы в working directory.
2. **Запрещено:** создание веток, commit, push, PR-комментарии — это делает агент.
3. **Deterministic publish:** отдельный step выполняет `git add/commit/push` после агента.
4. **Требуется:** секрет `CURSOR_API_KEY` в Settings → Secrets → Actions.
5. **Запуск:** только при падении pipeline (`if: failure()`).

---

## Пример теста Cursor Agent (PR #2)

**Сценарий:** mock test намеренно сломан — проверяется несуществующий `app/missing.txt`.

| Этап | Результат |
|------|-----------|
| Mock tests | ❌ Failed |
| Cursor Agent | ✅ Удалил проверку `app/missing.txt`, улучшил тесты |
| Commit & push | ✅ `ci: cursor restricted fixes` — запушен в ветку PR |

**Ссылки:**
- [PR #2 — broken: mock test (Cursor Agent scenario)](https://github.com/vvv-web/pr-ci-kind-project/pull/2)
- [Actions — pr-ci-kind](https://github.com/vvv-web/pr-ci-kind-project/actions/workflows/pr-ci.yml)
