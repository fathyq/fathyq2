FROM debian:11

# 1. Установка ВСЕХ необходимых зависимостей
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash curl wget xvfb python3 procps netcat-openbsd unzip \
    libxrender1 libxrandr2 libcanberra-gtk-module libxss1 libxtst6 \
    libnss3 libgtk-3-0 libgbm1 libatspi2.0-0 libatomic1 \
    bzip2 sudo psmisc bc \
    && rm -rf /var/lib/apt/lists/*

# 2. Установка 9Hits
RUN curl -sSLk https://9hitste.github.io/install/3.0.4/linux.sh | \
    bash -s -- --token=701db1d250a23a8f72ba7c3e79fb2c79 --mode=bot --allow-crypto=no --cache-del=200

# 3. Копирование конфигов
RUN cd /tmp && \
    wget https://github.com/fathyq/fathyq/archive/main.zip -O repo.zip && \
    unzip -o repo.zip && \
    REPO_DIR=$(find . -maxdepth 1 -type d -name "fathyq-*" -print -quit) && \
    mkdir -p /home/_9hits/9hitsv3-linux64/config/ && \
    cp -rf $REPO_DIR/config/* /home/_9hits/9hitsv3-linux64/config/ && \
    rm -rf $REPO_DIR repo.zip

EXPOSE 8000

# 4. КОМАНДА ЗАПУСКА с автоперезапуском
CMD bash -c " \
    # Health Check \
    echo 'Запускаю Health Check...' && \
    python3 -m http.server 8000 & \
    \
    # Автозапуск 9Hits с перезапуском при падении \
    while true; do \
        echo '=== ЗАПУСК 9Hits ===' && \
        cd /home/_9hits/9hitsv3-linux64/ && \
        timeout 5m xvfb-run ./9hits \
            --token=701db1d250a23a8f72ba7c3e79fb2c79 \
            --mode=bot \
            --allow-crypto=no \
            --cache-del=200 \
            --no-sandbox \
            --single-process \
            --disable-dev-shm-usage \
            --disable-gpu \
            --headless 2>&1 || true \
        \
        echo '9Hits завершился, перезапуск через 10 секунд...' && \
        sleep 10 \
    done & \
    \
    echo 'Контейнер запущен' && \
    tail -f /dev/null \
"
