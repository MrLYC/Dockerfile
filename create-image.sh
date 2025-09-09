#!/bin/bash

# 新镜像创建脚本
# 用于快速创建新的镜像目录和基础 Dockerfile

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示使用说明
show_usage() {
    echo "用法: $0 [选项] <镜像名>"
    echo "选项:"
    echo "  -h, --help                显示此帮助信息"
    echo "  -b, --base BASE_IMAGE     指定基础镜像 (默认: alpine:latest)"
    echo "  -t, --template TEMPLATE   使用模板 (可选: alpine, ubuntu, node, python, golang)"
    echo "  -d, --description DESC    镜像描述"
    echo "  --dry-run                 仅显示将要创建的内容，不实际创建"
    echo ""
    echo "示例:"
    echo "  $0 my-app                              # 创建基于 alpine 的简单镜像"
    echo "  $0 -t node my-node-app                 # 创建基于 node 模板的镜像"
    echo "  $0 -b ubuntu:20.04 my-ubuntu-app       # 创建基于指定基础镜像的镜像"
    echo "  $0 -d \"My application\" my-app         # 创建带描述的镜像"
}

# 生成 Dockerfile 内容
generate_dockerfile() {
    local base_image="$1"
    local description="$2"
    local template="$3"
    
    case "$template" in
        "alpine")
            cat << EOF
FROM ${base_image}

LABEL maintainer="lyc <imyikong@gmail.com>"
LABEL description="${description}"

# 安装基础工具
RUN apk add --no-cache \\
    ca-certificates \\
    tzdata

# 设置时区
ENV TZ=Asia/Shanghai

# 创建应用目录
WORKDIR /app

# 创建非 root 用户
RUN adduser -D -s /bin/sh appuser
USER appuser

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \\
    CMD echo "healthy"

ENTRYPOINT ["echo", "Hello from ${description}"]
EOF
            ;;
        "ubuntu")
            cat << EOF
FROM ${base_image}

LABEL maintainer="lyc <imyikong@gmail.com>"
LABEL description="${description}"

