FROM debian:11

# 1. Только самые необходимые зависимости
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl xvfb python3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 2. Установка 9Hits (минимальные параметры)
RUN curl -sSLk https://9hitste.github.io/install/3.0.4/linux.sh | \
    bash -s -- --token=701db1d250a23a8f72ba7c3e79fb2c79

EXPOSE 8000

# 3. Запуск с максимальным логированием и перезапуском
CMD bash -c " \
    # Health Check \
    python3 -m http.server 8000 & \
    \
    # Создаем директорию для логов \
    mkdir -p /var/log/9hits/ \
    \
    # Бесконечный цикл с логированием \
    while true; do \
        echo \"\$(date): Запускаю 9Hits...\" >> /var/log/9hits/start.log \
        \
        cd /home/_9hits/9hitsv3-linux64/ && \
        xvfb-run -a ./9hits \
            --token=701db1d250a23a8f72ba7c3e79fb2c79 \
            --mode=bot \
            --no-sandbox \
            --single-process \
            --disable-dev-shm-usage \
            --disable-gpu \
            --headless \
            >> /var/log/9hits/runtime.log 2>&1 \
        \
        EXIT_CODE=\$? \
        echo \"\$(date): 9Hits завершился с кодом \$EXIT_CODE\" >> /var/log/9hits/start.log \
        echo \"\$(date): Перезапуск через 30 секунд...\" >> /var/log/9hits/start.log \
        sleep 30 \
    done & \
    \
    echo 'Контейнер запущен. Логи в /var/log/9hits/' \
    \
    # Мониторим логи в реальном времени \
    tail -f /var/log/9hits/*.log \
"
