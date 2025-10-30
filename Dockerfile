FROM debian:11

# Шаг 1: Устанавливаем минимальные инструменты, необходимые для дальнейшей работы в терминале
# и обновления списка пакетов (apt-utils - для корректной работы apt)
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils \
    bash \
    procps \
    vim \
    curl \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

# Шаг 2: Определяем команду, которая будет выполняться при запуске контейнера.
# В данном случае, это просто запуск оболочки (bash), чтобы вы могли подключиться.
CMD ["/bin/bash"]
