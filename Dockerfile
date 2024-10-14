# 默认镜像构建基于基于python-3.11.10，使用Dockerfile.fastbuild作为构建文件来获得更快的构建速度
FROM python:3.11.10-slim

# 工作目录设置为/musicatri
WORKDIR /musicatri

# 复制项目运行文件
COPY langfiles /musicatri/langfiles
COPY website /musicatri/website
COPY musicatri.py /musicatri/musicatri.py
COPY config.json /musicatri/config.json
COPY requirements.txt /musicatri/requirements.txt
# 启动入口点文件
COPY docker-compose/musicatri-entrypoint.sh /musicatri/entrypoint.sh
# 覆盖原始proxychains配置文件
COPY docker-compose/proxychains4.conf /etc/proxychains4.conf

# 安装python第三方依赖
RUN ["pip", "install", "--upgrade", "pip"]
RUN ["pip", "install", "-r", "requirements.txt"]

# 安装程序运行必要依赖，proxychains4用于指定流量中转到clash
RUN ["apt", "update"]
RUN ["apt", "install", "ffmpeg", "proxychains4", "dnsutils", "curl", "vim", "-y"]

# 项目启动入口
ENTRYPOINT ["/bin/bash", "./entrypoint.sh"]