# Полная версия Debian 11
FROM debian:11

# 1. Установка всех зависимостей в один слой
RUN apt-get update && \
    apt-get upgrade -y && \
    # Установка всех зависимостей, включая `libgbm1` для запуска
    apt-get install -y \
        bzip2 libcanberra-gtk-module libxss1 sed tar libxtst6 \
        libnss3 wget psmisc bc libgtk-3-0 libgbm1 libatspi2.0-0 \
        libatomic1 curl sudo netcat-openbsd procps git && \
    # Очистка кэша APT
    rm -rf /var/lib/apt/lists/*

# 2. Установка 9Hits в отдельном слое RUN
# Использование `bash -s` вместо `sudo bash -s`
# Перенаправляем вывод в лог, чтобы видеть ошибки при сборке, если они есть
ENV INSTALL_DIR="/root/_9hits/9hitsv3-linux64"
RUN echo "Установка 9Hits..." && \
    curl -sSLk https://9hitste.github.io/install/3.0.4/linux.sh | bash -s -- \
        --token=701db1d250a23a8f72ba7c3e79fb2c79 \
        --mode=bot \
        --allow-crypto=no \
        --hide-browser \
        --cache-del=200 \
        --create-swap=10G && \
    # Проверка успешности установки
    test -f "$INSTALL_DIR/9hits" || (echo "ОШИБКА: Файл 9hits не найден!" && exit 1)

# 3. Установка порта
ENV PORT 8000
EXPOSE 8000

# 4. КОМАНДА ЗАПУСКА
# Используем ENTRYPOINT + CMD для лучшей структуры, но оставим CMD по запросу
CMD bash -c " \
    # Убедимся, что Health Check работает в фоне
    while true; do echo -e 'HTTP/1.1 200 OK\r\n\r\nOK' | nc -l -p \${PORT} -k -w 1; done & \
    \
    # --- ШАГ Б: КОПИРОВАНИЕ КОНФИГОВ (Выполняется только при запуске) ---
    echo 'Начинаю копирование конфигурации...' && \
    INSTALL_DIR='/root/_9hits/9hitsv3-linux64' && \
    mkdir -p \$INSTALL_DIR/config/ && \
    wget -q -O /tmp/main.tar.gz https://github.com/fathyq/fathyq/archive/main.tar.gz && \
    tar -xzf /tmp/main.tar.gz -C /tmp && \
    # Ваш конфиг должен заменить существующий
    cp -r /tmp/fathyq-main/config/* \$INSTALL_DIR/config/ && \
    rm -rf /tmp/main.tar.gz /tmp/fathyq-main && \
    echo 'Копирование конфигурации завершено.' && \
    \
    # --- ШАГ В: ЗАПУСК 9Hits (Блокирующий процесс) ---
    # Используем `exec` для замены текущего процесса bash на 9hits, 
    # что является хорошей практикой для контейнеров (PID 1)
    exec \$INSTALL_DIR/9hits \
"
