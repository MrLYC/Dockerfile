# Docker 镜像仓库 - Copilot 指引

## 项目概述

本仓库包含各种开发工具和服务的 Docker 镜像定义。

## 仓库结构

```
/
├── .github/workflows/           # GitHub Actions CI/CD 工作流
│   └── docker-build.yaml      # 多平台 Docker 构建流水线
├── images/                     # Docker 镜像定义
├── build-images.sh            # 本地测试构建脚本
├── create-image.sh            # 新镜像模板脚本
├── test-images.sh             # 镜像测试脚本
├── migrate-branches.sh        # 分支迁移脚本
├── MIGRATION.md               # 迁移文档
└── README.md                  # 项目文档
```

## Docker 镜像标准

### 目录结构
`images/` 中的每个镜像应遵循以下结构：
```
images/<镜像名>/
├── Dockerfile                 # 优先使用多阶段构建
├── README.md                  # 使用文档
├── .env.example              # 配置模板（如需要）
├── config.yaml.example       # 配置模板（如需要）
├── build.sh                   # 构建脚本（如需要）
└── entry.sh                   # 入口脚本（如需要）
```

#### 多阶段构建
- 使用多阶段构建来最小化最终镜像大小
- 第一阶段：`builder` - 安装依赖和构建
- 最终阶段：仅包含必要组件的最小运行时镜像

#### 基础镜像
- **Go 项目**: `golang:1.23.2-alpine AS builder` → `alpine:latest`
- **Python 项目**: `python:3.11-alpine AS builder` → `python:3.11-alpine`
- **Node.js 项目**: `node:18-alpine AS builder` → `node:18-alpine`

#### 安全最佳实践
- 始终创建并使用非 root 用户
- 使用特定的用户/组 ID（例如 1001:1001）
- 仅安装必要的运行时依赖
- 对 apk 安装使用 `--no-cache`

#### Dockerfile 模板示例
```dockerfile
# <项目名> 的多阶段构建
FROM <基础镜像> AS builder

# 安装构建依赖
RUN apk add --no-cache \
    build-base \
    git \
    ca-certificates

WORKDIR /app

# 构建步骤...
# ...

# 最终阶段 - 最小运行时镜像
FROM <运行时镜像>

# 安装运行时依赖
RUN apk add --no-cache \
    ca-certificates

# 创建非 root 用户
RUN addgroup -g 1001 -S <用户名> && \
    adduser -S <用户名> -u 1001 -G <用户名>

WORKDIR /app

# 从构建阶段复制产物
COPY --from=builder /app/<二进制文件> .

# 设置所有权
RUN chown -R <用户名>:<用户名> /app

# 切换到非 root 用户
USER <用户名>

# 暴露端口（如需要）
EXPOSE <端口>

# 设置入口点和默认命令
ENTRYPOINT ["./<二进制文件>"]
CMD ["--help"]
```

## GitHub Actions 集成

### 构建策略
- 多平台构建：`linux/amd64,linux/arm64`
- 基于 `images/` 中变更文件的自动镜像检测
- 三种标签策略：
  - Git SHA（8 字符）：`a1b2c3d4`
  - 分支名称：`main`、`images`
  - 最新版本：`latest`

### Docker Hub 集成
镜像自动构建并推送到 Docker Hub，命名规则：
`<docker-用户名>/<镜像名>:<标签>`

## 代码生成指引

### 创建新镜像时
1. 在 `images/<新镜像名>/` 中创建目录
2. 按照上述模板生成 Dockerfile
3. 创建包含以下内容的完整 README.md：
   - 功能概述
   - 构建说明
   - 使用示例
   - 配置选项
   - 安全考虑
   - 故障排除指南

### 修改现有镜像时
1. 保留现有安全配置
2. 保持向后兼容性
3. 相应更新文档
4. 提交前本地测试构建

### 错误处理模式
- 始终在 Dockerfile 中检查必需工具
- 在脚本中提供清晰的错误消息
- 优雅处理缺失依赖
- 尽可能包含备用选项

