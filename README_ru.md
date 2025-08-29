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

- **📖 [Wiki](https://github.com/mishagin-dev/DebianForge/wiki/%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9)** - Полная документация, руководства и учебники
- **🔧 [Конфигурация](https://github.com/mishagin-dev/DebianForge/wiki/%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9#-%D0%BA%D0%BE%D0%BD%D1%84%D0%B8%D0%B3%D1%83%D1%80%D0%B0%D1%86%D0%B8%D1%8F)** - Настройка и кастомизация
- **📊 [Отчетность](https://github.com/mishagin-dev/DebianForge/wiki/%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9#-%D0%BE%D1%82%D1%87%D0%B5%D1%82%D0%BD%D0%BE%D1%81%D1%82%D1%8C)** - Генерация отчетов и форматы
- **🛠️ [Разработка](https://github.com/mishagin-dev/DebianForge/wiki/%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9#%EF%B8%8F-%D1%80%D0%B0%D0%B7%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%BA%D0%B0)** - Вклад в проект и расширение

## 🤝 Поддержка

- **Issues**: [GitHub Issues](https://github.com/mishagin-dev/DebianForge/issues)
- **Wiki**: [Project Wiki](https://github.com/mishagin-dev/DebianForge/wiki/%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9)

## 📄 Лицензия

MIT License - см. [LICENSE](LICENSE) для деталей.

---

**Создано с ❤️ для сообщества Debian**

*Для английской документации см. [README.md](README.md)*
