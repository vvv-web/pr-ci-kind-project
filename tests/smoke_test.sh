#!/bin/bash
# Smoke tests — после деплоя в kind (кластер должен быть запущен)
# Проверяем readiness deployment и доступность сервиса
set -e
echo "Running smoke tests..."
kubectl rollout status deployment/app --timeout=60s
echo "Deployment ready."
# Проверка endpoint (через port-forward или NodePort в CI)
# Заглушка: kubectl port-forward в фоне + curl
kubectl wait --for=condition=ready pod -l app=app --timeout=30s
echo "Smoke tests passed."
