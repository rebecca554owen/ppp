# openppp2 docker 安装指南 
本教程基于docker compose 安装，可部署在非LXC系统，不想用docker的话，直接用 Supervisor 进程守护启动 ppp 。

1.使用 `mkdir ppp` 新建ppp文件夹，并在文件夹内新建 `docker-compose.yml` 和 `appsettings.json`。
## 服务端  
docker-compose.yml 示例
```
version: '3'
services:
  openppp2:
    image: rebecca554owen/ppp:latest
    container_name: openppp2
    restart: always
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
    volumes:
      - ./appsettings.json:/app/appsettings.json # 挂载当前目录的appsettings.json配置文件到容器内部。
    network_mode: host # host 模式方便监听ipv4/ipv6 。
    command: ppp --mode=server 
```
## 客户端  
docker-compose.yml 示例
```
version: '3'
services:
  openppp1: # 服务名，openppp2对应appsettings2.json，多开的时候用上。
    image: rebecca554owen/ppp:latest
    container_name: openppp1 # 容器名，openppp2对应appsettings2.json，多开的时候用上。
    restart: always
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
    volumes:
      - ./appsettings1.json:/app/appsettings.json # appsettings1.json，用于区别接入多个服务端。
    ports:
      - "7891:8080" # bridge 模式，7891端口对接第一个服务端，7892端口对接第二个服务端互不干扰，也不会全局代理。
    networks:
      - openpppnetwork
    command: ppp --mode=client --tun-static=yes --block-quic=no --set-http-proxy=yes # --tun-static=yes或者no，按需修改，服务端未开启udp则不要选yes。

networks:
  openpppnetwork:
    driver: bridge
    # enable_ipv6: true # docker 是否启用ipv6，需要提前设置修改 /etc/docker/daemon.json 以便于支持ipv6。
    ipam:
      driver: default
      config:
        - subnet: 172.20.0.0/24 # 新建的docker 桥接网络ipv6子网
        # - subnet: 2001:db8:1::/64 # 新建的docker 桥接网络ipv6子网
 
```
## appsettings.json 配置文件
服务端和客户端可以共用一份配置文件，使用前 **删去** # 后面的注释内容，为了方便入门，一些参数我就不写注释了，默认值即可使用。
```
{
    "concurrent": 5,   # 多核榨干U能并发数为核心数+1，单核写1（否则系统内核容易在极高负载的时被挂起）
    "cdn": [ 80, 443 ], 
    "key": {
        "kf": 154543927,
        "kx": 128,
        "kl": 10,
        "kh": 12,
        "protocol": "aes-128-cfb",
        "protocol-key": "N6HMzdUs7IUnYHwq",
        "transport": "aes-256-cfb",
        "transport-key": "HWFweXu2g5RVMEpy",
        "masked": false,
        "plaintext": false,
        "delta-encode": false,
        "shuffle-data": false
    },
    "ip": {
        "public": "1.2.3.4", # 服务端输入 ip addr 或者 ifconfig 看到的 eth0 的内网IP 172.x.x.x或者公网IP：1.2.3.4；客户端写本机内网IP：192.168.1.100。
        "interface": "::" # 服务端 可以按上边填写，或者默认 :: 用于监听ipv4/ipv6双栈，客户端写本机内网IP：192.168.1.100。
    },
    "vmem": {
        "size": 0, # 不生成swap就写0，需要swap就写1024/2024/4096。
        "path": "./{}"
    },
    "tcp": {
        "inactive": {
            "timeout": 300
        },
        "connect": {
            "timeout": 5
        },
        "listen": {
            "port": 2024 # 服务端使用的TCP连接端口
        },
        "turbo": true,
        "backlog": 511,
        "fast-open": true
    },
    "udp": {
        "inactive": {
            "timeout": 72
        },
        "dns": {
            "timeout": 4,
            "redirect": "0.0.0.0"
        },
        "listen": {
            "port": 2024 # 服务端使用的UDP连接端口
        },
        "static": {
            "keep-alived": [1, 5], # [0, 0]
            "dns": true,
            "quic": true,
            "icmp": true,
            "server": "1.2.3.4:2024" # 客户端填写服务端的地址以及UDP端口
        }
    },
    "websocket": {
        "host": "starrylink.net",
        "path": "/tun",
        "listen": {
            "ws": 20080,
            "wss": 20443
        },
        "ssl": {
            "certificate-file": "starrylink.net.pem",
            "certificate-chain-file": "starrylink.net.pem",
            "certificate-key-file": "starrylink.net.key",
            "certificate-key-password": "test",
            "ciphersuites": "TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256"
        },
        "verify-peer": true,
        "http": {
            "error": "Status Code: 404; Not Found",
            "request": {
                "Cache-Control": "no-cache",
                "Pragma": "no-cache",
                "Accept-Encoding": "gzip, deflate",
                "Accept-Language": "zh-CN,zh;q=0.9",
                "Origin": "http://www.websocket-test.com",
                "Sec-WebSocket-Extensions": "permessage-deflate; client_max_window_bits",
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36 Edg/121.0.0.0"
            },
            "response": {
                "Server": "Kestrel"
            }
        }
    },
    "server": {
        "log": "./ppp.log",
        "node": 1,
        "subnet": true,
        "mapping": true,
        "backend": "", 
        "backend-key": "HaEkTB55VcHovKtUPHmU9zn0NjFmC6tff"
    },
    "client": {
        "guid": "{F4569208-BB45-4DEB-B115-0FEA1D91B85B}",
        "server": "ppp://1.2.3.4:2024/", # 填写服务端的地址以及端口，支持域名。
        "bandwidth": 0,
        "reconnections": {
            "timeout": 5
        },
        "paper-airplane": {
            "tcp": true
        },
        "http-proxy": {
            "bind": "::", # http监听地址，可写127.0.0.1或者内网IP或者0.0.0.0。
            "port": 8080
        },
        "mappings": [
            {
                "local-ip": "192.168.0.24",
                "local-port": 80,
                "protocol": "tcp",
                "remote-ip": "::",
                "remote-port": 10001
            },
            {
                "local-ip": "192.168.0.24",
                "local-port": 7000,
                "protocol": "udp",
                "remote-ip": "::",
                "remote-port": 10002
            }
        ]
    }
}

```
