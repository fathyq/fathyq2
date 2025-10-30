# Полная версия Debian 11
FROM debian:11

# 1. Установка всех утилит и необходимых зависимостей для 9Hits
# Добавлены все зависимости из документации 9Hits для Debian/Ubuntu
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        bzip2 \
        libcanberra-gtk-module \
        libxss1 \
        sed \
        tar \
        libxtst6 \
        libnss3 \
        wget \
        psmisc \
        bc \
        libgtk-3-0 \
        libgbm-dev \
        libatspi2.0-0 \
        libatomic1 \
        curl \
        sudo \
        netcat-openbsd \
        procps \
        git && \
    # Очистка кэша APT для уменьшения размера образа
    rm -rf /var/lib/apt/lists/*

# 2. Установка порта
ENV PORT 8000
EXPOSE 8000

# 3. КОМАНДА ЗАПУСКА: Установка, копирование конфигов и запуск 9Hits
# Выносим установку 9Hits из CMD в отдельный RUN-шаг, чтобы она выполнилась один раз
# при сборке образа. Зависимости уже установлены, 'sudo' не нужен, т.к. работаем от root.
# Вместо 'sudo bash -s' используем просто 'bash -s'
RUN bash -c "curl -sSLk https://9hitste.github.io/install/3.0.4/linux.sh | bash -s -- --token=701db1d250a23a8f72ba7c3e79fb2c79 --mode=bot --allow-crypto=no --hide-browser --cache-del=200 --create-swap=10G"

# 4. КОМАНДА ЗАПУСКА
CMD bash -c " \
    # --- ШАГ А: HEALTH CHECK ---
    # Добавлен '-k' для netcat, чтобы он не закрывался после первого соединения
    while true; do echo -e 'HTTP/1.1 200 OK\r\n\r\nOK' | nc -l -p \${PORT} -k -w 1; done & \
    \
    # --- ШАГ Б: КОПИРОВАНИЕ КОНФИГОВ ---
    # Ваша логика копирования конфигов
    echo 'Начинаю копирование конфигурации...' && \
    # Папка 9Hits по умолчанию: /root/_9hits/9hitsv3-linux64/ или $HOME/_9hits/9hitsv3-linux64/
    # Т.к. вы работаете от root, $HOME = /root
    INSTALL_DIR='/root/_9hits/9hitsv3-linux64' && \
    mkdir -p \$INSTALL_DIR/config/ && \
    # Используем ваш метод wget/tar/cp
    wget -q -O /tmp/main.tar.gz https://github.com/fathyq/fathyq/archive/main.tar.gz && \
    tar -xzf /tmp/main.tar.gz -C /tmp && \
    cp -r /tmp/fathyq-main/config/* \$INSTALL_DIR/config/ && \
    rm -rf /tmp/main.tar.gz /tmp/fathyq-main && \
    echo 'Копирование конфигурации завершено.' && \
    \
    # --- ШАГ В: ЗАПУСК 9Hits (теперь он установлен) ---
    # Запускаем приложение 9Hits
    # В Koyeb CMD должна быть блокирующей, поэтому не используем '&' для 9Hits.
    # После установки 9Hits в предыдущем шаге, исполняемый файл находится в $INSTALL_DIR.
    # Запускаем, используя 'exec', чтобы PID 1 остался процессом 9Hits (лучшая практика)
    # или просто запускаем его, если он не требует фонового запуска.
    # Программа 9Hits часто запускается в режиме, который удерживает контейнер.
    # Если 9Hits не блокирует, то вам понадобится `tail -f /dev/null`
    \$INSTALL_DIR/9hits \
"
