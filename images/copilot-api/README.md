# Copilot API Docker Image

将 GitHub Copilot 转换为 OpenAI/Anthropic API 兼容服务器。可与 Claude Code 配合使用!

## 特性

- ✅ OpenAI API 兼容 (`/v1/chat/completions`)
- ✅ Anthropic API 兼容 (`/v1/messages`)
- ✅ 支持流式响应
- ✅ 自动令牌刷新
- ✅ 使用率监控
- ✅ 代理支持
- ✅ 速率限制控制

## 快速开始

### 1. 获取 GitHub Token

首先需要通过认证模式获取 GitHub Token:

```bash
docker run -it --rm \
  -v copilot-data:/home/copilot/.local/share/copilot-api \
  liuyicong/copilot-api --auth
```

按照提示在浏览器中授权,Token 将自动保存到卷中。

### 2. 启动服务器

使用保存的 Token 启动服务器:

```bash
docker run -d \
  --name copilot-api \
  -p 4141:4141 \
  -v copilot-data:/home/copilot/.local/share/copilot-api \
  liuyicong/copilot-api
```

或者直接提供 GitHub Token:

```bash
docker run -d \
  --name copilot-api \
  -p 4141:4141 \
  -e GH_TOKEN="your_github_token" \
  liuyicong/copilot-api
```

### 3. 测试 API

```bash
curl http://localhost:4141/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

## 配置选项

### 环境变量

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `GH_TOKEN` | GitHub Token | - |
| `HTTP_PROXY` | HTTP 代理 | - |
| `HTTPS_PROXY` | HTTPS 代理 | - |

### 启动参数

```bash
docker run -d \
  -p 4141:4141 \
  -v copilot-data:/home/copilot/.local/share/copilot-api \
  liuyicong/copilot-api \
  --port 8080 \              # 自定义端口
  --account-type business \  # 账户类型: individual/business/enterprise
  --rate-limit 1 \           # 请求间最小间隔(秒)
  --wait \                   # 速率限制时等待而非返回错误
  --verbose                  # 详细日志
```

完整参数列表:

- `--port, -p`: HTTP 服务器端口 (默认: 4141)
- `--github-token, -g`: 提供 GitHub Token
- `--account-type, -a`: Copilot 账户类型 (individual/business/enterprise)
- `--manual`: 手动批准每个请求
- `--rate-limit, -r`: 请求间最小间隔(秒)
- `--wait, -w`: 速率限制时等待而非返回错误
- `--verbose, -v`: 详细日志
- `--proxy-env`: 从环境变量初始化代理
- `--claude-code, -c`: 生成 Claude Code 启动命令

## 使用示例

### OpenAI 风格请求

```bash
curl http://localhost:4141/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4",
    "messages": [
      {"role": "system", "content": "You are a helpful assistant."},
      {"role": "user", "content": "Write a Python function to calculate fibonacci numbers."}
    ],
    "stream": false
  }'
```

### Anthropic 风格请求

```bash
curl http://localhost:4141/v1/messages \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-3-sonnet-20240229",
    "messages": [
      {"role": "user", "content": "Explain quantum computing"}
    ],
    "max_tokens": 1024
  }'
```

### 查看使用情况

```bash
curl http://localhost:4141/usage
```

### 查看可用模型

```bash
curl http://localhost:4141/v1/models
```

## 与 Claude Code 集成

启动服务器后,使用 `--claude-code` 参数生成配置命令:

```bash
docker run -it --rm \
  -v copilot-data:/home/copilot/.local/share/copilot-api \
  liuyicong/copilot-api --claude-code
```

## Docker Compose 示例

```yaml
version: '3.8'

services:
  copilot-api:
    image: liuyicong/copilot-api
    container_name: copilot-api
    ports:
      - "4141:4141"
    environment:
      - GH_TOKEN=${GH_TOKEN}  # 可选,也可使用卷存储
    volumes:
      - copilot-data:/home/copilot/.local/share/copilot-api
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--spider", "http://localhost:4141/"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 5s

volumes:
  copilot-data:
```

## 代理配置

如果需要通过代理访问 GitHub:

```bash
docker run -d \
  -p 4141:4141 \
  -e HTTP_PROXY="http://proxy.example.com:8080" \
  -e HTTPS_PROXY="http://proxy.example.com:8080" \
  -v copilot-data:/home/copilot/.local/share/copilot-api \
  liuyicong/copilot-api --proxy-env
```

## 持久化数据

Token 和配置存储在 `/home/copilot/.local/share/copilot-api`,建议使用卷挂载:

```bash
# 使用命名卷
docker volume create copilot-data

# 或使用绑定挂载
docker run -d \
  -p 4141:4141 \
  -v /path/to/local/data:/home/copilot/.local/share/copilot-api \
  liuyicong/copilot-api
```

## 安全建议

1. **保护 GitHub Token**: 
   - 使用 Docker secrets 或环境变量文件
   - 不要在日志或脚本中硬编码 Token

2. **网络隔离**:
   - 仅在内部网络暴露 API
   - 使用反向代理添加认证层

3. **限制访问**:
   - 使用 `--rate-limit` 防止滥用
   - 考虑使用 `--manual` 模式手动审批请求

## 故障排查

### 健康检查失败

```bash
# 查看日志
docker logs copilot-api

# 检查端口
docker exec copilot-api wget -O- http://localhost:4141/
```

### Token 无效

```bash
# 重新认证
docker run -it --rm \
  -v copilot-data:/home/copilot/.local/share/copilot-api \
  liuyicong/copilot-api --auth
```

### 权限问题

```bash
# 检查卷权限
docker run --rm -v copilot-data:/data alpine ls -la /data

# 修复权限
docker run --rm -v copilot-data:/data alpine chown -R 1000:1000 /data
```

## API 端点

| 端点 | 说明 |
|------|------|
| `GET /` | 健康检查 |
| `POST /v1/chat/completions` | OpenAI 兼容的聊天补全 |
| `POST /v1/messages` | Anthropic 兼容的消息 API |
| `GET /v1/models` | 列出可用模型 |
| `POST /v1/embeddings` | 文本嵌入 |
| `GET /usage` | 使用情况统计 |
| `GET /token` | 当前 Token 信息 |

## 技术栈

- **运行时**: Bun 1.2.19
- **基础镜像**: Alpine Linux
- **HTTP 框架**: Hono
- **进程管理**: tini

## 许可证

MIT License - 基于 [ericc-ch/copilot-api](https://github.com/ericc-ch/copilot-api)

## 相关链接

- [上游项目](https://github.com/ericc-ch/copilot-api)
- [问题反馈](https://github.com/ericc-ch/copilot-api/issues)
- [Docker Hub](https://hub.docker.com/r/liuyicong/copilot-api)
