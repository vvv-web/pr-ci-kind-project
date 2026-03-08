#!/bin/bash
# Mock/unit tests — быстрые проверки до Kubernetes
# Добавь сюда реальные тесты (pytest, go test и т.п.)
set -euo pipefail
echo "Running mock tests..."
# Пока заглушка: проверяем наличие ожидаемых файлов (запуск из корня репо)
test -f app/Dockerfile || { echo "app/Dockerfile missing"; exit 1; }
test -f app/index.html || { echo "app/index.html missing"; exit 1; }
test -f k8s/deployment.yaml || { echo "k8s/deployment.yaml missing"; exit 1; }
test -f k8s/service.yaml || { echo "k8s/service.yaml missing"; exit 1; }
echo "Mock tests passed."
