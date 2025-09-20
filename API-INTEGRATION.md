# GetVideo API 集成文档

## 概述

GetVideo 提供完整的 RESTful API 接口，支持与 n8n、Coze 等自动化平台集成。所有 API 均支持 API Key 认证。

## 认证方式

### API Key 认证

所有 API 请求需要在请求头中包含 API Key：

```http
X-API-Key: vds_your_api_key_here
```

或使用 Bearer Token 格式：

```http
Authorization: Bearer vds_your_api_key_here
```

## 核心 API 接口

### 1. 健康检查

**GET** `/api/health`

检查服务状态，无需认证。

```bash
curl -X GET http://localhost:3000/api/health
```

**响应示例：**
```json
{
  "status": "healthy",
  "timestamp": "2025-01-01T00:00:00.000Z",
  "services": {
    "yt-dlp": {
      "status": "available",
      "version": "2024.12.16"
    }
  }
}
```

### 2. 创建下载任务

**POST** `/api/download`

创建新的视频下载任务。

**请求头：**
```http
Content-Type: application/json
X-API-Key: your_api_key
```

**请求体：**
```json
{
  "url": "https://www.youtube.com/watch?v=example",
  "format": "video",
  "quality": "best"
}
```

**参数说明：**
- `url` (必需): 视频链接
- `format` (可选): 下载格式，可选值：`video`、`audio`、`thumbnail`，默认 `video`
- `quality` (可选): 视频质量，如 `best`、`720p`、`480p`，默认 `best`

**响应示例：**
```json
{
  "taskId": "1234567890-abcdef123",
  "status": "pending",
  "message": "下载任务已创建",
  "timestamp": "2025-01-01T00:00:00.000Z"
}
```

**错误响应：**
```json
{
  "error": "请提供有效的URL",
  "code": "INVALID_URL", 
  "timestamp": "2025-01-01T00:00:00.000Z"
}
```

### 3. 查询任务状态

**GET** `/api/status/{taskId}`

查询指定任务的下载状态和进度。

**请求头：**
```http
X-API-Key: your_api_key
```

**响应示例：**
```json
{
  "task": {
    "id": "1234567890-abcdef123",
    "url": "https://www.youtube.com/watch?v=example",
    "format": "video",
    "quality": "best",
    "status": "downloading",
    "progress": 75.5,
    "filename": "example_video.mp4",
    "error": null,
    "createdAt": "2025-01-01T00:00:00.000Z",
    "startedAt": "2025-01-01T00:00:01.000Z",
    "completedAt": null,
    "fileSize": 1048576,
    "downloadUrl": "/downloads/example_video.mp4"
  },
  "timestamp": "2025-01-01T00:00:00.000Z"
}
```

**状态说明：**
- `pending`: 等待开始
- `downloading`: 下载中
- `completed`: 已完成
- `error`: 下载失败

### 4. 获取任务列表

**GET** `/api/download`

获取所有下载任务列表。

**请求头：**
```http
X-API-Key: your_api_key
```

**响应示例：**
```json
{
  "tasks": [
    {
      "id": "1234567890-abcdef123",
      "url": "https://www.youtube.com/watch?v=example1",
      "status": "completed",
      "progress": 100,
      "filename": "example1.mp4",
      "createdAt": "2025-01-01T00:00:00.000Z"
    },
    {
      "id": "0987654321-fedcba456", 
      "url": "https://www.youtube.com/watch?v=example2",
      "status": "downloading",
      "progress": 45.2,
      "filename": "example2.mp4",
      "createdAt": "2025-01-01T00:01:00.000Z"
    }
  ],
  "timestamp": "2025-01-01T00:00:00.000Z"
}
```

### 5. 获取视频信息

**POST** `/api/get-url`

获取视频的元信息（标题、缩略图等），不下载视频文件。

**请求头：**
```http
Content-Type: application/json
X-API-Key: your_api_key
```

**请求体：**
```json
{
  "videolink": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
  "apikey": "your_api_key"
}
```

**参数说明：**
- `videolink` (必需): 视频链接
- `apikey` (必需): API密钥

**响应示例：**
```json
{
  "code": 200,
  "data": {
    "imageSrc": "https://i.ytimg.com/vi_webp/dQw4w9WgXcQ/maxresdefault.webp",
    "link": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    "state": 1,
    "title": "Rick Astley - Never Gonna Give You Up (Official Video) (4K Remaster)",
    "videourl": "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
  },
  "msg": "获取视频信息成功"
}
```

**GET 方法支持：**
```http
GET /api/get-url?videolink=https://www.youtube.com/watch?v=dQw4w9WgXcQ&apikey=your_api_key
X-API-Key: your_api_key
```

**字段说明：**
- `code`: 状态码（200=成功，400=参数错误，500=服务器错误）
- `data.imageSrc`: 视频缩略图链接
- `data.link`: 原始视频链接
- `data.state`: 状态（1=成功）
- `data.title`: 视频标题
- `data.videourl`: 视频链接（标准化后）
- `msg`: 响应消息

**错误响应：**
```json
{
  "code": 400,
  "data": null,
  "msg": "缺少视频链接参数"
}
```

## n8n 集成示例

### HTTP Request 节点配置

1. **创建下载任务**
   - Method: `POST`
   - URL: `http://your-server:3000/api/download`
   - Headers: 
     ```json
     {
       "Content-Type": "application/json",
       "X-API-Key": "{{$env.GETVIDEO_API_KEY}}"
     }
     ```
   - Body:
     ```json
     {
       "url": "{{$json.video_url}}",
       "format": "{{$json.format || 'video'}}",
       "quality": "{{$json.quality || 'best'}}"
     }
     ```

