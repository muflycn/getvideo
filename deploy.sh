#!/bin/bash

# GetVideo 部署脚本
# 用于 1Panel 或其他 Docker 环境

echo "🚀 开始部署 GetVideo 应用..."

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装，请先安装 Docker"
    exit 1
fi

# 检查 Docker Compose 是否安装
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose 未安装，请先安装 Docker Compose"
    exit 1
fi

# 创建必要的目录
echo "📁 创建目录..."
mkdir -p downloads
mkdir -p logs

# 设置权限
echo "🔐 设置权限..."
chmod 755 downloads
chmod 755 logs

# 构建并启动容器
echo "🔨 构建 Docker 镜像..."
docker-compose build

echo "▶️ 启动服务..."
docker-compose up -d

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 10

# 检查服务状态
echo "🔍 检查服务状态..."
if curl -f http://localhost:3000/api/health > /dev/null 2>&1; then
    echo "✅ 服务启动成功！"
    echo "🌐 应用访问地址: http://localhost:3000"
    echo "📚 API 文档: http://localhost:3000/api/health"
else
    echo "❌ 服务启动失败，请检查日志"
    docker-compose logs
    exit 1
fi

echo "🎉 部署完成！"
echo ""
echo "常用命令："
echo "  查看日志: docker-compose logs -f"
echo "  停止服务: docker-compose down"
echo "  重启服务: docker-compose restart"
echo "  更新应用: git pull && docker-compose build && docker-compose up -d"