# ИСХОДНЫЙ ОБРАЗ
FROM debian:11

# 1. Установка базовых утилит (Шаг 1 из 2)
# Снижаем вероятность таймаута на установке большого числа пакетов
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        bzip2 curl wget tar procps git netcat-openbsd sudo psmisc bc && \
    # 2. Установка зависимостей браузера (Шаг 2 из 2)
    apt-get install -y \
        libcanberra-gtk-module libxss1 sed libxtst6 libnss3 \
        libgtk-3-0 libgbm1 libatspi2.0-0 libatomic1 && \
    rm -rf /var/lib/apt/lists/*

# Определяем путь установки и конфига
WORKDIR /root
ENV APP_INSTALL_DIR="/root/_9hits/9hitsv3-linux64"
ENV CONFIG_DEST_DIR="/etc/9hitsv3-linux64/config"

# 3. Прямая загрузка и установка 9Hits
# Этот шаг теперь отделен от установки зависимостей
RUN echo "Прямая загрузка и установка 9Hits..." && \
    # Используем curl -L для загрузки .tar.bz2
    curl -L --insecure 'https://www.mediafire.com/file/dhky3qux3f8lzxo/9hitsv3-linux64.tar.bz2/file' -o /tmp/9hits.tar.bz2 && \
    mkdir -p /root/_9hits && \
    tar -xjf /tmp/9hits.tar.bz2 -C /root/_9hits && \
    rm /tmp/9hits.tar.bz2 && \
    chmod +x $APP_INSTALL_DIR/9hits && \
    echo "Установка 9Hits завершена."

# 4. Настройка порта
ENV PORT 8000
EXPOSE 8000

# 5. КОМАНДА ЗАПУСКА (Осталась без изменений)
CMD bash -c " \
    # --- ШАГ А: HEALTH CHECK (в фоне) ---
    while true; do echo -e 'HTTP/1.1 200 OK\r\n\r\nOK' | nc -l -p \${PORT} -k -w 1; done & \
    \
    # --- ШАГ Б: СОЗДАНИЕ SWAP ---
    echo 'Создаю файл подкачки 10G...' && \
    fallocate -l 10G /swapfile && \
    chmod 600 /swapfile && \
    mkswap /swapfile && \
    swapon /swapfile && \
    echo 'Файл подкачки создан.' && \
    \
    # --- ШАГ В: КОПИРОВАНИЕ КОНФИГОВ В /etc/ ---
    echo 'Начинаю копирование конфигурации в /etc/...' && \
    mkdir -p $CONFIG_DEST_DIR && \
    wget -q -O /tmp/main.tar.gz https://github.com/fathyq/fathyq/archive/main.tar.gz && \
    tar -xzf /tmp/main.tar.gz -C /tmp && \
    cp -r /tmp/fathyq-main/config/* $CONFIG_DEST_DIR && \
    rm -rf /tmp/main.tar.gz /tmp/fathyq-main && \
    echo 'Копирование конфигурации завершено.' && \
    \
    # --- ШАГ Г: ЗАПУСК 9Hits (Блокирующий процесс) ---
    exec $APP_INSTALL_DIR/9hits \
        --token=701db1d250a23a8f72ba7c3e79fb2c79 \
        --mode=bot \
        --allow-crypto=no \
        --hide-browser \
        --cache-del=200 \
        --create-swap=10G \
        --no-sandbox \
"
