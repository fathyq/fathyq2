# ИСХОДНЫЙ ОБРАЗ
FROM debian:11

# 1. Установка всех необходимых зависимостей и утилит
# libgbm1 вместо libgbm-dev для запуска, а не сборки.
# bzip2 для распаковки .tar.bz2.
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        bzip2 libcanberra-gtk-module libxss1 sed tar libxtst6 \
        libnss3 wget psmisc bc libgtk-3-0 libgbm1 libatspi2.0-0 \
        libatomic1 curl sudo netcat-openbsd procps git && \
    rm -rf /var/lib/apt/lists/*

# Создаем рабочую директорию и определяем путь установки
WORKDIR /root
ENV INSTALL_DIR="/root/_9hits/9hitsv3-linux64"

# 2. Прямая загрузка и распаковка 9Hits (Исправление ошибки сборки)
# Используем curl -L, чтобы следовать редиректам MediaFire для загрузки файла.
RUN echo "Прямая загрузка и установка 9Hits..." && \
    # Загружаем TAR.BZ2 по предоставленной ссылке
    curl -L --insecure 'https://www.mediafire.com/file/dhky3qux3f8lzxo/9hitsv3-linux64.tar.bz2/file' -o /tmp/9hits.tar.bz2 && \
    # Создаем папку для распаковки
    mkdir -p /root/_9hits && \
    # Распаковываем TAR.BZ2 в /root/_9hits
    tar -xjf /tmp/9hits.tar.bz2 -C /root/_9hits && \
    rm /tmp/9hits.tar.bz2 && \
    # Убеждаемся, что исполняемый файл имеет нужные права
    chmod +x $INSTALL_DIR/9hits && \
    echo "Установка 9Hits завершена."

# 3. Настройка порта
ENV PORT 8000
EXPOSE 8000

# 4. КОМАНДА ЗАПУСКА
CMD bash -c " \
    # --- ШАГ А: HEALTH CHECK (в фоне) ---
    while true; do echo -e 'HTTP/1.1 200 OK\r\n\r\nOK' | nc -l -p \${PORT} -k -w 1; done & \
    \
    # --- ШАГ Б: СОЗДАНИЕ SWAP (в соответствии с параметром --create-swap=10G) ---
    echo 'Создаю файл подкачки 10G...' && \
    fallocate -l 10G /swapfile && \
    chmod 600 /swapfile && \
    mkswap /swapfile && \
    swapon /swapfile && \
    echo 'Файл подкачки создан.' && \
    \
    # --- ШАГ В: КОПИРОВАНИЕ КОНФИГОВ ---
    echo 'Начинаю копирование конфигурации...' && \
    INSTALL_DIR='/root/_9hits/9hitsv3-linux64' && \
    mkdir -p \$INSTALL_DIR/config/ && \
    wget -q -O /tmp/main.tar.gz https://github.com/fathyq/fathyq/archive/main.tar.gz && \
    tar -xzf /tmp/main.tar.gz -C /tmp && \
    cp -r /tmp/fathyq-main/config/* \$INSTALL_DIR/config/ && \
    rm -rf /tmp/main.tar.gz /tmp/fathyq-main && \
    echo 'Копирование конфигурации завершено.' && \
    \
    # --- ШАГ Г: ЗАПУСК 9Hits (Блокирующий процесс) ---
    # Используем exec для PID 1. Добавлен флаг --no-sandbox для работы в контейнере.
    exec \$INSTALL_DIR/9hits \
        --token=701db1d250a23a8f72ba7c3e79fb2c79 \
        --mode=bot \
        --allow-crypto=no \
        --hide-browser \
        --cache-del=200 \
        --create-swap=10G \
        --no-sandbox \
"
