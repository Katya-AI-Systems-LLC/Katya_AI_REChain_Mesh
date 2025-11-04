# 🇷🇺 Российская инфраструктура Katya Mesh

Поддержка отечественных облачных решений и сервисов.

## 🌐 Поддерживаемые российские платформы

### 1. Yandex Cloud
- **Kubernetes** - Managed Service for Kubernetes
- **PostgreSQL** - Managed PostgreSQL
- **Redis** - Managed Redis
- **Terraform Provider** - Полная поддержка Infrastructure as Code

### 2. VK Cloud (бывший MCS)
- **Kubernetes** - VK Cloud Kubernetes
- **Object Storage** - S3-совместимое хранилище
- **Managed Databases** - PostgreSQL, Redis, MongoDB

### 3. Selectel
- **Kubernetes** - Managed Kubernetes
- **OpenStack** - Полная поддержка OpenStack

### 4. Ростелеком Cloud
- **Kubernetes** - Kubernetes кластеры
- **Object Storage** - Хранилище данных

## 🚀 Быстрый старт с Yandex Cloud

```bash
cd terraform/yandex-cloud

# Создать terraform.tfvars
cat > terraform.tfvars <<EOF
yandex_token     = "your-oauth-token"
yandex_cloud_id  = "your-cloud-id"
yandex_folder_id = "your-folder-id"
redis_password    = "your-redis-password"
EOF

# Применить инфраструктуру
terraform init
terraform plan
terraform apply
```

## 📊 Сравнение платформ

| Платформа | Kubernetes | PostgreSQL | Redis | Цена (базовая) |
|-----------|-----------|------------|-------|----------------|
| Yandex Cloud | ✅ | ✅ | ✅ | ~11500₽/мес |
| VK Cloud | ✅ | ✅ | ✅ | ~10000₽/мес |
| Selectel | ✅ | ✅ | ⚠️ | ~12000₽/мес |
| Ростелеком Cloud | ✅ | ⚠️ | ⚠️ | ~13000₽/мес |

## 🔒 Безопасность

Все российские платформы обеспечивают:
- **Соответствие 152-ФЗ** - Требованиям защиты персональных данных
- **Локальное хранение** - Данные не покидают территорию РФ
- **Шифрование** - End-to-end шифрование данных
- **Аудит** - Логирование всех операций

## 📚 Документация

- [Yandex Cloud Terraform](terraform/yandex-cloud/)
- [Yandex Cloud Documentation](https://cloud.yandex.ru/docs/)
- [VK Cloud Documentation](https://mcs.mail.ru/docs/)
- [Selectel Documentation](https://selectel.ru/docs/)

## 🛠 Развертывание

### Yandex Cloud

```bash
# Terraform
cd terraform/yandex-cloud
terraform apply

# Helm
helm install katya-mesh ./helm/katya-mesh \
  --set env[0].value=postgresql://user:pass@host:5432/db \
  --set env[1].value=redis://host:6379
```

### Docker Compose (локально)

```bash
docker-compose up -d
```

## 📈 Мониторинг

- **Prometheus** - Метрики и алерты
- **Grafana** - Визуализация и дашборды
- **Yandex Monitoring** - Интеграция с Yandex Cloud

## 🔗 Интеграция с российскими сервисами

- **Yandex Object Storage** - Хранилище файлов
- **Yandex Message Queue** - Очереди сообщений
- **Yandex Data Streams** - Потоковая обработка данных
- **VK Cloud Object Storage** - Альтернативное хранилище

## 💰 Стоимость

### Базовая конфигурация (Yandex Cloud)
- Kubernetes Cluster: ~2000₽/мес
- Worker Nodes (s2.micro x2): ~6000₽/мес
- PostgreSQL: ~2000₽/мес
- Redis: ~1500₽/мес
- **Итого**: ~11500₽/мес

### Production конфигурация
- Kubernetes Cluster: ~2000₽/мес
- Worker Nodes (s2.small x3): ~18000₽/мес
- PostgreSQL (s2.small): ~5000₽/мес
- Redis: ~3000₽/мес
- **Итого**: ~28000₽/мес

## 📞 Поддержка

- **Yandex Cloud Support**: [cloud.yandex.ru/support](https://cloud.yandex.ru/support)
- **VK Cloud Support**: [mcs.mail.ru/support](https://mcs.mail.ru/support)
- **Selectel Support**: [selectel.ru/support](https://selectel.ru/support)

