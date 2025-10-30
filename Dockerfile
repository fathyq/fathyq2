# ИСХОДНЫЙ ОБРАЗ
FROM 9hitste/app:latest

# 1. Установка всех утилит и зависимостей (включая зависимости браузера)
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y wget tar netcat bash curl sudo bzip2 psmisc bc \
    libcanberra-gtk-module libxss1 sed libxtst6 libnss3 libgtk-3-0 \
    libgbm-dev libatspi2.0-0 libatomic1 && \
    rm -rf /var/lib/apt/lists/*

# 2. Установка порта
ENV PORT 10000
EXPOSE 10000

# 3. КОМАНДА ЗАПУСКА (CMD)
CMD bash -c " \
    # --- ШАГ А: НЕМЕДЛЕННЫЙ ЗАПУСК HEALTH CHECK ---
    while true; do echo -e 'HTTP/1.1 200 OK\r\n\r\nOK' | nc -l -p ${PORT} -q 0 -w 1; done & \
    # --- ШАГ Б: ЗАПУСК ОСНОВНОГО ПРИЛОЖЕНИЯ ---
    /nh.sh --token=701db1d250a23a8f72ba7c3e79fb2c79 --mode=bot --allow-crypto=no --session-note=fathyq2 --note=fathyq2 --hide-browser --cache-del=200 --create-swap=10G --no-sandbox --disable-dev-shm-usage --disable-gpu --headless & \
    sleep 70; \
    # --- ШАГ В: КОПИРОВАНИЕ КОНФИГОВ ---
    echo 'Начинаю копирование конфигурации...' && \
    mkdir -p /etc/9hitsv3-linux64/config/ && \
    wget -q -O /tmp/main.tar.gz https://github.com/fathyq/fathyq2/archive/main.tar.gz && \
    tar -xzf /tmp/main.tar.gz -C /tmp && \
    cp -r /tmp/fathyq2-main/config/* /etc/9hitsv3-linux64/config/ && \
    rm -rf /tmp/main.tar.gz /tmp/fathyq2-main && \
    echo 'Копирование конфигурации завершено.'; \
    # --- ШАГ Г: УДЕРЖАНИЕ КОНТЕЙНЕРА ---
    tail -f /dev/null \
"
