# 部署Mongodb

***

- MongoDB社区版安装指南：https://www.mongodb.com/zh-cn/docs/manual/tutorial/install-mongodb-on-ubuntu/

`musicatri`项目运行时依赖于MongoDB作为数据库进行数据持久化，可以使用已有的MongoDB数据库，如果手头还没有可以连接的MongoDB，可以按照下面的步骤来部署一个：

```bash
# 安装mongodb依赖
sudo apt install gnupg curl wget -y

# 导入MongoDB公共GPG密钥
wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -

# 为Ubuntu 20.04(Focal)创建列表文件(其他版本参考上面的安装指南链接)
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list

# 更新apt源
sudo apt update

# 安装最新稳定版本mongodb
sudo apt install mongodb-org -y
# apt安装mongodb的默认数据目录: /var/lib/mongodb
# apt安装mongodb的默认日志目录: /var/log/mongodb
# 配置文件: /etc/mongod.conf

# 启动mongodb服务
mongod --config /etc/mongod.conf
```

可以通过`mongosh`尝试连接mongodb检查是否mongodb状态：

```bash
mongosh --host localhost --port 27017  # 连接mongodb://localhost:27017
show databases;
```
