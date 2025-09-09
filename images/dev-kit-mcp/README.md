# Dev Kit MCP Server Docker Image

这个 Docker 镜像包含了 [dev-kit](https://github.com/nguyenvanduocit/dev-kit) MCP (Model Context Protocol) 服务器，它允许 AI 模型与各种开发工具进行结构化和安全的交互。

## 功能特性

- **Atlassian 集成**: Jira 和 Confluence 支持
- **版本控制**: GitHub 和 GitLab 集成
- **脚本执行**: 安全的命令行脚本执行
- **多协议支持**: STDIO 和 SSE (Server-Sent Events) 协议

## 构建镜像

```bash
docker build -t dev-kit-mcp ./images/dev-kit-mcp/
```

## 使用方法

### 1. 准备环境配置

复制示例环境文件并填入你的配置：

```bash
cp ./images/dev-kit-mcp/.env.example .env
# 编辑 .env 文件，填入你的 API 令牌和配置
```

### 2. 运行容器 (STDIO 协议)

```bash
docker run -it --rm \
  --env-file .env \
  dev-kit-mcp
```

### 3. 运行容器 (SSE 协议)

```bash
docker run -d \
  --name dev-kit-mcp \
  --env-file .env \
  -p 8080:8080 \
  dev-kit-mcp \
  -protocol sse
```

### 4. 与 Claude Desktop 集成

在你的 Claude Desktop 配置中添加：

```json
{
  "mcpServers": {
    "dev_kit": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "--env-file", "/path/to/.env",
        "dev-kit-mcp",
        "-protocol", "stdio"
      ]
    }
  }
}
```

## 环境变量

| 变量名 | 描述 | 必需 |
|--------|------|------|
| `ATLASSIAN_HOST` | Atlassian 实例 URL | 使用 Jira/Confluence 时必需 |
| `ATLASSIAN_EMAIL` | Atlassian 账户邮箱 | 使用 Jira/Confluence 时必需 |
| `ATLASSIAN_TOKEN` | Atlassian API 令牌 | 使用 Jira/Confluence 时必需 |
| `GITLAB_HOST` | GitLab 实例 URL | 使用 GitLab 时必需 |
| `GITLAB_TOKEN` | GitLab 个人访问令牌 | 使用 GitLab 时必需 |
| `GITHUB_TOKEN` | GitHub 个人访问令牌 | 使用 GitHub 时必需 |
| `ENABLE_TOOLS` | 启用的工具组 (逗号分隔) | 可选 |
| `PROXY_URL` | HTTP/HTTPS 代理 URL | 可选 |
| `PORT` | SSE 服务器端口 | 可选 (默认: 8080) |

## 可用工具组

- `confluence`: Confluence 页面管理
- `github`: GitHub 仓库和问题管理
- `gitlab`: GitLab 项目和合并请求管理
- `jira`: Jira 问题跟踪
- `script`: 安全的脚本执行

## 安全注意事项

- 容器以非 root 用户运行
- 脚本执行具有安全限制
- 建议使用只读文件系统挂载配置文件
- 定期更新 API 令牌

## 故障排除

1. **连接问题**: 检查网络连接和代理设置
2. **认证失败**: 验证 API 令牌的有效性和权限
3. **工具不可用**: 检查 `ENABLE_TOOLS` 配置和相关环境变量