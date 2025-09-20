# GetVideo 部署指南

GetVideo 是一个基于 Next.js 的视频下载应用，支持 API 密钥管理和后台管理功能。

## 🚀 快速部署（1Panel 推荐）

### 1. 使用 1Panel 应用商店

如果已提交到 1Panel 应用商店，可直接安装：

1. 打开 1Panel 控制面板
2. 进入"应用商店"
3. 搜索"GetVideo"
4. 点击安装并配置相关参数

### 2. 手动 Docker Compose 部署

#### 2.1 准备工作

```bash
# 克隆项目（或下载源码）
git clone <your-repo-url>
cd getvideo

# 创建必要的目录
mkdir -p data downloads logs

# 复制环境变量配置
cp .env.example .env
```

#### 2.2 配置环境变量

编辑 `.env` 文件：

```env
# 修改为安全的随机字符串
SESSION_SECRET=your-very-secure-random-string-here

# 可选：设置首次部署的管理员账户
ADMIN_USERNAME=admin
ADMIN_PASSWORD=your-secure-password

# 其他配置保持默认即可
```

#### 2.3 启动服务

```bash
# 构建并启动
docker-compose up -d

# 查看日志
docker-compose logs -f getvideo-app

# 检查健康状态
curl http://localhost:3000/api/health
```

## 🔧 初始化配置

### 方法1：自动创建管理员（推荐）

如果在 `.env` 中配置了 `ADMIN_USERNAME` 和 `ADMIN_PASSWORD`，系统会在首次启动时自动创建管理员账户。

### 方法2：手动初始化

```bash
# 进入容器
docker exec -it getvideo-app /bin/sh

# 运行初始化脚本
node scripts/init-admin.js

# 按提示输入管理员信息
```

## 📝 访问地址

- **前端页面**：http://localhost:3000
- **管理后台**：http://localhost:3000/admin/login
- **API 文档**：http://localhost:3000/api/health
- **健康检查**：http://localhost:3000/api/health

## 🔑 API 使用

### 1. 创建 API Key

1. 登录管理后台：http://localhost:3000/admin/login
2. 进入"API Key 管理"
3. 点击"创建 API Key"
4. 配置权限和限制
5. 保存并复制生成的密钥

### 2. 使用 API

```bash
# 创建下载任务
curl -X POST http://localhost:3000/api/download \\
  -H "X-API-Key: your-api-key-here" \\
  -H "Content-Type: application/json" \\
  -d '{
    "url": "https://www.youtube.com/watch?v=example",
    "format": "video",
    "quality": "best"
  }'

# 查询任务状态
curl -H "X-API-Key: your-api-key-here" \\
  http://localhost:3000/api/status/your-task-id
```

### 3. n8n 集成示例

```json
{
  "nodes": [
    {
      "parameters": {
        "url": "http://your-server:3000/api/download",
        "authentication": "genericCredentialType",
        "genericAuthType": "httpHeaderAuth",
        "httpHeaderAuth": {
          "name": "X-API-Key",
          "value": "your-api-key-here"
        },
        "requestMethod": "POST",
        "jsonParameters": true,
        "options": {
          "bodyContentType": "json"
        },
        "bodyParametersJson": {
          "url": "{{$json.video_url}}",
          "format": "video",
          "quality": "best"
        }
      },
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 1,
      "position": [800, 300],
      "name": "创建下载任务"
    }
  ]
}
```

## 🛡️ 安全配置

### 1. 反向代理（推荐）

在 1Panel 中配置 Nginx 反向代理：

```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### 2. SSL 证书

建议在 1Panel 中配置 SSL 证书以启用 HTTPS。

### 3. 防火墙设置

确保只开放必要的端口：
- HTTP: 80
- HTTPS: 443
- 管理后台：建议通过 VPN 访问

## 📊 监控和维护

### 1. 日志查看

```bash
# 查看应用日志
docker-compose logs -f getvideo-app

# 查看系统日志（在容器内）
docker exec getvideo-app ls -la /app/logs/
```

### 2. 数据备份

```bash
# 备份数据目录
tar -czf getvideo-backup-$(date +%Y%m%d).tar.gz data/

# 备份下载文件（可选）
tar -czf downloads-backup-$(date +%Y%m%d).tar.gz downloads/
```

### 3. 更新升级

```bash
# 拉取最新代码
git pull origin main

# 重新构建并启动
docker-compose up -d --build

# 清理旧镜像
docker image prune -f
```

## 🔍 故障排除

### 1. 容器启动失败

```bash
# 查看详细日志
docker-compose logs getvideo-app

# 检查端口占用
netstat -tlnp | grep :3000

# 检查磁盘空间
df -h
```

### 2. yt-dlp 下载失败

```bash
# 进入容器更新 yt-dlp
docker exec -it getvideo-app /bin/sh
pip3 install --upgrade yt-dlp

# 测试 yt-dlp
yt-dlp --version
```

### 3. 权限问题

```bash
# 检查目录权限
ls -la data/ downloads/ logs/

# 修复权限
sudo chown -R 1001:1001 data/ downloads/ logs/
```

## 🆘 技术支持

如遇到问题，请检查：

1. Docker 和 Docker Compose 版本
2. 系统资源（内存、磁盘空间）
3. 网络连接
4. 日志文件中的错误信息

## 📋 系统要求

- Docker 20.10+
- Docker Compose 2.0+
- 内存：至少 512MB
- 磁盘：至少 2GB 可用空间
- 网络：需要访问视频网站