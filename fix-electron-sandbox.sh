#!/bin/bash

# Electron沙盒权限修复脚本

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
  echo "请使用root权限运行此脚本"
  echo "sudo $0"
  exit 1
fi

echo "========================================"
echo "     修复Electron沙盒权限"
echo "========================================"

# 检查全局安装的Electron路径
ELECTRON_PATHS=(
  "/usr/local/lib/node_modules/electron/dist/chrome-sandbox"
  "/usr/lib/node_modules/electron/dist/chrome-sandbox"
  "/usr/share/electron/chrome-sandbox"
  "/opt/electron/chrome-sandbox"
)

FIXED=0

for SANDBOX_PATH in "${ELECTRON_PATHS[@]}"; do
  if [ -f "$SANDBOX_PATH" ]; then
    echo "找到Electron沙盒文件: $SANDBOX_PATH"
    echo "正在设置正确的权限..."
    
    # 设置所有者为root
    chown root:root "$SANDBOX_PATH"
    
    # 设置SUID权限
    chmod 4755 "$SANDBOX_PATH"
    
    echo "权限设置完成！"
    FIXED=1
  fi
done

# 如果没有找到标准路径，尝试查找全局安装的electron
if [ $FIXED -eq 0 ]; then
  echo "在标准路径未找到chrome-sandbox，尝试查找..."
  
  # 尝试查找npm全局安装的electron
  ELECTRON_PATH=$(which electron 2>/dev/null)
  if [ -n "$ELECTRON_PATH" ]; then
    ELECTRON_DIR=$(dirname "$ELECTRON_PATH")
    # 向上找到dist目录
    if [ -d "$ELECTRON_DIR/../lib/electron" ]; then
      SANDBOX_PATH="$ELECTRON_DIR/../lib/electron/chrome-sandbox"
      if [ -f "$SANDBOX_PATH" ]; then
        echo "找到Electron沙盒文件: $SANDBOX_PATH"
        echo "正在设置正确的权限..."
        chown root:root "$SANDBOX_PATH"
        chmod 4755 "$SANDBOX_PATH"
        echo "权限设置完成！"
        FIXED=1
      fi
    fi
  fi
  
  # 全局搜索chrome-sandbox文件
  if [ $FIXED -eq 0 ]; then
    echo "搜索系统中的chrome-sandbox文件..."
    FOUND_SANDBOXES=$(find /usr -name chrome-sandbox -type f 2>/dev/null)
    
    for SANDBOX in $FOUND_SANDBOXES; do
      echo "找到Electron沙盒文件: $SANDBOX"
      echo "正在设置正确的权限..."
      chown root:root "$SANDBOX"
      chmod 4755 "$SANDBOX"
      echo "权限设置完成！"
      FIXED=1
    done
  fi
fi

if [ $FIXED -eq 1 ]; then
  echo "========================================"
  echo "     修复成功！"
  echo "     现在可以使用fonger-music命令运行方格音乐了"
  echo "========================================"
else
  echo "========================================"
  echo "     未找到chrome-sandbox文件"
  echo "     您可以尝试以下解决方案："
  echo ""
  echo "     1. 使用系统包管理器安装electron："
  echo "        sudo apt-get install electron"
  echo ""
  echo "     2. 使用--no-sandbox参数启动："
  echo "        修改/usr/local/bin/fonger-music脚本"
  echo "        将electron命令改为:"
  echo "        \$ELECTRON --no-sandbox /opt/fonger-music/app.asar"
  echo "========================================"
fi 