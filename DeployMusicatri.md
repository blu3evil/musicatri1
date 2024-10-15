# 部署Musicatri

***

-  :warning:我们假设您已经完成了NeteaseCloudMusicApi，Mongodb服务的部署，并且它们顺利运行，Musicatri的部署文档并不会涉及上面两个服务的部署事宜
- 如果您还没有可以使用的Mongodb或者NeteaseCloudMusicApi，您可以参考列表中关于它们的部署文档，或是前往官方站点了解如何部署它们

## 手动部署

首先请确保环境可以运行ffmpeg，Musicatri中的Discord API依赖ffmpeg执行音频流播放：

```bash
ffmpeg -version  # 在命令行打印当前ffmpeg版本
```

如果没有安装ffmpeg，可以通过包管理器来快速安装

```bash
# for Linux
apt install ffmpeg -y  
# for Windows
scoop install ffmpeg   
```

`blu3evil/musicatri`仓库的`main`分支代表了此项目的稳定版本，推荐使用此分支进行Musicatri服务的部署，可以使用下面的命令将项目拉取到您的本地：

```bash
git clone https://github.com/blu3evil/musicatri1.git && cd musicatri1
```

项目采用Python编写，因此请确保当前python环境可用，我们推荐使用`Python3.11`版本运行此项目，您可以使用Miniconda为此项目创建一个python虚拟环境：

```bash
# 安装miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.9.2-Linux-x86_64.sh
bash ./Miniconda3-py39_4.9.2-Linux-x86_64.sh

conda create -n musicatri python=3.11  # 创建项目运行使用的虚拟环境
conda activate musicatri  # 激活虚拟环境
```

在项目源码目录下，使用`requirements.txt`安装项目需要的依赖：

```bash
pip install -r requirements.txt  # 安装项目所需依赖
```

在运行项目之前您需要进行一些简单的配置：在项目的根路径下存在`config.json`配置文件，其中涉及了项目的全部配置项，将您的机器人应用的`CLIENT ID`、`CLIENT SECRET`、`Token`分别复制到配置文件中

```json
"DISCORD_CLIENT_ID": "your client id"
"DISCORD_CLIENT_SECRET": "your clientsecret"
"DISCORD_BOT_TOKEN": "your bot's token"
```

配置Musicatri服务正确指向NeteaseCloudMusicApi和Mongodb服务：

```json
"NETEASECLOUDMUSICAPI_URL": "http://localhost:3000"
"MONGODB_URL": "mongodb://localhost:27017"
```

如果您为服务配置了域名或者服务处于具有公网IP的云服务器环境，并且您希望能够通过公网访问Musicatri服务控制台页面，那么修改

```json
"PUBLIC_URL": "http://localhost:5000"
"DISCORD_REDIRECT_URI": "http://localhost:5000/account/callback"
```

> 请注意`DISCORD_REDIRECT_URI`一般配置为`${PUBLIC_URL}/account/callback`的形式

到这一步全部的配置就完成了，可以通过命令来启动Musicatri：

```bash
python musicatri.py
```

```bash
2024-10-15 15:57:42:INFO:主人我目前加入了1个服务器哦  # 控制台回显
```

如果一切顺利的话，你应该可以在你的服务器当中看到机器人上线了，挑选一首喜好的网易云音乐，复制其链接，或是直接复制bilibili视频页面URL，在服务器键入下面的命令来播放它

``` bash
${DISCORD_BOT_COMMAND_PREFIX}play ${VOICE_URL}
```

你也可以进入Musicatri的控制台管理页面，比如 http://localhost:5000/songctl 来手动加入歌曲，或者调整歌曲播放列表排序

机器人会加入服务器的语音频道并开始播放音乐，加入语音频道来一起听歌吧！

## 使用docker部署

项目提供了很完备的Docker部署支持，或者说项目主推Docker部署，因为那样能够省去很多麻烦，Musicatri服务已经被打包作为镜像同时传到了DockerHub以及阿里云镜像托管，因此你可以直接拉取它们~~（国内环境使用后者）~~

```bash
# from dockerhub
docker pull pineclone/musicatri:latest
# from aliyun registry
docker pull registry.cn-hangzhou.aliyuncs.com/pineclone/musicatri:latest
```

为项目服务创建一个根目录：

```bash
mkdir musicatri && cd musicatri
```