2. **查询任务状态**
   - Method: `GET`
   - URL: `http://your-server:3000/api/status/{{$json.taskId}}`
   - Headers:
     ```json
     {
       "X-API-Key": "{{$env.GETVIDEO_API_KEY}}"
     }
     ```

### n8n 工作流示例

```json
{
  "name": "Video Download Workflow",
  "nodes": [
    {
      "name": "Start",
      "type": "n8n-nodes-base.manualTrigger"
    },
    {
      "name": "Create Download Task",
      "type": "n8n-nodes-base.httpRequest",
      "parameters": {
        "method": "POST",
        "url": "http://your-server:3000/api/download",
        "headers": {
          "X-API-Key": "{{$env.GETVIDEO_API_KEY}}"
        },
        "body": {
          "url": "https://www.youtube.com/watch?v=example",
          "format": "video",
          "quality": "720p"
        }
      }
    },
    {
      "name": "Wait",
      "type": "n8n-nodes-base.wait",
      "parameters": {
        "amount": 10,
        "unit": "seconds"
      }
    },
    {
      "name": "Check Status",
      "type": "n8n-nodes-base.httpRequest",
      "parameters": {
        "method": "GET",
        "url": "http://your-server:3000/api/status/{{$json.taskId}}",
        "headers": {
          "X-API-Key": "{{$env.GETVIDEO_API_KEY}}"
        }
      }
    }
  ]
}
```

## Coze 集成示例

### API 插件配置

1. **添加 API 插件**
   - 名称: GetVideo
   - Base URL: `http://your-server:3000`
   - 认证方式: API Key
   - API Key Header: `X-API-Key`

2. **定义操作**

**下载视频：**
```yaml
name: download_video
description: 下载视频文件
endpoint: /api/download
method: POST
parameters:
  - name: url
    type: string
    required: true
    description: 视频链接
  - name: format
    type: string
    required: false
    description: 格式(video/audio/thumbnail)
  - name: quality
    type: string
    required: false
    description: 质量(best/720p/480p等)
```

**查询状态：**
```yaml
name: check_status
description: 查询下载状态
endpoint: /api/status/{taskId}
method: GET
parameters:
  - name: taskId
    type: string
    required: true
    description: 任务ID
```

### Coze Bot 示例对话

```
用户: 帮我下载这个视频 https://www.youtube.com/watch?v=example

Bot: 好的，我来帮您下载这个视频。

[调用 download_video API]
- url: https://www.youtube.com/watch?v=example
- format: video
- quality: best

任务已创建，任务ID: 1234567890-abcdef123
正在下载中，请稍等...

[等待并调用 check_status API]
- taskId: 1234567890-abcdef123

下载完成！文件名: example_video.mp4
下载进度: 100%
```

## 错误处理

### 认证错误

```json
{
  "error": "API key is required",
  "code": "AUTH_FAILED",
  "timestamp": "2025-01-01T00:00:00.000Z"
}
```

**HTTP 状态码：** 401 Unauthorized

### 权限错误

```json
{
  "error": "Insufficient permissions", 
  "code": "AUTH_FAILED",
  "timestamp": "2025-01-01T00:00:00.000Z"
}
```

**HTTP 状态码：** 401 Unauthorized

### 速率限制

```json
{
  "error": "Rate limit exceeded",
  "code": "RATE_LIMIT_EXCEEDED", 
  "timestamp": "2025-01-01T00:00:00.000Z"
}
```

**HTTP 状态码：** 429 Too Many Requests

### 服务器错误

```json
{
  "error": "服务器内部错误",
  "code": "INTERNAL_ERROR",
  "timestamp": "2025-01-01T00:00:00.000Z"
}
```

**HTTP 状态码：** 500 Internal Server Error

## API Key 管理

### 创建 API Key

1. 访问管理后台: `http://your-server:3000/admin/login`
2. 使用管理员账户登录
3. 进入 "API Key 管理" → "创建 API Key"
4. 配置权限和限制
5. 保存并复制生成的 API Key

### 权限配置

**资源类型：**
- `download`: 下载服务权限
- `status`: 状态查询权限  
- `get-url`: 视频信息获取权限
- `admin`: 管理功能权限
- `*`: 全部资源权限

**操作类型：**
- `read`: 读取权限
- `write`: 写入权限
- `delete`: 删除权限
- `*`: 全部操作权限

**推荐配置：**
- n8n/Coze 集成: `download:write` + `status:read` + `get-url:write`
- 视频信息获取: `get-url:write`
- 监控系统: `status:read`
- 全功能应用: `*:*`

## 最佳实践

### 1. 安全建议

- 使用 HTTPS 传输
- 定期轮换 API Key
- 设置合理的使用限制
- 配置 IP 白名单
- 监控 API 使用情况

### 2. 性能优化

- 合理设置轮询间隔
- 使用批量操作
- 实现错误重试机制
- 缓存任务状态

### 3. 错误处理

- 检查 HTTP 状态码
- 解析错误响应
- 实现指数退避重试
- 记录错误日志

## 技术支持

如需技术支持或有疑问，请通过以下方式联系：

- GitHub Issues
- 系统日志：`/admin/logs`
- 健康检查：`/api/health`

---

**版本:** v1.0.0  
**更新时间:** 2025-01-01  
**兼容性:** n8n v1.x, Coze Bot Platform