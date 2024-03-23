FROM ubuntu:latest
# ubuntu:22.04, ubuntu:20.04, ubuntu:18.04
ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    vim \
    curl \
    lsof \   
    unzip \
    tzdata \
    iptables \
    net-tools \
    iputils-ping \
    ca-certificates \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && curl -L "https://github.com/liulilittle/openppp2/releases/download/1.0.0.24123/openppp2-linux-amd64.zip" -o openppp2-linux-amd64.zip \
    && unzip openppp2-linux-amd64.zip \
    && rm openppp2-linux-amd64.zip \
    && chmod +x /app/ppp

ENTRYPOINT ["/app/ppp"]
