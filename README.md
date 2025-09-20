# GetVideo - 视频下载应用

基于 yt-dlp 的视频/音频/图片下载应用，提供网页界面和 API 接口，支持 Docker 部署。

## 功能特性

- 🎥 **多平台支持**: 支持 YouTube、哔哩哔哩、抖音等主流视频平台
- 🎵 **多格式下载**: 支持视频、音频、缩略图下载
- 🌐 **网页界面**: 用户友好的 Web 界面
- 🔌 **API 接口**: 提供 RESTful API，支持 n8n、Coze 等平台集成
- 📊 **实时进度**: 实时显示下载进度
- 🐳 **Docker 部署**: 支持 Docker 和 1Panel 部署
- ⚡ **高性能**: 基于 Next.js 14 构建

## 技术栈

- **前端**: Next.js 14 + TypeScript + Tailwind CSS
- **后端**: Node.js API Routes
- **下载引擎**: yt-dlp
- **部署**: Docker + Docker Compose

## 快速开始

### 使用 Docker Compose（推荐）

1. 克隆项目：
```bash
git clone <your-repo-url>
cd getvideo
```

2. 启动服务：
```bash
docker-compose up -d
```

3. 访问应用：
打开浏览器访问 `http://localhost:3000`

### 手动安装

1. 安装依赖：
```bash
npm install
```

2. 安装 yt-dlp：
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install yt-dlp

# macOS
brew install yt-dlp

# Windows
# 下载 yt-dlp.exe 并添加到 PATH
```

3. 运行开发服务器：
```bash
npm run dev
```

## API 文档

### 创建下载任务

**POST** `/api/download`

请求体：
```json
{
  "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
  "format": "video",  // video | audio | thumbnail
  "quality": "best"   // best | worst | 720p | 480p | 360p
}
```

响应：
```json
{
  "taskId": "uuid-task-id",
  "status": "pending",
  "message": "下载任务已创建"
}
```

### 查询任务状态

**GET** `/api/status/:taskId`

响应：
```json
{
  "task": {
    "id": "uuid-task-id",
    "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    "format": "video",
    "quality": "best",
    "status": "downloading",  // pending | downloading | completed | error
    "progress": 45.6,
    "filename": "video.mp4",
    "error": null,
    "createdAt": "2024-01-01T00:00:00.000Z",
    "startedAt": "2024-01-01T00:00:01.000Z",
    "completedAt": null
  }
}
```

### 获取所有任务

**GET** `/api/download`

响应：
```json
{
  "tasks": [
    {
      "id": "uuid-task-id",
      "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      "status": "completed",
      // ... 其他字段
    }
  ]
}
```

### 健康检查

**GET** `/api/health`

响应：
```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "services": {
    "yt-dlp": {
      "status": "available",
      "version": "2024.01.01"
    }
  }
}
```

## n8n 集成示例

在 n8n 中使用 HTTP Request 节点：

1. **创建下载任务**：
   - Method: POST
   - URL: `http://your-domain:3000/api/download`
   - Body: JSON 格式的请求数据

2. **查询任务状态**：
   - Method: GET
   - URL: `http://your-domain:3000/api/status/{{$json.taskId}}`

## Coze 集成示例

创建一个 API 工具：

```json
{
  "name": "download_video",
  "description": "下载视频/音频",
  "parameters": {
    "url": {
      "type": "string",
      "description": "视频链接"
    },
    "format": {
      "type": "string",
      "enum": ["video", "audio", "thumbnail"],
      "description": "下载格式"
    }
  },
  "api": {
    "method": "POST",
    "url": "http://your-domain:3000/api/download",
    "headers": {
      "Content-Type": "application/json"
    }
  }
}
```

## 1Panel 部署

1. 在 1Panel 中创建应用
2. 上传 `docker-compose.yml` 文件
3. 配置环境变量：
   - `DOWNLOAD_PATH=/app/downloads`
   - `MAX_CONCURRENT_DOWNLOADS=3`
4. 设置数据卷映射：
   - `./downloads:/app/downloads`
5. 启动服务

## 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `NODE_ENV` | `production` | 运行环境 |
| `DOWNLOAD_PATH` | `/app/downloads` | 下载文件存储路径 |
| `MAX_CONCURRENT_DOWNLOADS` | `3` | 最大并发下载数 |

## 支持的平台

- YouTube
- 哔哩哔哩 (Bilibili)
- 抖音 (TikTok)
- 快手
- 微博视频
- 爱奇艺
- 腾讯视频
- 优酷
- 更多平台请参考 [yt-dlp 支持列表](https://github.com/yt-dlp/yt-dlp/blob/master/supportedsites.md)

## 常见问题

### Q: 某些网站下载失败怎么办？
A: 确保 yt-dlp 版本是最新的，某些网站可能需要特定版本或配置。

### Q: 如何限制下载文件大小？
A: 可以在 yt-dlp 参数中添加 `--max-filesize` 选项。

### Q: 如何设置代理？
A: 在环境变量中设置 `HTTP_PROXY` 和 `HTTPS_PROXY`。

## 开发

```bash
# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 构建项目
npm run build

# 启动生产服务器
npm start

# 运行 lint
npm run lint
```

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！