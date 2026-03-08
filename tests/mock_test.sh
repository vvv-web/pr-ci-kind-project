#!/bin/bash
# Mock/unit tests — быстрые проверки до Kubernetes
# Добавь сюда реальные тесты (pytest, go test и т.п.)
set -e
echo "Running mock tests..."
# Пока заглушка: проверяем наличие ожидаемых файлов (запуск из корня репо)
# BROKEN: для теста Cursor Agent — проверка несуществующего файла
test -f app/missing.txt || { echo "app/missing.txt missing"; exit 1; }
test -f app/Dockerfile || { echo "app/Dockerfile missing"; exit 1; }
test -f app/index.html || { echo "app/index.html missing"; exit 1; }
test -d k8s || { echo "k8s/ missing"; exit 1; }
echo "Mock tests passed."
