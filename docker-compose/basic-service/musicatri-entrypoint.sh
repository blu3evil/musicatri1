#!/bin/bash

# ----------------------------------------------------------------------
# 脚本名称: musicatri-entrypoint.sh
# 脚本描述: 脚本作为pineclone/musicatri:<version>镜像入口点，此脚本作用为基础容器
#
# 作者: pineclone
# 日期: 2024/10/15
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

# 启动项目
python musicatri.py