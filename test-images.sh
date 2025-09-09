#!/bin/bash

# 镜像测试脚本
# 用于测试构建的镜像是否正常工作

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
    echo "用法: $0 [选项] [镜像名[:标签]]"
    echo "选项:"
    echo "  -h, --help      显示此帮助信息"
    echo "  -a, --all       测试所有本地镜像"
    echo "  -l, --list      列出本地可测试的镜像"
    echo "  --timeout SEC   设置容器运行超时时间 (默认: 30秒)"
    echo ""
    echo "示例:"
    echo "  $0 hello-world              # 测试 hello-world:latest 镜像"
    echo "  $0 hello-world:v1.0.0       # 测试指定标签的镜像"
    echo "  $0 --all                     # 测试所有本地镜像"
}

# 列出可测试的本地镜像
list_local_images() {
    print_info "本地可测试的镜像："
    
    if [ -d "images" ]; then
        for dir in images/*/; do
            if [ -d "$dir" ]; then
                local image_name=$(basename "$dir")
                local images=$(docker images --format "table {{.Repository}}:{{.Tag}}" | grep "^$image_name:" | grep -v "<none>" || true)
                if [ -n "$images" ]; then
                    echo "$images"
                fi
            fi
        done
    else
        print_warning "images 目录不存在"
    fi
}

# 测试单个镜像
test_image() {
    local image_full_name="$1"
    local timeout="${2:-30}"
    
    print_info "测试镜像: $image_full_name"
    
    # 检查镜像是否存在
    if ! docker image inspect "$image_full_name" >/dev/null 2>&1; then
        print_error "镜像 '$image_full_name' 不存在，请先构建镜像"
        return 1
    fi
    
    # 运行容器并获取输出
    print_info "运行容器 (超时: ${timeout}秒)..."
    
    local container_id
    local exit_code=0
    
    # 运行容器
    if container_id=$(docker run -d "$image_full_name"); then
        print_info "容器已启动: $container_id"
        
        # 等待容器完成或超时
        local count=0
        while [ $count -lt $timeout ]; do
            if ! docker ps -q --filter "id=$container_id" | grep -q .; then
                break
            fi
            sleep 1
            count=$((count + 1))
        done
        
        # 获取容器退出状态
        exit_code=$(docker inspect "$container_id" --format='{{.State.ExitCode}}' 2>/dev/null || echo "1")
        
        # 获取容器日志
        print_info "容器输出："
        echo "----------------------------------------"
        docker logs "$container_id" 2>&1
        echo "----------------------------------------"
        
        # 清理容器
        docker rm "$container_id" >/dev/null 2>&1 || true
        
        # 检查退出状态
        if [ "$exit_code" -eq 0 ]; then
            print_success "镜像 $image_full_name 测试通过"
            return 0
        else
            print_error "镜像 $image_full_name 测试失败 (退出码: $exit_code)"
            return 1
        fi
    else
        print_error "无法启动容器"
        return 1
    fi
}

# 测试所有本地镜像
test_all_images() {
    local timeout="${1:-30}"
    
    print_info "测试所有本地镜像..."
    
    if [ ! -d "images" ]; then
        print_error "images 目录不存在"
        return 1
    fi
    
    local success_count=0
    local total_count=0
    
    for dir in images/*/; do
        if [ -d "$dir" ]; then
            local image_name=$(basename "$dir")
            
            # 查找该镜像的最新标签
            local latest_image="${image_name}:latest"
            
            if docker image inspect "$latest_image" >/dev/null 2>&1; then
                total_count=$((total_count + 1))
                
                if test_image "$latest_image" "$timeout"; then
                    success_count=$((success_count + 1))
                fi
                
                echo ""  # 添加空行分隔
            fi
        fi
    done
    
    print_info "测试完成: $success_count/$total_count 镜像通过测试"
    
    if [ $success_count -eq $total_count ] && [ $total_count -gt 0 ]; then
        print_success "所有镜像测试通过！"
        return 0
    else
        if [ $total_count -eq 0 ]; then
            print_warning "没有找到可测试的镜像"
        else
            print_error "部分镜像测试失败"
        fi
        return 1
    fi
}

# 主函数
main() {
    local timeout=30
    local test_all=false
    local image_name=""
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -l|--list)
                list_local_images
                exit 0
                ;;
            -a|--all)
                test_all=true
                shift
                ;;
            --timeout)
                timeout="$2"
                shift 2
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
    
    # 检查 Docker 是否可用
    if ! command -v docker >/dev/null 2>&1; then
        print_error "Docker 未安装或不可用"
        exit 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker 守护进程未运行或权限不足"
        exit 1
    fi
    
    # 执行测试
    if [ "$test_all" = "true" ]; then
        test_all_images "$timeout"
    elif [ -n "$image_name" ]; then
        # 如果没有指定标签，默认使用 latest
        if [[ "$image_name" != *:* ]]; then
            image_name="${image_name}:latest"
        fi
        test_image "$image_name" "$timeout"
    else
        print_error "请指定要测试的镜像名或使用 --all 测试所有镜像"
        show_usage
        exit 1
    fi
}

# 执行主函数
main "$@"