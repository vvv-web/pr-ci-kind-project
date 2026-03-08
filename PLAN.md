# PR-driven CI/CD для Kubernetes-приложения на Kind

**Цель:** Репозиторий, где каждый PR автоматически запускает mock/unit tests, поднимает kind-кластер, разворачивает приложение, выполняет smoke-проверки и при необходимости запускает Cursor Agent в restricted mode.

**Срок:** 2–4 недели  
**Стек:** kind v0.31.0, GitHub Actions, Cursor Agent, mock + smoke tests

---

## Декомпозиция плана

| # | Шаг | Статус | Зависимости |
|---|-----|--------|-------------|
| 1 | Подготовить репозиторий (структура app/, k8s/, tests/, .github/workflows/, .cursor/) | ✅ | — |
| 2 | Поднять локальную базу на kind (create → deploy → verify → delete) | ✅ | Шаг 1 |
| 3 | Добавить mock/unit tests + smoke tests после деплоя | ⬜ | Шаг 2 |
| 4 | Собрать GitHub Actions workflow для PR | ✅ | Шаги 2–3 |
| 5 | Подключить Cursor Agent в restricted mode | ⬜ | Шаг 4 |
| 6 | Настроить минимальные permissions и deterministic publish | ⬜ | Шаг 5 |
| 7 | Добавить troubleshooting-артефакты и критерии качества | ⬜ | Шаг 4 |

---

## Шаг 1: Подготовка репозитория

**Цель:** Структура, которая действительно меняется в PR (не только README).

**Структура:**
```
pr-ci-kind-project/
├── app/                 # Исходники приложения + Dockerfile
├── k8s/                 # Kubernetes manifests (deployment, service)
├── charts/              # или Helm charts (опционально)
├── tests/               # mock/unit и smoke-скрипты
├── .github/workflows/   # PR CI workflow
├── .cursor/             # Cursor env/config
└── README.md
```

**DoD шага 1:**
- [ ] `mkdir -p pr-ci-kind-project/{app,k8s,tests,.github/workflows,.cursor}`
- [ ] Минимальный Dockerfile в app/
- [ ] Минимальные k8s манифесты в k8s/
- [ ] README с разделами Local run, PR workflow (заготовки)

---

## Шаг 2: Локальная база на kind

**Цель:** Воспроизводимый цикл без ручных правок.

**Команды (по kind Quick Start):**
- `kind create cluster --name pr-ci --wait 2m`
- `kind get clusters`
- `kind load docker-image <image> --name pr-ci`
- `kind delete cluster --name pr-ci`

**DoD шага 2:**
- [ ] `kind create cluster` → приложение деплоится
- [ ] `kubectl` проверяет pod/service доступность
- [ ] `kind delete cluster` завершает цикл
- [ ] Цикл воспроизводим между запусками

---

## Шаг 3: Mock/unit + smoke tests

**Цель:** Два уровня: быстрые тесты до K8s, smoke после деплоя.

**Mock/unit:** быстрые проверки до `kind create cluster`  
**Smoke:** после деплоя — deployment ready, service отвечает, хотя бы один сценарий.

**DoD шага 3:**
- [ ] Mock/unit тесты в tests/ (или в app/)
- [ ] Smoke-скрипт проверяет readiness и endpoint
- [ ] Smoke подтверждает не только `kubectl apply`, а реальную работу

---

## Шаг 4: GitHub Actions workflow

**Цель:** Pipeline на `pull_request` + `synchronize`.

**Последовательность:**
1. checkout
2. install kind
3. create cluster
4. mock tests
5. build image
6. load image into kind
7. deploy manifests
8. smoke tests
9. export logs on failure
10. delete cluster

**DoD шага 4:**
- [ ] Workflow на `pull_request` (opened, synchronize, reopened)
- [ ] Полный pipeline без ручного вмешательства
- [ ] `kind load docker-image` без внешнего registry

---

## Шаг 5: Cursor Agent restricted mode

**Цель:** Агент меняет файлы, не делает commit/push/comment сам.

**DoD шага 5:**
- [ ] Отдельный step/job с cursor-agent
- [ ] Агент только анализирует diff и меняет файлы
- [ ] Не создаёт branches, не коммитит, не пушит

---

## Шаг 6: Permissions и deterministic publish

**Цель:** Least-privilege, воспроизводимый publish.

**DoD шага 6:**
- [ ] `contents: write`, `pull-requests: write` только при необходимости
- [ ] Отдельный step: `git add/commit/push` после агента
- [ ] Auditability — явные git-операции в pipeline

---

## Шаг 7: Troubleshooting-артефакты

**Цель:** По любому фейлу — понятная диагностика.

**DoD шага 7:**
- [ ] `kind export logs` на failure
- [ ] Артефакты тестов
- [ ] README: Failure triage, How Cursor Agent is used safely

---

## Итоговый DoD проекта

- [x] PR → автоматический запуск workflow
- [ ] Ephemeral kind cluster, деплой без ручного вмешательства
- [ ] Mock/unit до K8s, smoke после деплоя
- [ ] Артефакты при падении (kind logs и т.п.)
- [ ] Cursor Agent в restricted mode, publish отдельным step
- [ ] README: Local run, PR workflow, Failure triage, Cursor Agent safely
- [ ] 2–3 PR-сценария для тренировки (сломанный тест, манифест, image tag)

---

## Официальные документы

| Компонент | URL | Версия |
|-----------|-----|--------|
| kind Quick Start | https://kind.sigs.k8s.io/docs/user/quick-start/ | v0.31.0 |
| GitHub Actions | https://docs.github.com/en/actions | — |
| Workflow syntax | https://docs.github.com/actions/using-workflows/workflow-syntax-for-github-actions | — |
| Cursor Agent in GitHub Actions | https://docs.cursor.com/en/cli/github-actions | — |
| Cursor GitHub integration | https://docs.cursor.com/en/integrations/github | — |
