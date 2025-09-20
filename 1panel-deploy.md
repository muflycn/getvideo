# 1Panel 部署指南

本文档详细说明如何在 1Panel 上部署 GetVideo 应用。

## 前置要求

- 已安装 1Panel
- 服务器有足够的存储空间
- 网络连接正常

## 部署步骤

### 1. 准备文件

将以下文件上传到服务器：
- `docker-compose.yml`
- `Dockerfile`
- 整个项目源码

### 2. 在 1Panel 中创建应用

1. 登录 1Panel 管理界面
2. 进入 "应用商店" -> "自定义应用"
3. 点击 "创建应用"

### 3. 配置应用信息

**基本信息：**
- 应用名称: `getvideo`
- 应用描述: `视频下载应用`
- 应用图标: 可选

**Docker Compose 配置：**
```yaml
version: '3.8'

services:
  getvideo-app:
    build: .
    ports:
      - "3000:3000"
    volumes:
      - ./downloads:/app/downloads
      - /etc/localtime:/etc/localtime:ro
    environment:
      - NODE_ENV=production
      - DOWNLOAD_PATH=/app/downloads
      - MAX_CONCURRENT_DOWNLOADS=3
    restart: unless-stopped
    container_name: getvideo-app

networks:
  default:
    name: getvideo-network
```

### 4. 配置端口映射

- 内部端口: 3000
- 外部端口: 3000 (或其他可用端口)

### 5. 配置数据卷

| 容器路径 | 主机路径 | 描述 |
|----------|----------|------|
| `/app/downloads` | `./downloads` | 下载文件存储 |
| `/etc/localtime` | `/etc/localtime` | 时区同步 |

### 6. 配置环境变量

| 变量名 | 值 | 描述 |
|--------|-----|------|
| `NODE_ENV` | `production` | 运行环境 |
| `DOWNLOAD_PATH` | `/app/downloads` | 下载路径 |
| `MAX_CONCURRENT_DOWNLOADS` | `3` | 最大并发下载数 |

### 7. 网络配置

如果需要使用反向代理（推荐）：

1. 在 1Panel 中配置 Nginx
2. 创建网站，配置反向代理到 `http://localhost:3000`
3. 可选：配置 SSL 证书

**Nginx 配置示例：**
```nginx
server {
    listen 80;
    server_name your-domain.com;

    client_max_body_size 100M;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 8. 启动应用

1. 点击 "创建并启动"
2. 等待镜像构建和容器启动
3. 检查应用状态

### 9. 验证部署

访问 `http://your-server-ip:3000` 或配置的域名，确认：
- 网页界面正常显示
- API 接口可以访问
- 下载功能正常工作

## 监控和维护

### 查看日志

在 1Panel 应用管理界面可以：
- 查看容器日志
- 监控资源使用情况
- 重启应用

### 备份配置

定期备份以下内容：
- `downloads` 目录（下载的文件）
- Docker Compose 配置
- 环境变量配置

### 更新应用

1. 上传新版本代码
2. 在 1Panel 中重新构建镜像
3. 重启容器

## 故障排除

### 常见问题

1. **容器启动失败**
   - 检查端口是否被占用
   - 检查文件权限
   - 查看容器日志

2. **下载失败**
   - 确认 yt-dlp 已正确安装
   - 检查网络连接
   - 查看 API 错误日志

3. **文件访问问题**
   - 检查数据卷映射
   - 确认文件权限设置
   - 验证下载目录路径

### 日志查看

在 1Panel 中可以直接查看应用日志，或通过命令行：

```bash
# 查看应用日志
docker logs getvideo-app

# 实时查看日志
docker logs -f getvideo-app
```

## 性能优化

### 资源配置

根据服务器配置调整：
- CPU 限制
- 内存限制
- 存储空间

### 并发下载数

通过环境变量 `MAX_CONCURRENT_DOWNLOADS` 调整并发下载数，建议：
- 1-2核 CPU: 2-3个并发
- 4核+ CPU: 3-5个并发

### 缓存配置

如果使用 Nginx 反向代理，可以配置静态文件缓存以提高性能。

## 安全建议

1. **访问控制**
   - 配置防火墙规则
   - 限制 API 访问频率
   - 使用 HTTPS

2. **文件管理**
   - 定期清理下载文件
   - 设置存储空间限制
   - 监控磁盘使用情况

3. **更新维护**
   - 定期更新 yt-dlp
   - 更新基础镜像
   - 应用安全补丁

## 技术支持

如遇到问题，可以：
1. 查看项目 README.md
2. 检查 GitHub Issues
3. 查看 1Panel 官方文档