### 版本管理
- 当稳定性至关重要时使用特定版本的基础镜像
- 固定依赖版本以确保可重现构建
- 对开发工具使用最新稳定版本
- 在注释中记录版本选择

## 开发工作流

### 本地测试
```bash
# 构建特定镜像
docker build -t <镜像名>-test ./images/<镜像名>/

# 测试镜像功能
docker run --rm <镜像名>-test

# 使用挂载卷测试
docker run --rm -v $(pwd):/workspace <镜像名>-test
```

### 自动创建 GitHub Pull Request
如果我提到需要创建一个 Pull Request，执行类似的命令，注意要自动填充 title 和 body 参数，使用 web 页面打开：
```bash
$ gh pr create --title "Remove failed docker image builds" --body "Removed 17 failed image directories based on GitHub Actions build results (run #17589497811):

**Removed images:**
- chrome-vnc, httplive, kcptun, docker-utils
- centos, hexo, devteam, kcptun-client
- nextcloud, minicron, webcron, ubuntu
- zabbix, webdav, sslocal, ipython, yapf

These images had various build failures including missing Dockerfiles, dependency installation failures, and base image issues.

**Preserved successful/working images:**
- alpine-sshd, beanstalkd, copilot-metrics-dashboard
- dev-kit-mcp, hello-world, imap-mcp, jupyter
- lamptun, minio, opengrok, pyspider
- snmpd, ssh-client, tox, versifier" --base master --head images --web
```

## 常见模式

### OAuth2 设置（适用于 Gmail、GitHub 等）
1. 记录所需的 OAuth2 范围
2. 提供逐步设置说明
3. 包含令牌刷新机制
4. 优雅处理身份验证错误

### 配置模板
- 始终提供示例配置
- 记录所有可用选项
- 包含安全建议
- 尽可能提供验证

### 日志记录和调试
- 支持可配置的日志级别
- 为开发提供调试模式
- 适用时包含健康检查端点
- 记录故障排除步骤

## AI 辅助最佳实践

在使用此仓库时：
1. 始终遵循既定的模式和约定
2. 优先考虑安全性和最小攻击面
3. 确保全面的文档
4. 测试多平台兼容性
5. 保持一致的命名和结构
6. 考虑向后兼容性
7. 清楚记录任何破坏性变更

## 已迁移镜像

以下镜像已从独立分支迁移到统一的 `images/` 结构：

### 基础设施服务
- `alpine-sshd` - 基于 Alpine 的安全 SSH 服务器
- `ubuntu` - 带工具的 Ubuntu 基础镜像
- `centos` - CentOS 企业 Linux 环境

### 开发工具
- `devteam` - 完整的开发团队环境
- `jupyter` - Jupyter 数据科学环境
- `ipython` - 交互式 Python 环境
- `tox` - Python 多环境测试工具
- `yapf` - Python 代码格式化工具

### Web 服务
- `hexo` - 静态站点生成器
- `nextcloud` - 云存储平台
- `webdav` - WebDAV 文件共享服务器
- `httplive` - HTTP 实时流媒体服务

### 存储和数据库
- `minio` - S3 兼容的对象存储
- `beanstalkd` - 工作队列服务器

### 网络工具
- `kcptun` / `kcptun-client` - 网络加速隧道
- `sslocal` - Shadowsocks 本地代理
- `ssh-client` - SSH 客户端工具

### 监控和管理
- `zabbix` - 基础设施监控解决方案
- `snmpd` - SNMP 守护进程
- `webcron` - 基于 Web 的定时任务管理
- `minicron` - 轻量级定时任务守护进程
- `opengrok` - 源代码搜索引擎

### 其他工具
- `pyspider` - Python 网络爬虫框架
- `docker-utils` - Docker 管理工具
- `chrome-vnc` - 带 VNC 的 Chrome 浏览器
- `lamptun` - LAMP 栈隧道

所有这些镜像现在都遵循现代 Docker 最佳实践，包括安全的非 root 用户、健康检查和优化的多阶段构建。
