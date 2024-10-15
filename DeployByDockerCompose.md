# DockerCompose部署

***

得益于Docker Compose对所有程序依赖的服务进行统一的组织管理，我们可以通过DockerCompose来实现项目的一键启动，为了适应不同的环境，我们为项目编写了不止一套compose文件，这些文件适用于不同的生产环境，从而确保项目能够适配更多的场景

项目一键部署相关的DockerCompose配置主要集中在`/docker-compose`目录下，我们使用尽可能见名知意的命名规则来命名每一个DockerCompose文件，来使得它们更容易被理解，例如：

以下是**生产环境**所使用的compose文件：

```
compose.prod.aliyun.yml
compose.prod.yml
```

`aliyun`字样代表其使用我们上传到阿里云镜像仓库的镜像来启动服务，这是为了针对一些云服务器环境不方便使用代理而设计的，如果您在本地并且拥有一个健康的代理环境，可以连接Dockerhub，那么可以直接使用第二份compose文件

使用DockerCompose一键部署只需要很少的步骤：首先通过github直接获取这份Compose文件：您可以根据自身所处环境来选择是否使用阿里云镜像：（下面以一般环境为例）

为项目创建根目录

```bash
mkdir musicatri && cd musicatri
```

通过github仓库拉取compose文件：

```bash
# for Linux
curl https://raw.githubusercontent.com/blu3evil/musicatri1/refs/heads/main/docker/compose.prod.yml > compose.yml
# for Windows
Invoke-RestMethod -Uri https://raw.githubusercontent.com/blu3evil/musicatri1/refs/heads/main/docker/compose.prod.yml > ./.env
```

通过github仓库拉取环境配置文件（用于配置Musicatri）：

```bash
# for Linux
curl https://raw.githubusercontent.com/blu3evil/musicatri1/refs/heads/main/docker/env.example > .env
# for Windows
Invoke-RestMethod -Uri https://raw.githubusercontent.com/blu3evil/musicatri1/refs/heads/main/docker/env.example > ./.env
```

然后您需要配置`.env`文件当中的数个配置项：这一步和使用Docker部署Musicatri几乎没有差异，修改`.env`配置文件：写入您的机器人应用的`CLIENT ID`、`CLIENT SECRET`以及`Token`配置项：

```properties
# Discord机器人应用客户端ID
DISCORD_CLIENT_ID="your client id"
# Discord机器人应用客户端密匙
DISCORD_CLIENT_SECRET="your client secret"
# Discord机器人认证Token
DISCORD_BOT_TOKEN="your bot token"
```

如果您在配备公网ip的云服务器环境运行，或者配置了域名，希望外部可以通过域名或者公网ip访问Musicatri管理后台，那么修改`PUBLIC_URL`以及`callback`认证地址：

```properties
# Musicatri服务端地址，如果服务配置了域名那么将这一项替换
PUBLIC_URL=http://localhost:5000
# DiscordOAuth2重定向地址，请配置为PUBLIC_URL/account/callback的格式
DISCORD_REDIRECT_URI=http://localhost:5000/account/callback
```

> :warning:注：如果您熟悉DockerCompose，我们支持您按照自己的偏好修改DockerCompose文件以适应您当前的运行环境，或是一些个性化需求，如果不然，请不要轻易改动它，这极有可能导致项目不能正常运行，您应该仅仅修改`.env`文件，这份文件的配置已经能完成绝大多数需求

随后运行这份compose文件来启动项目即可：

```bash
docker compose up -d
```

这会启动多个docker容器，它们共同组成Musicatri项目本体

如果一切启动正常，您就可以在服务器中看到机器人上线了，通过 http://localhost:5000 端口来访问Musicatri的控制台，您可以在上面点歌，Musicatri会加入频道中并播放音乐，加入频道一起摇滚吧~

