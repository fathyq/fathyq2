FROM debian:11

# Шаг 1: Устанавливаем минимальные инструменты, включая netcat для имитации сервера
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils \
    bash \
    procps \
    vim \
    curl \
    wget \
    git \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Указываем порт 8000 для Koyeb
EXPOSE 8000

# Шаг 2: Запуск основного процесса. 
# Используем netcat для "прослушивания" порта 8000.
# Эта команда никогда не завершается и проходит Health Check.
# Она также позволяет подключиться к контейнеру для интерактивной работы.
CMD ["/bin/bash", "-c", "nc -l -p 8000 -k & wait"] 
# Объяснение: 'nc -l -p 8000 -k' слушает порт 8000 в фоне. '& wait' удерживает контейнер.
