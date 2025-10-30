# 1. Базовый образ: Используем Debian 11 (Bullseye)
FROM debian:11

# Устанавливаем переменные окружения для токена (для чистоты)
# **ОБЯЗАТЕЛЬНО ЗАМЕНИТЕ ВАШ ТОКЕН ЗДЕСЬ ИЛИ В НАСТРОЙКАХ КОYEB!**
ENV NINEHITS_TOKEN="701db1d250a23a8f72ba7c3e79fb2c79"

# Устанавливаем порт для Health Check Koyeb (если 9hits не слушает порт, это просто документация)
EXPOSE 8000

# 2. Установка ВСЕХ необходимых зависимостей в одном слое
# Включаем curl, wget, git, xvfb, chromium и все библиотеки, необходимые для headless-браузера.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl wget tar git procps \
        # Зависимости для 9hits
        bzip2 sudo psmisc bc netcat-openbsd \
        # Зависимости для Headless/Xvfb/Chromium
        xvfb chromium \
        libxrender1 libxrandr2 libcanberra-gtk-module libxss1 libxtst6 \
        libnss3 libgtk-3-0 libgbm1 libatspi2.0-0 libatomic1 \
    # Очистка кэша apt для уменьшения размера образа
    && rm -rf /var/lib/apt/lists/*

# 3. Установка 9hits
# Запускаем скрипт установки с токеном и в режиме бота (БЕЗ 'sudo', так как мы root)
RUN curl -sSLk https://9hitste.github.io/install/3.0.4/linux.sh | \
    bash -s -- --token=$NINEHITS_TOKEN --mode=bot --allow-crypto=no --hide-browser --cache-del=200

# 4. Копирование папки config
# Копируем вашу папку 'config' из репозитория в каталог установки 9hits
COPY config /home/_9hits/9hitsv3-linux64/config

# 5. Команда запуска
# Запускаем 9hits через xvfb-run, чтобы создать виртуальный дисплей.
# Используем флаги --no-sandbox и --disable-dev-shm-usage для надежной работы в контейнерах.
# ЭТОТ ПРОЦЕСС БУДЕТ PID 1, что позволит ему работать постоянно.
CMD ["xvfb-run", "/home/_9hits/9hitsv3-linux64/9hits", "--no-sandbox", "--disable-dev-shm-usage"]
