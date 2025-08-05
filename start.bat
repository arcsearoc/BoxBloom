@echo off
REM 查找当前目录下的love.exe（假设love文件夹与main.lua同级）
set LOVE_PATH=.\love-11.5-win64\love.exe

REM 检查love.exe是否存在
if not exist "%LOVE_PATH%" (
    echo 错误：未找到love.exe，请确认love文件夹是否在当前目录下
    echo 路径应为：%LOVE_PATH%
    pause
    exit /b 1
)

REM 检查main.lua是否存在
if not exist "main.lua" (
    echo 错误：未找到main.lua文件
    pause
    exit /b 1
)

REM 启动Love2D并运行当前目录（包含main.lua）
"%LOVE_PATH%" .

REM 保持窗口打开（可选，出错时方便查看信息）
pause