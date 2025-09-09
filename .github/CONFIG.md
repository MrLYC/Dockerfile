# GitHub Actions 配置说明

## 必需的 Secrets 配置

在 GitHub 仓库的 Settings > Secrets and variables > Actions 中添加以下 secrets：

### DOCKER_HUB_USERNAME
- **描述**: 你的 Docker Hub 用户名
- **值**: 例如 `mrlycz`

### DOCKER_HUB_TOKEN
- **描述**: Docker Hub 访问令牌（推荐使用 Access Token 而不是密码）
- **获取方式**:
  1. 登录 Docker Hub
  2. 进入 Account Settings > Security
  3. 点击 "New Access Token"
  4. 输入 token 名称（如 "github-actions"）
  5. 选择权限（通常选择 "Read, Write, Delete"）
  6. 生成并复制 token
- **值**: 生成的访问令牌

## 工作流程说明

### 触发条件
- 代码推送到 `master` 或 `main` 分支
- Pull Request 合并到 `master` 或 `main` 分支

### 构建流程
1. **检测变更**: 比较源分支和目标分支，找出 `images/` 目录下有变更的子目录
2. **并行构建**: 为每个变更的镜像创建独立的构建任务
3. **多架构支持**: 构建支持 `linux/amd64` 和 `linux/arm64` 架构的镜像
4. **标签管理**: 
   - 时间戳标签: `YYYYMMDD-HHMMSS`
   - 最新标签: `latest`
5. **推送到 Docker Hub**: 自动推送构建好的镜像

### 缓存优化
- 使用 GitHub Actions 缓存来加速构建
- 支持跨构建的层缓存复用

## 本地测试

在推送代码前，建议先在本地测试构建：

```bash
# 测试单个镜像构建
./build-images.sh hello-world

# 测试所有镜像构建
./build-images.sh --all

# 仅查看会执行的命令（不实际构建）
./build-images.sh --dry-run hello-world
```

## 故障排除

### 常见问题

1. **Docker Hub 认证失败**
   - 检查 `DOCKER_HUB_USERNAME` 和 `DOCKER_HUB_TOKEN` 是否正确设置
   - 确认 Docker Hub token 有足够的权限

2. **镜像构建失败**
   - 检查 Dockerfile 语法
   - 确认所有必需的文件都在镜像目录中
   - 查看 GitHub Actions 的详细日志

3. **变更检测不工作**
   - 确认文件变更在 `images/` 目录下
   - 检查提交历史和分支比较

4. **多架构构建失败**
   - 确认 Dockerfile 中的基础镜像支持多架构
   - 检查是否有架构特定的依赖

### 调试技巧

1. **查看构建日志**:
   - 在 GitHub Actions 页面查看详细的构建日志
   - 每个构建步骤都有独立的日志

2. **本地调试**:
   - 使用 `--dry-run` 选项查看会执行的命令
   - 在本地先测试 Docker 构建

3. **分步测试**:
   - 先测试单个镜像的构建
   - 再测试整个流程