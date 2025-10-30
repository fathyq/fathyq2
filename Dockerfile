FROM debian:11

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash curl wget git netcat-openbsd unzip \
    xvfb chromium xauth \
    libxrender1 libxrandr2 libcanberra-gtk-module libxss1 libxtst6 \
    libnss3 libgtk-3-0 libgbm1 libatspi2.0-0 libatomic1 \
    bzip2 sudo psmisc bc python3 \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSLk https://9hitste.github.io/install/3.0.4/linux.sh | \
    bash -s -- --token=701db1d250a23a8f72ba7c3e79fb2c79 --mode=bot --allow-crypto=no --hide-browser --cache-del=200

RUN cd /tmp && \
    wget https://github.com/fathyq/fathyq/archive/main.zip -O repo.zip && \
    unzip -o repo.zip && \
    REPO_DIR=$(find . -maxdepth 1 -type d -name "fathyq-*" -print -quit) && \
    mkdir -p /home/_9hits/9hitsv3-linux64/config/ && \
    cp -rf $REPO_DIR/config/* /home/_9hits/9hitsv3-linux64/config/ && \
    rm -rf $REPO_DIR repo.zip

EXPOSE 8000

CMD bash -c " \
    # Health Check \
    python3 -m http.server 8000 & \
    \
    echo '=== ДИАГНОСТИКА ЗАПУСКА ===' && \
    \
    # Проверка файлов \
    echo '1. Файлы 9Hits:' && \
    ls -la /home/_9hits/9hitsv3-linux64/ && \
    \
    echo '2. Исполняемый файл:' && \
    file /home/_9hits/9hitsv3-linux64/9hits && \
    \
    echo '3. Конфиги:' && \
    ls -la /home/_9hits/9hitsv3-linux64/config/ && \
    \
    # Тестовый запуск \
    echo '4. Тестовый запуск (версия):' && \
    cd /home/_9hits/9hitsv3-linux64/ && \
    ./9hits --version || echo 'Не удалось получить версию' && \
    \
    # Основной запуск с логированием \
    echo '5. Основной запуск...' && \
    xvfb-run ./9hits \
    --token=701db1d250a23a8f72ba7c3e79fb2c79 \
    --mode=bot \
    --allow-crypto=no \
    --hide-browser \
    --cache-del=200 \
    --no-sandbox \
    --disable-dev-shm-usage \
    --headless 2>&1 | tee /tmp/9hits.log & \
    \
    # Мониторинг \
    echo '6. Ожидаю и проверяю процессы...' && \
    sleep 30 && \
    echo '=== ПРОЦЕССЫ ===' && \
    ps aux && \
    echo '=== ЛОГИ 9Hits ===' && \
    tail -20 /tmp/9hits.log || echo 'Логи не созданы' && \
    \
    echo '=== ДИАГНОСТИКА ЗАВЕРШЕНА ===' && \
    tail -f /dev/null \
"FROM debian:11

# Шаг 1: Установка ВСЕХ зависимостей
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash curl wget git netcat-openbsd unzip \
    xvfb chromium xauth \
    libxrender1 libxrandr2 libcanberra-gtk-module libxss1 libxtst6 \
    libnss3 libgtk-3-0 libgbm1 libatspi2.0-0 libatomic1 \
    bzip2 sudo psmisc bc \
    && rm -rf /var/lib/apt/lists/*

# Шаг 2: Установка 9Hits
RUN curl -sSLk https://9hitste.github.io/install/3.0.4/linux.sh | \
    bash -s -- --token=701db1d250a23a8f72ba7c3e79fb2c79 --mode=bot --allow-crypto=no --hide-browser --cache-del=200

# Шаг 3: Копирование конфигов ПРИ СБОРКЕ
RUN cd /tmp && \
    wget https://github.com/fathyq/fathyq/archive/main.zip -O repo.zip && \
    unzip -o repo.zip && \
    REPO_DIR=$(find . -maxdepth 1 -type d -name "fathyq-*" -print -quit) && \
    mkdir -p /home/_9hits/9hitsv3-linux64/config/ && \
    cp -rf $REPO_DIR/config/* /home/_9hits/9hitsv3-linux64/config/ && \
    rm -rf $REPO_DIR repo.zip

EXPOSE 8000

# Шаг 4: КОМАНДА ЗАПУСКА
CMD bash -c " \
    # Health Check \
    nc -l -p 8000 -k & \
    \
    # Запуск 9Hits в xvfb \
    echo 'Запускаю 9Hits...' && \
    xvfb-run /home/_9hits/9hitsv3-linux64/9hits \
    --token=701db1d250a23a8f72ba7c3e79fb2c79 \
    --mode=bot \
    --allow-crypto=no \
    --hide-browser \
    --cache-del=200 \
    --no-sandbox \
    --disable-dev-shm-usage \
    --headless & \
    \
    echo 'Приложение запущено' && \
    tail -f /dev/null \
"
