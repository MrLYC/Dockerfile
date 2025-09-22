# didatodolist-mcp

基于 [GalaxyXieyu/didatodolist-mcp](https://github.com/GalaxyXieyu/didatodolist-mcp) 项目构建的 Docker 镜像。

## 项目简介

滴答清单MCP（Memory-Context-Planning）服务是一个基于Python的后端服务，为用户提供目标管理、任务统计分析、关键词提取和任务-目标匹配等功能。该服务作为滴答清单主应用的辅助功能，帮助用户更好地规划和跟踪个人及团队目标完成情况。

## 功能特性

- **目标管理**：创建、查询、更新和删除个人目标
- **任务统计分析**：生成任务完成情况统计报告
- **关键词提取**：基于任务内容提取关键词（基于jieba分词）
- **任务与目标匹配**：智能匹配任务与相关目标
- **目标完成进度计算**：分析并可视化目标完成进度

## 技术栈

- **语言**: Python 3.11
- **框架**: FastMCP
- **依赖**: requests, pandas, jieba, numpy, wordcloud, matplotlib, scikit-learn
- **基础镜像**: python:3.11-slim

## 构建镜像

```bash
docker build -t didatodolist-mcp .
```

## 运行容器

### 认证方式

您可以通过环境变量或挂载配置文件来提供滴答清单的认证信息。

#### 1. 使用环境变量

```bash
docker run --rm -it \
  -e DIDA_EMAIL="your_email@example.com" \
  -e DIDA_PASSWORD="your_password" \
  didatodolist-mcp
```

或者使用 Token：

```bash
docker run --rm -it \
  -e DIDA_TOKEN="your_dida_token" \
  didatodolist-mcp
```

#### 2. 使用配置文件

首先，在您的宿主机上创建一个 `config.json` 文件：

```json
{
  "email": "your_email@example.com",
  "password": "your_password"
}
```

然后运行容器并挂载该文件：

```bash
docker run --rm -it \
  -v $(pwd)/config.json:/app/config.json \
  didatodolist-mcp
```

### 运行模式

#### 默认 Stdio 模式

```bash
docker run --rm -i didatodolist-mcp
```

#### SSE 模式

如果您需要通过网络访问 MCP 服务，可以启动 SSE (Server-Sent Events) 模式：

```bash
docker run --rm -it \
  -p 3000:3000 \
  -e DIDA_TOKEN="your_dida_token" \
  didatodolist-mcp python main.py --sse --host 0.0.0.0 --port 3000
```

### 数据持久化

该服务会在 `/app/data` 目录下生成 `goals.csv` 等数据文件。为了持久化这些数据，您可以挂载一个宿主机目录：

```bash
docker run --rm -it \
  -v $(pwd)/my_dida_data:/app/data \
  -e DIDA_TOKEN="your_dida_token" \
  didatodolist-mcp
```

## 安全说明

- 镜像使用非 root 用户 `mcpuser` 运行。
- 建议使用环境变量传递敏感信息，而不是直接写入 `config.json`。

## 参考链接

- [原始项目](https://github.com/GalaxyXieyu/didatodolist-mcp)
- [Model Context Protocol](https://modelcontextprotocol.io/)
- [FastMCP](https://github.com/jlowin/fastmcp)
