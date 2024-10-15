#!/bin/bash

# ----------------------------------------------------------------------
# 脚本名称: musicatri-entrypoint.sh
# 脚本描述: 脚本作为pineclone/musicatri:<version>-clash镜像入口点
#
# 脚本原理:
#   - 项目启动之后脚本通过dnsutils命令行工具读取各个服务的ip地址，并在/etc/proxychains.conf
#     中对clash代理进行正确配置，同时对其他服务配置hosts文件以确保正确的解析
#
# 作者: pineclone
# 日期: 2024/10/13
# 版本: 1.0
# ----------------------------------------------------------------------

debug_mode=false  # 调试模式

# 解析参数
for arg in "$@"; do
    case $arg in
        --debug)
            debug_mode=true
            shift
            ;;
        *)
            echo "未知参数: $arg"
            ;;
    esac
done

if [ "$debug_mode" = true ]; then
    echo "启动脚本调试模式启用"
fi

CLASH_HOSTNAME="clash"  # clash服务域名
MONGODB_HOSTNAME="mongodb"  # mongodb服务域名
NETEASECLOUDMUSICAPI_HOSTNAME="neteasecloudmusicapi"  # neteasecloudmusicapi服务域名

# 通过域名查询ip
dnsLookup(){
  local domain=$1  # 域名
  # shellcheck disable=SC2155
  local ip=$(getent hosts "$domain" | awk '{ print $1 }')

    if [[ -z "$ip" ]]; then
      # 域名解析失败
      echo "[严重错误]: 域名解析失败，未找到域名 $domain 的 IP 地址"
      exit 1
    fi

  echo "$ip"  # 域名解析成功
}

# 解析域名
clash_ip=$(dnsLookup "$CLASH_HOSTNAME")
mongodb_ip=$(dnsLookup "$MONGODB_HOSTNAME")
neteasecloudmusicapi_ip=$(dnsLookup "$NETEASECLOUDMUSICAPI_HOSTNAME")

if [ "$debug_mode" = true ]; then
    echo "域名解析结果:"
    echo "clash ip: $clash_ip"
    echo "mongodb ip: $mongodb_ip"
    echo "neteasecloudmusic ip: $neteasecloudmusicapi_ip"
fi

# 如果缺少内容那么追加
# param1: 检索的内容
# param2: 写入的内容
# param3: 目标文件
appendIfAbsent(){
  local search=$1  # 检索内容
  local to_append=$2  # 写入内容
  local file=$3  # 写入文件
  # shellcheck disable=SC2155
  if ! grep "$search" "$file"; then
    # 如果没有找到，写入内容
    if [ -s "$file" ] && [ "$(tail -c 1 "$file")" != "" ]; then
        echo "" >> "$file"  # 换行
    fi

    echo "$to_append" >> "$file"

    if [ "$debug_mode" = true ]; then
      echo "已将 $to_append 添加到 $file"
    fi

  else
    # 已经包含
    if [ "$debug_mode" = true ]; then
      echo "$file 已包含 '$search'，跳过添加"
    fi
  fi
}

# 初始化配置
appendIfAbsent "7890" "socks5 $clash_ip 7890" "/etc/proxychains4.conf"
appendIfAbsent $MONGODB_HOSTNAME "$mongodb_ip  $MONGODB_HOSTNAME" "/etc/hosts"
appendIfAbsent $NETEASECLOUDMUSICAPI_HOSTNAME "$neteasecloudmusicapi_ip  $NETEASECLOUDMUSICAPI_HOSTNAME" "/etc/hosts"

# 启动项目
proxychains4 python musicatri.py