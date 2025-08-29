# 🔧 DebianForge

[![Version](https://img.shields.io/badge/version-0.9.8_alpha-orange.svg)](https://github.com/mishagin-dev/DebianForge)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/status-active%20development-brightgreen.svg)](https://github.com/mishagin-dev/DebianForge)
[![Platform](https://img.shields.io/badge/platform-Debian%2013-orange.svg)](https://www.debian.org/)
[![Shell](https://img.shields.io/badge/shell-Bash%205.0+-lightgrey.svg)](https://www.gnu.org/software/bash/)
[![Architecture](https://img.shields.io/badge/architecture-modular-blue.svg)](https://github.com/mishagin-dev/DebianForge)

Комплексное решение "все в одном" для оптимизации, аудита безопасности и администрирования серверов на базе Debian. Объединяет настройку производительности, усиление безопасности и автоматическую генерацию отчетов в едином интеллектуальном инструменте.

> **🇺🇸 English version**: [README.md](README.md)

## ✨ Что такое DebianForge?

DebianForge - это интеллектуальный инструментарий, который превращает серверы Debian в высокопроизводительные, безопасные и хорошо мониторимые системы. Он предназначен для системных администраторов, DevOps инженеров и всех, кто хочет оптимизировать свою инфраструктуру Debian.

## 🚀 Быстрый старт

### Требования
- **Debian 13** (протестировано и поддерживается)
- Bash 5.0+
- Права root или sudo

### Установка
```bash
git clone https://github.com/mishagin-dev/DebianForge.git
cd DebianForge
chmod +x main.sh
sudo ./main.sh
```

### Базовое использование
```bash
# Интерактивный интерфейс
sudo ./main.sh

# Аудит безопасности
sudo ./main.sh security audit full markdown

# Бенчмарк производительности
sudo ./main.sh performance benchmark cpu html

# Обновление системы
sudo ./main.sh system update
```

## 🔒 Ключевые возможности

- **Оптимизация производительности**: Настройка CPU, памяти, диска, сети
- **Усиление безопасности**: Автоматическая оценка уязвимостей и настройка безопасности
- **Мониторинг в реальном времени**: Отслеживание ресурсов системы и метрик производительности
- **Комплексная отчетность**: Множество форматов (HTML, JSON, CSV, Markdown)
- **Модульная архитектура**: Легко расширять и настраивать

## 📚 Документация

- **📖 [Wiki](WIKI_ru.md)** - Полная документация, руководства и учебники
- **🔧 [Конфигурация](WIKI_ru.md#конфигурация)** - Настройка и кастомизация
- **📊 [Отчетность](WIKI_ru.md#отчетность)** - Генерация отчетов и форматы
- **🛠️ [Разработка](WIKI_ru.md#разработка)** - Вклад в проект и расширение

## 🤝 Поддержка

- **Issues**: [GitHub Issues](https://github.com/mishagin-dev/DebianForge/issues)
- **Discussions**: [GitHub Discussions](https://github.com/mishagin-dev/DebianForge/discussions)
- **Wiki**: [Project Wiki](WIKI_ru.md)

## 📄 Лицензия

MIT License - см. [LICENSE](LICENSE) для деталей.

---

**Создано с ❤️ для сообщества Debian**

*Для английской документации см. [README.md](README.md)*
