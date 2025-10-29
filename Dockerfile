FROM debian:11-slim

# 1. Установка ВСЕХ зависимостей как у вас
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y bzip2 libcanberra-gtk-module libxss1 sed tar libxtst6 libnss3 wget psmisc bc libgtk-3-0 libgbm-dev libatspi2.0-0 libatomic1 curl sudo dbus-x11 xvfb libasound2 libx11-xcb1 libxcomposite1 libxrandr2 libxcursor1 libxi6 libxtst6 libxss1 libnss3 libcups2 libxdamage1 libpango-1.0-0 libatk1.0-0 libatk-bridge2.0-0 libc6

# 2. Установка 9Hits (ТОЧНО ваша команда)
RUN curl -sSLk https://9hitste.github.io/install/3.0.4/linux.sh | sudo bash -s -- --token=701db1d250a23a8f72ba7c3e79fb2c79 --mode=bot --allow-crypto=no --hide-browser --schedule-reset=1 --cache-del=200 --create-swap=10G

# 3. Создаем симлинк для совместимости
RUN ln -s /home/_9hits/9hitsv3-linux64/9hits /nh.sh

# 4. Установка порта
ENV PORT 8000
EXPOSE 8000

# 5. КОМАНДА ЗАПУСКА
CMD bash -c " \
    # --- ШАГ А: HEALTH CHECK ---
    while true; do echo -e 'HTTP/1.1 200 OK\r\n\r\nOK' | nc -l -p \${PORT} -q 1; done & \
    \
    # --- ШАГ Б: ЗАПУСК ПРИЛОЖЕНИЯ (ваша точная команда) ---
    /nh.sh --token=701db1d250a23a8f72ba7c3e79fb2c79 --mode=bot --allow-crypto=no --hide-browser --cache-del=200 --create-swap=10G --no-sandbox --disable-dev-shm-usage --disable-gpu --headless & \
    \
    sleep 70; \
    \
    # --- ШАГ В: КОПИРОВАНИЕ КОНФИГОВ ---
    echo 'Начинаю копирование конфигурации...' && \
    mkdir -p /etc/9hitsv3-linux64/config/ && \
    wget -q -O /tmp/main.tar.gz https://github.com/fathyq/fathyq/archive/main.tar.gz && \
    tar -xzf /tmp/main.tar.gz -C /tmp && \
    cp -r /tmp/fathyq-main/config/* /etc/9hitsv3-linux64/config/ && \
    rm -rf /tmp/main.tar.gz /tmp/fathyq-main && \
    echo 'Копирование конфигурации завершено.'; \
    \
    # --- ШАГ Г: УДЕРЖАНИЕ КОНТЕЙНЕРА ---
    echo '=== КОНТЕЙНЕР ЗАПУЩЕН ===' && \
    echo 'Проверка процессов:' && \
    ps aux | grep -i 9hit && \
    tail -f /dev/null \
"
