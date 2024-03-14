FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive

#设置工作目录
WORKDIR /app

# 复制文件
COPY . /app/

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    tzdata iptables \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && chmod +x /app/ppp

# 定义环境和启动脚本
ENTRYPOINT ["/app/ppp"]
