FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive

#设置工作目录
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    iptables \ 
    curl \
    unzip \
    lsof \
    net-tools \
    iputils-ping \
    ca-certificates \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && curl -L "https://github.com/liulilittle/openppp2/releases/download/1.0.0.24123/openppp2-linux-amd64.zip" -o openppp2-linux-amd64.zip \
    && unzip openppp2-linux-amd64.zip \
    && rm openppp2-linux-amd64.zip \
    && chmod +x /app/ppp

# 定义环境和启动脚本
ENTRYPOINT ["/app/ppp"]