# 更新包列表并安装基础工具
RUN apt-get update && apt-get install -y \\
    ca-certificates \\
    tzdata \\
    curl \\
    && rm -rf /var/lib/apt/lists/*

# 设置时区
ENV TZ=Asia/Shanghai

# 创建应用目录
WORKDIR /app

# 创建非 root 用户
RUN useradd -m -s /bin/bash appuser
USER appuser

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \\
    CMD echo "healthy"

ENTRYPOINT ["echo", "Hello from ${description}"]
EOF
            ;;
        "node")
            cat << EOF
FROM ${base_image}

LABEL maintainer="lyc <imyikong@gmail.com>"
LABEL description="${description}"

# 设置工作目录
WORKDIR /app

# 复制 package.json 和 package-lock.json (如果存在)
COPY package*.json ./

# 安装依赖
RUN npm ci --only=production

# 复制应用代码
COPY . .

# 创建非 root 用户
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001
USER nodejs

# 暴露端口
EXPOSE 3000

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \\
    CMD curl -f http://localhost:3000/health || exit 1

CMD ["node", "index.js"]
EOF
            ;;
        "python")
            cat << EOF
FROM ${base_image}

LABEL maintainer="lyc <imyikong@gmail.com>"
LABEL description="${description}"

# 设置环境变量
ENV PYTHONUNBUFFERED=1 \\
    PYTHONDONTWRITEBYTECODE=1 \\
    PIP_NO_CACHE_DIR=1 \\
    PIP_DISABLE_PIP_VERSION_CHECK=1

# 设置工作目录
WORKDIR /app

# 安装依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制应用代码
COPY . .

# 创建非 root 用户
RUN adduser -D -s /bin/sh appuser
USER appuser

# 暴露端口
EXPOSE 8000

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \\
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

CMD ["python", "app.py"]
EOF
            ;;
        "golang")
            cat << EOF
FROM ${base_image} AS builder

LABEL maintainer="lyc <imyikong@gmail.com>"
LABEL description="${description}"

# 设置工作目录
WORKDIR /app

# 复制 go.mod 和 go.sum
COPY go.mod go.sum ./

# 下载依赖
RUN go mod download

# 复制源代码
COPY . .

# 构建应用
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# 运行时镜像
FROM alpine:latest

RUN apk --no-cache add ca-certificates
WORKDIR /root/

# 从构建镜像复制二进制文件
COPY --from=builder /app/main .

# 创建非 root 用户
RUN adduser -D -s /bin/sh appuser
USER appuser

# 暴露端口
EXPOSE 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \\
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

CMD ["./main"]
EOF
            ;;
        *)
            # 默认简单模板
            cat << EOF
FROM ${base_image}

LABEL maintainer="lyc <imyikong@gmail.com>"
LABEL description="${description}"

# 设置工作目录
WORKDIR /app

# 复制应用文件
# COPY . .

# 安装依赖或设置环境
# RUN your-setup-commands-here

# 暴露端口 (如果需要)
# EXPOSE 8080

# 健康检查 (如果需要)
# HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \\
#     CMD your-health-check-command || exit 1

# 设置入口点
ENTRYPOINT ["echo", "Hello from ${description}"]
EOF
            ;;
    esac
}

# 生成 README 文件
generate_readme() {
    local image_name="$1"
    local description="$2"
    local base_image="$3"
    
    cat << EOF
# ${image_name}

${description}

## 构建

\`\`\`bash
# 从项目根目录运行
./build-images.sh ${image_name}
\`\`\`

## 运行

\`\`\`bash
docker run --rm ${image_name}:latest
\`\`\`

## 基础信息

- **基础镜像**: ${base_image}
- **描述**: ${description}
- **维护者**: lyc <imyikong@gmail.com>

## 配置

这个镜像支持以下环境变量：

| 变量名 | 描述 | 默认值 |
|--------|------|--------|
| 变量1  | 描述1 | 默认值1 |

## 端口

| 端口 | 协议 | 描述 |
|------|------|------|
| 8080 | HTTP | 主要服务端口 |

## 卷

| 路径 | 描述 |
|------|------|
| /app/data | 数据存储目录 |

## 使用示例

\`\`\`bash
# 基本运行
docker run --rm ${image_name}:latest

# 带环境变量运行
docker run --rm -e VAR1=value1 ${image_name}:latest

# 带端口映射运行
docker run --rm -p 8080:8080 ${image_name}:latest

# 带卷挂载运行
docker run --rm -v \$(pwd)/data:/app/data ${image_name}:latest
\`\`\`
EOF
}

# 创建新镜像
create_image() {
    local image_name="$1"
    local base_image="${2:-alpine:latest}"
    local description="${3:-A Docker image for $image_name}"
    local template="${4:-alpine}"
    local dry_run="${5:-false}"
    
    local image_dir="images/$image_name"
    
    # 检查镜像目录是否已存在
    if [ -d "$image_dir" ]; then
        print_error "镜像目录 '$image_dir' 已存在"
        return 1
    fi
    
    print_info "创建新镜像: $image_name"
    print_info "基础镜像: $base_image"
    print_info "描述: $description"
    print_info "模板: $template"
    
    if [ "$dry_run" = "true" ]; then
        echo ""
        print_info "将要创建的文件结构:"
        echo "$image_dir/"
        echo "├── Dockerfile"
        echo "└── README.md"
        echo ""
        print_info "Dockerfile 内容预览:"
        echo "------------------------"
        generate_dockerfile "$base_image" "$description" "$template"
        echo "------------------------"
        return 0
    fi
    
    # 创建镜像目录
    mkdir -p "$image_dir"
    
    # 生成 Dockerfile
    generate_dockerfile "$base_image" "$description" "$template" > "$image_dir/Dockerfile"
    
    # 生成 README
    generate_readme "$image_name" "$description" "$base_image" > "$image_dir/README.md"
    
    print_success "镜像 '$image_name' 创建成功！"
    print_info "目录: $image_dir"
    print_info "你可以编辑 $image_dir/Dockerfile 来自定义镜像"
    print_info "然后运行: ./build-images.sh $image_name"
}

# 主函数
main() {
    local base_image="alpine:latest"
    local description=""
    local template="alpine"
    local dry_run=false
    local image_name=""
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -b|--base)
                base_image="$2"
                shift 2
                ;;
            -t|--template)
                template="$2"
                shift 2
                ;;
            -d|--description)
                description="$2"
                shift 2
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            -*)
                print_error "未知选项: $1"
                show_usage
                exit 1
                ;;
            *)
                if [ -z "$image_name" ]; then
                    image_name="$1"
                else
                    print_error "只能指定一个镜像名"
                    show_usage
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # 检查必需参数
    if [ -z "$image_name" ]; then
        print_error "请指定镜像名"
        show_usage
        exit 1
    fi
    
    # 验证镜像名
    if [[ ! "$image_name" =~ ^[a-z0-9][a-z0-9-]*[a-z0-9]$|^[a-z0-9]$ ]]; then
        print_error "镜像名格式不正确。只能包含小写字母、数字和连字符，且不能以连字符开头或结尾"
        exit 1
    fi
    
    # 如果没有指定描述，使用默认描述
    if [ -z "$description" ]; then
        description="A Docker image for $image_name"
    fi
    
    # 检查是否在正确的目录
    if [ ! -f "README.md" ] || [ ! -d ".github" ]; then
        print_error "请在项目根目录执行此脚本"
        exit 1
    fi
    
    # 确保 images 目录存在
    if [ ! -d "images" ]; then
        mkdir -p images
        print_info "创建了 images 目录"
    fi
    
    # 执行创建
    create_image "$image_name" "$base_image" "$description" "$template" "$dry_run"
}

# 执行主函数
main "$@"