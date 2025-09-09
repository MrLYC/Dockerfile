# IMAP MCP Server Docker Image

这个 Docker 镜像包含了 [imap-mcp](https://github.com/non-dirty/imap-mcp) MCP (Model Context Protocol) 服务器，它允许 AI 助手安全地访问和管理 IMAP 邮箱。

## 功能特性

- **邮件浏览**: 列出文件夹和邮件，支持过滤选项
- **邮件内容**: 读取邮件内容，包括文本、HTML 和附件
- **邮件操作**: 移动、删除、标记已读/未读、加标旗
- **邮件撰写**: 起草和保存回复邮件，支持正确的格式化
- **搜索功能**: 跨文件夹的基本搜索功能
- **OAuth2 支持**: 安全的 Gmail OAuth2 认证

## 构建镜像

```bash
docker build -t imap-mcp ./images/imap-mcp/
```

## 使用方法

### 1. 准备配置文件

复制示例配置文件并填入你的邮箱设置：

```bash
cp ./images/imap-mcp/config.yaml.example config.yaml
# 编辑 config.yaml 文件，填入你的邮箱配置
```

### 2. Gmail OAuth2 设置

如果使用 Gmail，需要设置 OAuth2 认证：

1. 访问 [Google Cloud Console](https://console.cloud.google.com/)
2. 创建新项目或选择现有项目
3. 启用 Gmail API
4. 创建 OAuth2 凭据（桌面应用程序类型）
5. 下载客户端配置
6. 在 `config.yaml` 中填入相关信息

### 3. 运行容器

```bash
# 运行 IMAP MCP 服务器
docker run -it --rm \
  -v $(pwd)/config.yaml:/app/config/config.yaml:ro \
  imap-mcp
```

### 4. 开发模式运行

```bash
# 以开发模式运行（启用调试）
docker run -it --rm \
  -v $(pwd)/config.yaml:/app/config/config.yaml:ro \
  imap-mcp \
  --dev
```

### 5. 与 Claude Desktop 集成

在你的 Claude Desktop 配置中添加：

```json
{
  "mcpServers": {
    "imap_mcp": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-v", "/path/to/config.yaml:/app/config/config.yaml:ro",
        "imap-mcp"
      ]
    }
  }
}
```

## OAuth2 令牌管理

### 刷新令牌

```bash
docker run -it --rm \
  -v $(pwd)/config.yaml:/app/config/config.yaml \
  imap-mcp \
  uv run imap_mcp.auth_setup refresh-token --config /app/config/config.yaml
```

### 生成新令牌

```bash
docker run -it --rm \
  -v $(pwd)/config.yaml:/app/config/config.yaml \
  imap-mcp \
  uv run imap_mcp.auth_setup generate-token --config /app/config/config.yaml
```

## 配置选项

| 配置项 | 描述 | 示例 |
|--------|------|------|
| `imap.host` | IMAP 服务器地址 | `imap.gmail.com` |
| `imap.port` | IMAP 服务器端口 | `993` |
| `imap.username` | 邮箱用户名 | `user@gmail.com` |
| `imap.use_ssl` | 是否使用 SSL | `true` |
| `imap.oauth2.client_id` | OAuth2 客户端 ID | (从 Google Cloud Console 获取) |
| `imap.oauth2.client_secret` | OAuth2 客户端密钥 | (从 Google Cloud Console 获取) |
| `imap.oauth2.refresh_token` | OAuth2 刷新令牌 | (从认证流程获取) |

## 支持的邮件提供商

- **Gmail**: 推荐使用 OAuth2 认证
- **Outlook/Hotmail**: 使用 IMAP 基本认证
- **Yahoo Mail**: 使用应用专用密码
- **其他 IMAP 提供商**: 根据提供商设置调整配置

## 安全注意事项

- **敏感数据**: 此服务器需要访问你的邮箱账户，包含敏感个人信息
- **凭据安全**: 使用环境变量或安全的凭据存储来保存邮箱凭据
- **应用专用密码**: 考虑使用应用专用密码而不是主账户密码
- **文件夹限制**: 仅限制访问必要的文件夹
- **权限审查**: 定期检查邮件提供商设置中授予服务器的权限

## 故障排除

1. **连接问题**: 检查 IMAP 设置和网络连接
2. **认证失败**: 验证 OAuth2 令牌或密码的有效性
3. **权限错误**: 确保启用了 IMAP 访问并设置了正确的权限
4. **SSL 错误**: 验证 SSL 设置和证书

## 可用的邮件操作

- 列出邮箱文件夹
- 浏览和搜索邮件
- 读取邮件内容和附件
- 标记邮件（已读/未读、重要等）
- 移动和删除邮件
- 撰写和发送回复
- 管理草稿