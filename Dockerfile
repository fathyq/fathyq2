FROM debian:11

# Шаг 1: Установка минимальных инструментов + netcat (для Health Check)
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    wget \
    git \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Указываем Koyeb, какой порт слушать
EXPOSE 8000

# Шаг 2: Запуск netcat для прохождения Health Check и удержания контейнера
# netcat слушает порт 8000, проходя проверку, а bash остается доступным для Shell-доступа.
CMD ["/bin/bash", "-c", "while true; do nc -l -p 8000 -q 1; done & tail -f /dev/null"]
