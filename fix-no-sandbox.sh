#!/bin/bash

# 给方格音乐添加--no-sandbox参数的脚本

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
  echo "请使用root权限运行此脚本"
  echo "sudo $0"
  exit 1
fi

echo "========================================"
echo "     修改方格音乐启动脚本"
echo "========================================"

LAUNCHER_PATH="/usr/local/bin/fonger-music"

if [ ! -f "$LAUNCHER_PATH" ]; then
  echo "错误: 找不到启动脚本 $LAUNCHER_PATH"
  echo "请先安装方格音乐启动器"
  exit 1
fi

echo "正在修改启动脚本，添加--no-sandbox参数..."

# 创建新的启动脚本
cat > "$LAUNCHER_PATH" << 'EOF'
#!/bin/bash
# 方格音乐启动命令 (无沙盒模式)

# 查找electron可执行文件
ELECTRON=""
if command -v electron &> /dev/null; then
    ELECTRON="electron"
elif command -v electron-19 &> /dev/null; then
    ELECTRON="electron-19"
elif command -v electron-18 &> /dev/null; then
    ELECTRON="electron-18"
else
    echo "错误: 未找到electron。请安装electron: sudo apt-get install electron"
    exit 1
fi

# 使用固定路径，添加--no-sandbox参数
if [ -f "/opt/fonger-music/app.asar" ]; then
    cd /opt/fonger-music
    $ELECTRON --no-sandbox /opt/fonger-music/app.asar "$@"
else
    echo "错误: 找不到app.asar文件: /opt/fonger-music/app.asar"
    echo "请确保已安装方格音乐或检查deb包是否正确安装"
    exit 1
fi
EOF

# 设置权限
chmod +x "$LAUNCHER_PATH"

echo "========================================"
echo "     修改成功！"
echo "     现在可以使用fonger-music命令运行方格音乐了"
echo "     (已添加--no-sandbox参数，无需设置沙盒权限)"
echo "========================================" 