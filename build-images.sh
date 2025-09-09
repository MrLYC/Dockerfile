#!/bin/bash

# Docker 镜像构建脚本
# 用于构建 images 目录下的 Docker 镜像

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
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
    echo "用法: $0 [选项] [镜像名]"
    echo "选项:"
    echo "  -h, --help      显示此帮助信息"
    echo "  -l, --list      列出所有可用的镜像"
    echo "  -a, --all       构建所有镜像"
    echo "  -t, --tag TAG   指定镜像标签 (默认: latest)"
    echo "  -p, --push      构建后推送到 Docker Hub"
    echo "  --dry-run       仅显示将要执行的命令，不实际执行"
    echo ""
    echo "示例:"
    echo "  $0 hello-world                    # 构建 hello-world 镜像"
    echo "  $0 -t v1.0.0 hello-world         # 构建 hello-world 镜像并打标签 v1.0.0"
    echo "  $0 --all                          # 构建所有镜像"
    echo "  $0 -p hello-world                 # 构建并推送 hello-world 镜像"
}

# 列出所有可用的镜像
list_images() {
    print_info "可用的镜像："
    if [ -d "images" ]; then
        for dir in images/*/; do
            if [ -d "$dir" ] && [ -f "${dir}Dockerfile" ]; then
                basename "$dir"
            fi
        done
    else
        print_warning "images 目录不存在"
    fi
}

# 构建单个镜像
build_image() {
    local image_name="$1"
    local tag="${2:-latest}"
    local push="${3:-false}"
    local dry_run="${4:-false}"
    
    local image_dir="images/$image_name"
    local dockerfile_path="$image_dir/Dockerfile"
    
    # 检查镜像目录是否存在
    if [ ! -d "$image_dir" ]; then
        print_error "镜像目录 '$image_dir' 不存在"
        return 1
    fi
    
    # 检查 Dockerfile 是否存在
    if [ ! -f "$dockerfile_path" ]; then
        print_error "Dockerfile '$dockerfile_path' 不存在"
        return 1
    fi
    
    print_info "构建镜像: $image_name:$tag"
    
    local build_cmd="docker build -t $image_name:$tag $image_dir"
    
    if [ "$dry_run" = "true" ]; then
        echo "将执行: $build_cmd"
    else
        print_info "执行: $build_cmd"
        if $build_cmd; then
            print_success "镜像 $image_name:$tag 构建成功"
            
            # 如果需要推送
            if [ "$push" = "true" ]; then
                print_info "推送镜像到 Docker Hub..."
                local push_cmd="docker push $image_name:$tag"
                if [ "$dry_run" = "true" ]; then
                    echo "将执行: $push_cmd"
                else
                    print_info "执行: $push_cmd"
                    if $push_cmd; then
                        print_success "镜像 $image_name:$tag 推送成功"
                    else
                        print_error "镜像 $image_name:$tag 推送失败"
                        return 1
                    fi
                fi
            fi
        else
            print_error "镜像 $image_name:$tag 构建失败"
            return 1
        fi
    fi
}

# 构建所有镜像
build_all_images() {
    local tag="${1:-latest}"
    local push="${2:-false}"
    local dry_run="${3:-false}"
    
    print_info "构建所有镜像..."
    
    if [ ! -d "images" ]; then
        print_error "images 目录不存在"
        return 1
    fi
    
    local success_count=0
    local total_count=0
    
    for dir in images/*/; do
        if [ -d "$dir" ] && [ -f "${dir}Dockerfile" ]; then
            local image_name=$(basename "$dir")
            total_count=$((total_count + 1))
            
            if build_image "$image_name" "$tag" "$push" "$dry_run"; then
                success_count=$((success_count + 1))
            fi
        fi
    done
    
    print_info "构建完成: $success_count/$total_count 镜像成功"
    
    if [ $success_count -eq $total_count ]; then
        print_success "所有镜像构建成功！"
        return 0
    else
        print_error "部分镜像构建失败"
        return 1
    fi
}

# 主函数
main() {
    local tag="latest"
    local push=false
    local build_all=false
    local dry_run=false
    local image_name=""
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -l|--list)
                list_images
                exit 0
                ;;
            -a|--all)
                build_all=true
                shift
                ;;
            -t|--tag)
                tag="$2"
                shift 2
                ;;
            -p|--push)
                push=true
                shift
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
    
    # 检查是否在正确的目录
    if [ ! -f "README.md" ] && [ ! -d "images" ]; then
        print_error "请在项目根目录执行此脚本"
        exit 1
    fi
    
    # 执行构建
    if [ "$build_all" = "true" ]; then
        build_all_images "$tag" "$push" "$dry_run"
    elif [ -n "$image_name" ]; then
        build_image "$image_name" "$tag" "$push" "$dry_run"
    else
        print_error "请指定要构建的镜像名或使用 --all 构建所有镜像"
        show_usage
        exit 1
    fi
}

# 执行主函数
main "$@"