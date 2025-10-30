FROM debian:11

RUN apt-get update && apt-get install -y curl xvfb python3
RUN curl -sSLk https://9hitste.github.io/install/3.0.4/linux.sh | bash -s -- --token=701db1d250a23a8f72ba7c3e79fb2c79

EXPOSE 8000

CMD ["/bin/bash", "-c", "python3 -m http.server 8000 & cd /home/_9hits/9hitsv3-linux64/ && xvfb-run -a ./9hits --token=701db1d250a23a8f72ba7c3e79fb2c79 --mode=bot --no-sandbox --single-process"]