通过命令来运行容器：由于项目配置项较多，使用`-e`逐条指定环境变量将十分麻烦，推荐使用`.env`作为环境变量配置文件来运行容器：可以直接从项目仓库拉取一份示例配置并保存到本地：

```bash
# for Linux
curl https://raw.githubusercontent.com/blu3evil/musicatri1/refs/heads/main/docker/env.example > ./.env

# for Windows
Invoke-RestMethod -Uri https://raw.githubusercontent.com/blu3evil/musicatri1/refs/heads/main/docker/env.example > ./.env
```

修改`.env`配置文件：写入您的机器人应用的`CLIENT ID`、`CLIENT SECRET`以及`Token`配置项：

```properties
# Discord机器人应用客户端ID
DISCORD_CLIENT_ID="your client id"
# Discord机器人应用客户端密匙
DISCORD_CLIENT_SECRET="your client secret"
# Discord机器人认证Token
DISCORD_BOT_TOKEN="your bot token"
```

配置Musicatri服务正确指向NeteaseCloudMusicApi和Mongodb服务：

```properties
# NeteaseCloudMusicApi服务地址
NETEASECLOUDMUSICAPI_URL=http://localhost:3000
# MongoDB数据库服务地址
MONGODB_URL=mongodb://localhost:27017
```

如果您在配备公网ip的云服务器环境运行，或者配置了域名，希望外部可以通过域名或者公网ip访问Musicatri管理后台，那么修改`PUBLIC_URL`以及`callback`认证地址：

```properties
# Musicatri服务端地址，如果服务配置了域名那么将这一项替换
PUBLIC_URL=http://localhost:5000
# DiscordOAuth2重定向地址，请配置为PUBLIC_URL/account/callback的格式
DISCORD_REDIRECT_URI=http://localhost:5000/account/callback
```

使用命令来启动Musicatri容器吧

```bash
docker-compose run --name musicatri -p 5000:5000 -it --rm --env-file ./.env pineclone/musicatri:latest
```

如果使用compose形式启动，那么创建compose.yml配置文件：

```bash
echo "" > compose.dev.env.yml && vim compose.dev.env.yml  # 新建配置文件
```

```yaml
version: "3.8"
services:
  musicatri:
    image: pineclone/musicatri:${MUSICATRI_TAG}
    ports:
      - "5000:5000"
    tty: true
    stdin_open: true
    environment:
      - NETEASECLOUDMUSICAPI_URL=${NETEASECLOUDMUSICAPI_URL}
      - MONGODB_URL=${MONGODB_URL}
      - SERVER_PORT=${SERVER_PORT}
      - PUBLIC_URL=${PUBLIC_URL}
      - APP_SECRET_KEY=${APP_SECRET_KEY}
      - DISCORD_REDIRECT_URI=${DISCORD_REDIRECT_URI}
      - DISCORD_CLIENT_ID=${DISCORD_CLIENT_ID}
      - DISCORD_CLIENT_SECRET=${DISCORD_CLIENT_SECRET}
      - DISCORD_BOT_TOKEN=${DISCORD_BOT_TOKEN}
      - DISCORD_BOT_BANNER=${DISCORD_BOT_BANNER}
      - DISCORD_BOT_ACTIVITY=${DISCORD_BOT_ACTIVITY}
      - DISCORD_BOT_COMMAND_PREFIX=${DISCORD_BOT_COMMAND_PREFIX}
      - YOUTUBEDL_PROXY=${YOUTUBEDL_PROXY}
      - CONSOLE_LOG_LEVEL=${CONSOLE_LOG_LEVEL}
      - LOGFILE_LOG_LEVEL=${LOGFILE_LOG_LEVEL}
      - LOG_BASIC_FORMAT=${LOG_BASIC_FORMAT}
      - LOG_DATE_FORMAT=${LOG_DATE_FORMAT}
```

```bash
docker-compose compose up -d  # 启动容器
```

和直接部署一样，如果一切顺利的话，就可以在你的服务器当中看到机器人上线了，挑选一首喜好的网易云音乐，复制其链接，或是直接复制bilibili视频页面URL，在服务器键入下面的命令来播放它

``` bash
${DISCORD_BOT_COMMAND_PREFIX}play ${VOICE_URL}
```

你也可以进入Musicatri的控制台管理页面，比如 http://localhost:5000/songctl 来手动加入歌曲，或者调整歌曲播放列表排序

机器人会加入服务器的语音频道并开始播放音乐，加入语音频道来一起听歌吧！
