# Dockerfile

这个项目包含多个 Docker 镜像的构建配置和自动化构建流程。

## 项目结构

```
.
├── images/                    # 镜像构建目录
│   └── hello-world/          # hello-world 镜像
│       └── Dockerfile        # hello-world 的 Dockerfile
├── .github/
│   └── workflows/
│       └── docker-build.yaml # GitHub Actions 自动构建配置
├── image-requests.txt        # 手动指定需要构建的镜像列表
├── build-images.sh           # 本地构建脚本
├── create-image.sh           # 新镜像创建脚本
├── test-images.sh            # 镜像测试脚本
├── build.sh                  # 原始构建脚本
├── entry.sh                  # 原始入口脚本
├── Dockerfile                # 原始 Dockerfile
└── README.md                 # 项目说明文档
```

## 镜像管理

### 添加新镜像

#### 使用创建脚本（推荐）

```bash
# 查看帮助
./create-image.sh --help

# 创建基于 Alpine 的简单镜像
./create-image.sh my-app

# 创建基于不同模板的镜像
./create-image.sh -t node my-node-app
./create-image.sh -t python my-python-app
./create-image.sh -t golang my-go-app

# 创建带自定义描述的镜像
./create-image.sh -d "我的应用程序" my-app

# 预览将要创建的内容（不实际创建）
./create-image.sh --dry-run my-app
```

支持的模板：
- `alpine`: 基于 Alpine Linux 的轻量级镜像
- `ubuntu`: 基于 Ubuntu 的镜像
- `node`: Node.js 应用镜像
- `python`: Python 应用镜像
- `golang`: Go 应用镜像（多阶段构建）

#### 手动创建

1. 在 `images/` 目录下创建新的子目录，目录名即为镜像名
2. 在子目录中创建 `Dockerfile`
3. 提交代码到仓库

### 本地构建

使用 `build-images.sh` 脚本进行本地构建：

```bash
# 查看帮助
./build-images.sh --help

# 列出所有可用镜像
./build-images.sh --list

# 构建指定镜像
./build-images.sh hello-world

# 构建指定镜像并指定标签
./build-images.sh -t v1.0.0 hello-world

# 构建所有镜像
./build-images.sh --all

# 构建并推送到 Docker Hub
./build-images.sh -p hello-world

# 仅显示将要执行的命令（不实际构建）
./build-images.sh --dry-run hello-world
```

### 测试镜像

使用 `test-images.sh` 脚本测试已构建的镜像：

```bash
# 查看帮助
./test-images.sh --help

# 测试指定镜像
./test-images.sh hello-world

# 测试所有本地镜像
./test-images.sh --all

# 列出可测试的镜像
./test-images.sh --list

# 设置容器运行超时时间
./test-images.sh --timeout 60 hello-world
```

### 自动构建

#### 触发条件
- 代码推送到 `master` 或 `main` 分支
- Pull Request 合并到 `master` 或 `main` 分支
- 手动触发（支持指定镜像或强制构建所有镜像）

#### 手动触发

可以在 GitHub Actions 页面手动触发构建：

1. 进入 Actions 标签页
2. 选择 "Build and Push Docker Images" workflow
3. 点击 "Run workflow" 
4. 可选填入：
   - 特定镜像名（仅构建指定镜像）
   - 勾选"强制构建所有镜像"

#### 构建流程

当代码合并到主分支时，GitHub Actions 会自动：

1. 检测 `images/` 目录下哪些镜像发生了变更
2. 读取 `image-requests.txt` 文件中指定的额外镜像列表
3. 合并变更检测和手动请求的镜像列表
4. 自动构建所有需要构建的镜像
5. 使用当前时间作为标签推送到 Docker Hub
6. 同时更新 `latest` 标签

#### 手动指定构建镜像

除了自动检测变更外，您还可以通过 `image-requests.txt` 文件手动指定需要重新构建的镜像：

1. 编辑项目根目录下的 `image-requests.txt` 文件
2. 每行添加一个镜像名称（对应 `images/` 目录下的子目录名）
3. 以 `#` 开头的行为注释，空行会被忽略
4. 提交文件更改到仓库

示例 `image-requests.txt` 内容：
```
# 需要重新构建的镜像列表
alpine-sshd
jupyter
minio
```

这样即使这些镜像的代码没有变更，GitHub Actions 也会重新构建它们。这对于以下场景很有用：
- 基础镜像更新后需要重新构建
- 修复安全漏洞
- 更新依赖包版本
- 定期重新构建镜像以获取最新补丁

## 配置要求

### GitHub Secrets

需要在 GitHub 仓库设置中配置以下 Secrets：

- `DOCKER_HUB_USERNAME`: Docker Hub 用户名
- `DOCKER_HUB_TOKEN`: Docker Hub 访问令牌

### 镜像命名规则

- 镜像名称：`{DOCKER_HUB_USERNAME}/{目录名}`
- 标签格式：`YYYYMMDD-HHMMSS`（基于构建时间）
- 同时会打上 `latest` 标签

## 示例镜像

### hello-world

基于 Alpine Linux 的简单示例镜像，包含：

- 基础的系统工具（bash, curl, ca-certificates）
- 一个简单的 hello-world 脚本
- 非 root 用户运行

使用方法：

```bash
# 本地构建
./build-images.sh hello-world

# 运行镜像
docker run --rm {your-username}/hello-world:latest
```

## 贡献指南

1. Fork 这个仓库
2. 创建你的功能分支
3. 在 `images/` 目录下添加或修改镜像配置
4. 提交你的更改
5. 创建 Pull Request

当 PR 合并后，相关的镜像会自动构建和发布。
