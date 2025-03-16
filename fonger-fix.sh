#!/bin/bash

# 确保以root权限运行
if [ "$(id -u)" != "0" ]; then
   echo "此脚本需要root权限，请使用sudo运行"
   exit 1
fi

echo "正在修复方格音乐窗口分离问题..."

# 备份桌面文件
cp /usr/share/applications/fonger-music.desktop /usr/share/applications/fonger-music.desktop.bak
echo "已备份原始桌面文件到 /usr/share/applications/fonger-music.desktop.bak"

# 查找应用程序的真实窗口类
# 启动应用并观察
echo "正在检测应用程序窗口类..."
fonger-music --no-sandbox &
APP_PID=$!
sleep 3

# 使用xprop检查所有窗口类，找到可能的FongerMusic窗口
WINDOW_IDS=$(xdotool search --name "FongerMusic" 2>/dev/null)
WINDOW_CLASS=""

if [ -n "$WINDOW_IDS" ]; then
    for WID in $WINDOW_IDS; do
        CLASS=$(xprop -id $WID WM_CLASS 2>/dev/null | sed 's/.*"\(.*\)",.*"\(.*\)".*/\2/')
        if [ -n "$CLASS" ]; then
            WINDOW_CLASS=$CLASS
            break
        fi
    done
fi

# 如果找不到，使用通用名称
if [ -z "$WINDOW_CLASS" ]; then
    WINDOW_CLASS="FongerMusic"
fi

# 终止启动的应用
kill $APP_PID 2>/dev/null
sleep 1

echo "检测到窗口类: $WINDOW_CLASS"

# 修改桌面文件
sed -i "s/StartupWMClass=.*/StartupWMClass=$WINDOW_CLASS/" /usr/share/applications/fonger-music.desktop

# 创建启动脚本包装器
cat > /usr/local/bin/fonger-music-wrapper << EOF
#!/bin/bash
# 方格音乐启动包装器
exec /usr/local/bin/fonger-music --class=$WINDOW_CLASS --no-sandbox "\$@"
EOF

chmod +x /usr/local/bin/fonger-music-wrapper

# 更新桌面文件使用新的包装器
sed -i "s|Exec=fonger-music --no-sandbox|Exec=/usr/local/bin/fonger-music-wrapper|" /usr/share/applications/fonger-music.desktop

echo "修复完成！现在尝试从应用程序菜单启动方格音乐，应该不会再出现窗口分离问题。"
echo "如果问题仍然存在，请尝试注销后重新登录。" 