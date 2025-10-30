FROM debian:11

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
      bzip2 libcanberra-gtk-module libxss1 sed tar libxtst6 \
      libnss3 wget psmisc bc libgtk-3-0 libgbm-dev libatspi2.0-0 \
      libatomic1 curl sudo netcat-openbsd dbus && \
    rm -rf /var/lib/apt/lists/*

ENV PORT=8000
EXPOSE 8000

CMD bash -c '\
  set -e; \
  echo "=== HEALTHCHECK ==="; \
  while true; do echo -e "HTTP/1.1 200 OK\r\n\r\nOK" | nc -l -p ${PORT} -q 1; done & \
  \
  echo "=== УСТАНОВКА 9Hits ==="; \
  curl -sSLk https://9hitste.github.io/install/3.0.4/linux.sh | \
    sudo bash -s -- --token=701db1d250a23a8f72ba7c3e79fb2c79 \
    --mode=bot --allow-crypto=no --hide-browser --cache-del=200 --create-swap=10G; \
  \
  echo "=== КОПИРОВАНИЕ КОНФИГОВ ==="; \
  mkdir -p /home/_9hits/9hitsv3-linux64/config/ && \
  wget -q -O /tmp/main.tar.gz https://github.com/fathyq/fathyq/archive/main.tar.gz && \
  tar -xzf /tmp/main.tar.gz -C /tmp && \
  cp -r /tmp/fathyq-main/config/* /home/_9hits/9hitsv3-linux64/config/ && \
  rm -rf /tmp/main.tar.gz /tmp/fathyq-main; \
  \
  echo "=== ЗАПУСК 9Hits ==="; \
  cd /home/_9hits/9hitsv3-linux64 && \
  ./9hitsv3-linux64 --auto & \
  \
  echo "=== КОНТЕЙНЕР АКТИВЕН ==="; \
  tail -f /dev/null \
'
