#!/bin/bash

# ==============================================
# 说明：macOS 下 Love2D 可执行文件路径说明
# 1. 若手动下载 Love2D 压缩包（如 love-11.5-macos.zip），解压后得到 "love.app"
# 2. 实际可执行文件路径为：love.app/Contents/MacOS/love
# 3. 脚本假设 "love.app" 与 main.lua 在同一目录（对应原 bat 中 love 文件夹同级逻辑）
# ==============================================

# 1. 定义 Love2D 可执行文件路径（根据实际解压后的文件夹名调整）
LOVE_PATH="./love-11.5-macos/love.app/Contents/MacOS/love"

# 2. 检查 Love2D 可执行文件是否存在
if [ ! -f "$LOVE_PATH" ]; then
    echo "错误：未找到 Love2D 可执行文件，请确认路径是否正确"
    echo "预期路径：$LOVE_PATH"
    echo "提示：1. 检查 love.app 是否在当前目录下；2. 确认压缩包解压后的文件夹名是否为 'love-11.5-macos'"
    read -n 1 -s -r -p "按任意键退出..."  # 类似 Windows 的 pause，等待用户按键
    exit 1
fi

# 3. 检查 main.lua 是否存在（与原 bat 逻辑一致）
if [ ! -f "main.lua" ]; then
    echo "错误：未找到 main.lua 文件，请确认该文件在当前目录下"
    read -n 1 -s -r -p "按任意键退出..."
    exit 1
fi

# 4. 启动 Love2D 并运行当前目录（传递当前目录路径给 Love2D，加载 main.lua）
"$LOVE_PATH" "$(pwd)"
