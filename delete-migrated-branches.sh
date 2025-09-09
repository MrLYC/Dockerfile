#!/bin/bash

# 删除已迁移分支的脚本
# 这些分支的内容已经迁移到 images/ 目录结构中

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

# 已迁移到 images/ 的分支列表
MIGRATED_BRANCHES=(
    "alpine-sshd"
    "beanstalkd" 
    "centos"
    "chrome-vnc"
    "docker-utils"
    "hexo"
    "httplive"
    "ipython"
    "jupyter"
    "kcptun"
    "kcptun-client"
    "lamptun"
    "minicron"
    "minio"
    "nextcloud"
    "opengrok"
    "pyspider"
    "snmpd"
    "ssh-client"
    "sslocal"
    "tox"
    "ubuntu"
    "webcron"
    "webdav"
    "yapf"
    "zabbix"
)

# 显示使用说明
show_usage() {
    echo "用法: $0 [选项]"
    echo "选项:"
    echo "  -h, --help      显示此帮助信息"
    echo "  -l, --list      列出将要删除的分支"
    echo "  --dry-run       仅显示将要执行的命令，不实际执行"
    echo "  --local-only    仅删除本地分支，不删除远程分支"
    echo "  --remote-only   仅删除远程分支，不删除本地分支"
    echo ""
    echo "注意: 默认情况下会同时删除本地和远程分支"
    echo ""
    echo "示例:"
    echo "  $0                    # 删除所有已迁移的本地和远程分支"
    echo "  $0 --dry-run          # 预览将要执行的删除命令"
    echo "  $0 --local-only       # 仅删除本地分支"
    echo "  $0 --remote-only      # 仅删除远程分支"
}

# 列出将要删除的分支
list_branches() {
    print_info "以下分支将被删除（内容已迁移到 images/ 目录）："
    echo ""
    for branch in "${MIGRATED_BRANCHES[@]}"; do
        echo "  - $branch"
    done
    echo ""
    print_warning "这些分支的内容已经完全迁移到 images/ 目录结构中"
    print_warning "删除后无法恢复，请确保迁移完成且正确"
}

# 删除本地分支
delete_local_branches() {
    local dry_run="${1:-false}"
    
    print_info "删除本地分支..."
    
    local success_count=0
    local total_count=0
    
    for branch in "${MIGRATED_BRANCHES[@]}"; do
        total_count=$((total_count + 1))
        
        # 检查本地分支是否存在
        if git show-ref --verify --quiet refs/heads/"$branch"; then
            local delete_cmd="git branch -D $branch"
            
            if [ "$dry_run" = "true" ]; then
                echo "将执行: $delete_cmd"
                success_count=$((success_count + 1))
            else
                print_info "删除本地分支: $branch"
                if eval "$delete_cmd" 2>/dev/null; then
                    print_success "本地分支 $branch 删除成功"
                    success_count=$((success_count + 1))
                else
                    print_warning "本地分支 $branch 不存在或删除失败"
                fi
            fi
        else
            print_warning "本地分支 $branch 不存在"
        fi
    done
    
    if [ "$dry_run" = "false" ]; then
        print_info "本地分支删除完成: $success_count/$total_count"
    fi
}

# 删除远程分支
delete_remote_branches() {
    local dry_run="${1:-false}"
    
    print_info "删除远程分支..."
    
    local success_count=0
    local total_count=0
    
    for branch in "${MIGRATED_BRANCHES[@]}"; do
        total_count=$((total_count + 1))
        
        # 检查远程分支是否存在
        if git show-ref --verify --quiet refs/remotes/origin/"$branch"; then
            local delete_cmd="git push origin --delete $branch"
            
            if [ "$dry_run" = "true" ]; then
                echo "将执行: $delete_cmd"
                success_count=$((success_count + 1))
            else
                print_info "删除远程分支: origin/$branch"
                if eval "$delete_cmd" 2>/dev/null; then
                    print_success "远程分支 origin/$branch 删除成功"
                    success_count=$((success_count + 1))
                else
                    print_error "远程分支 origin/$branch 删除失败"
                fi
            fi
        else
            print_warning "远程分支 origin/$branch 不存在"
        fi
    done
    
    if [ "$dry_run" = "false" ]; then
        print_info "远程分支删除完成: $success_count/$total_count"
        
        # 清理远程跟踪分支
        print_info "清理远程跟踪分支..."
        if [ "$dry_run" = "true" ]; then
            echo "将执行: git remote prune origin"
        else
            git remote prune origin
            print_success "远程跟踪分支清理完成"
        fi
    fi
}

# 主函数
main() {
    local dry_run=false
    local local_only=false
    local remote_only=false
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -l|--list)
                list_branches
                exit 0
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            --local-only)
                local_only=true
                shift
                ;;
            --remote-only)
                remote_only=true
                shift
                ;;
            -*)
                print_error "未知选项: $1"
                show_usage
                exit 1
                ;;
            *)
                print_error "此脚本不接受位置参数"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # 检查是否在正确的目录和分支
    if [ ! -f "README.md" ] && [ ! -d "images" ]; then
        print_error "请在项目根目录执行此脚本"
        exit 1
    fi
    
    current_branch=$(git branch --show-current)
    if [ "$current_branch" != "images" ] && [ "$current_branch" != "master" ] && [ "$current_branch" != "main" ]; then
        print_warning "当前分支: $current_branch"
        print_warning "建议在 images、master 或 main 分支上执行此操作"
        read -p "是否继续？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "操作已取消"
            exit 0
        fi
    fi
    
    # 显示将要删除的分支
    echo "=========================================="
    print_info "准备删除已迁移的分支"
    list_branches
    echo "=========================================="
    
    if [ "$dry_run" = "true" ]; then
        print_info "运行模式: 预览 (--dry-run)"
    else
        print_warning "这将永久删除分支！"
        read -p "确认删除这些分支？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "操作已取消"
            exit 0
        fi
    fi
    
    # 执行删除操作
    if [ "$remote_only" = "true" ]; then
        delete_remote_branches "$dry_run"
    elif [ "$local_only" = "true" ]; then
        delete_local_branches "$dry_run"
    else
        # 默认删除本地和远程分支
        delete_local_branches "$dry_run"
        delete_remote_branches "$dry_run"
    fi
    
    echo "=========================================="
    if [ "$dry_run" = "true" ]; then
        print_info "预览完成！使用不带 --dry-run 参数执行实际删除"
    else
        print_success "分支删除操作完成！"
        print_info "所有内容已安全迁移到 images/ 目录结构"
    fi
}

# 执行主函数
main "$@"
