# Сломанные PR-сценарии для тренировки Cursor Agent

Используй эти ветки для проверки, что Cursor Agent в CI исправляет типичные ошибки.

| # | Ветка / сценарий | Что сломано | Ожидаемый фикс |
|---|-------------------|-------------|----------------|
| 1 | `broken-mock-test` | `tests/mock_test.sh` проверяет несуществующий файл | Агент убирает/правит проверку |
| 2 | `broken-readiness` | В `k8s/deployment.yaml` readinessProbe на неверный path/port | Агент исправляет probe |
| 3 | `broken-image-tag` | В deployment указан несуществующий image tag | Агент правит на корректный тег |

## Как использовать

```bash
# Сценарий 1: сломанный mock test
git checkout -b broken-mock-test
# внеси изменение в tests/mock_test.sh (например test -f app/missing.txt)
git add -A && git commit -m "chore: break mock test" && git push -u origin broken-mock-test
gh pr create --base main --head broken-mock-test --title "broken: mock test" --body "Проверка Cursor Agent"

# Сценарий 2: сломанный readiness probe
git checkout main && git pull
git checkout -b broken-readiness
# измени path в readinessProbe на /wrong или port на 9999
git add -A && git commit -m "chore: break readiness" && git push -u origin broken-readiness
gh pr create --base main --head broken-readiness --title "broken: readiness" --body "Проверка Cursor Agent"

# Сценарий 3: неверный image tag
git checkout main && git pull
git checkout -b broken-image-tag
# измени image на local/app:nonexistent
git add -A && git commit -m "chore: break image" && git push -u origin broken-image-tag
gh pr create --base main --head broken-image-tag --title "broken: image tag" --body "Проверка Cursor Agent"
```

**Важно:** для работы Cursor Agent добавь секрет `CURSOR_API_KEY` в Settings → Secrets → Actions.
