# Prompt Library: AI Quantum Mesh App Ecosystem

This document aggregates system prompts to guide development across Mesh, AI, userver, Web3, Quantum, CI/CD, UX, and Infra layers. Use them as seeds for tasks, ADRs, and tickets.

## I. Общие системные промпты
1. System Refactor Prompt — Проанализируй весь проект и предложи архитектурное улучшение, сохранив обратную совместимость и расширяемость под mesh-сети и userver backend.
2. Platform Builder Prompt — Сгенерируй папки и файлы для платформ: Android, iOS, macOS, Windows, Linux, Web, AuroraOS, HarmonyOS.
3. Cross-Compile Prompt — Подготовь кросс-платформенные CMake и Flutter build-скрипты с учётом Yandex Infrastructure SDK и userver.
4. Codebase Organizer Prompt — Проведи полную сортировку исходников, документации и заметок по каталогам `/core`, `/frontend`, `/backend`, `/infra`, `/ai`, `/docs`, `/mesh`.
5. Quantum Core Prompt — Добавь модуль `ai_quantum_core` для обучения моделей на графах связей устройств.

## II. Mesh-сети и оффлайн-архитектура
6. Bluetooth Mesh Prompt — Реализуй оффлайн-передачу через BLE Advertising + Mesh API с шифрованием.
7. Wi‑Fi Direct Mesh Prompt — Настрой P2P обмен пакетами через Wi‑Fi Direct без интернета.
8. Multicast Discovery Prompt — Добавь UDP multicast обнаружение узлов и хранение топологии.
9. Mesh Voting App Prompt — Оффлайн‑голосование с majority‑agreement.
10. Mesh Sync Protocol Prompt — Протокол синхронизации после выхода узла в онлайн.

## III. Интеграция с Yandex и городской инфраструктурой
11–15. Подключение API, оффлайн‑кэш, городские мосты и userver‑бриджи, GeoAI маршрутизация.

## IV. AI, Quantum & GEN AI
16–20. RL‑адаптивный UI, оффлайн ассистент, квантовая оптимизация маршрутов, self‑evolving CI/CD, AI governance.

## V. Web 3–6 & Blockchain Layer
21–25. Мосты с Polkadot/Substrate, смарт‑контракты для голосований, DID, Web5 vault, Web6 AI consensus.

## VI. Документация и DevOps
26–30. README/CHANGELOG/GOVERNANCE, универсальные CI, инфра‑доки.

## VII. UI/UX & Design System
31–35. Дизайн‑система, AI‑адаптация UX, оффлайн индикатор, голографический UI, доступность.

## VIII. Мультимодальные возможности
36–40. Голосовые сообщения оффлайн, TTS, AR‑визуализация сети, жесты, CV‑навигация.

## IX. Quantum Engineering Layer
41–45. Квантовый симулятор, квантовое шифрование, мост классика‑квант, AI‑фидбек, гибридный консенсус.

## X. Масштабирование и бэкенд
46–50. Микросервисы userver, PostgreSQL‑кластер, Redis mesh cache, мониторинг, безопасность.

## XI. Расширения и мосты
51–55. Мосты AI/Blockchain, Vibe‑транспорт, Data Lake, Backlog Intelligence.


