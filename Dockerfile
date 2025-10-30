# 1. Базовый образ: Используем Debian 11 (Bullseye)
FROM debian:11

# Устанавливаем переменную окружения для токена 9hits
# **ОБЯЗАТЕЛЬНО ПРОВЕРЬТЕ ИЛИ ЗАМЕНИТЕ ВАШ ТОКЕН ЗДЕСЬ!**
ENV NINEHITS_TOKEN="701db1d250a23a8f72ba7c3e79fb2c79"

# 2. Установка ВСЕХ необходимых зависимостей в одном слое
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Основные утилиты
    apt-utils bash procps vim curl wget tar git \
    # Зависимости для 9hits
    bzip2 sudo psmisc bc netcat-openbsd \
    # Зависимости для Headless/Xvfb/Chromium (включая xauth)
    xvfb chromium xauth \
    libxrender1 libxrandr2 libcanberra-gtk-module libxss1 libxtst6 \
    libnss3 libgtk-3-0 libgbm1 libatspi2.0-0 libatomic1 \
    && rm -rf /var/lib/apt/lists/*

# 3. Установка 9hits
RUN curl -sSLk https://9hitste.github.io/install/3.0.4/linux.sh | \
    bash -s -- --token=$NINEHITS_TOKEN --mode=bot --allow-crypto=no --hide-browser --cache-del=200

# 4. Копирование папки config
# Копируем вашу папку 'config' из репозитория в каталог установки 9hits
COPY config /home/_9hits/9hitsv3-linux64/config

# 5. Команда запуска (PID 1) - Самый важный шаг
# Эта сложная команда выполняет три действия:
# 1. Xvfb :99 ... & : Запуск виртуального дисплея в фоне.
# 2. DISPLAY=:99 ... & : Запуск 9hits с указанием дисплея в фоне.
# 3. tail -f /dev/null: Удерживает контейнер от завершения.
CMD ["/bin/bash", "-c", "Xvfb :99 -screen 0 1024x768x24 & DISPLAY=:99 /home/_9hits/9hitsv3-linux64/9hits --no-sandbox --disable-dev-shm-usage & tail -f /dev/null"]
