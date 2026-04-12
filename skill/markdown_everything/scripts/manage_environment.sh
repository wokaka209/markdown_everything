#!/bin/bash
# MarkItDown Environment Manager
# 智能环境管理器 - 仅 Conda 环境检测与自动创建
# 流程: Conda检测 -> 环境检测 -> 自动创建 -> 依赖安装

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/environment.log"
ENV_NAME="markitdown"

PIP_TIMEOUT="${MARKITDOWN_PIP_TIMEOUT:-120}"
PIP_RETRIES="${MARKITDOWN_PIP_RETRIES:-3}"
PIP_MIRROR="${MARKITDOWN_PIP_MIRROR:-default}"
CUSTOM_MIRROR="${MARKITDOWN_CUSTOM_MIRROR:-}"

detect_os() {
    local os_name="Unknown"

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        os_name="Linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        os_name="macOS"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
        os_name="Windows"
    fi

    echo "$os_name"
}

SCRIPT_OS="$(detect_os)"

CONDA_PATHS=(
    "$HOME/.conda"
    "$HOME/anaconda3"
    "$HOME/miniconda3"
    "/opt/anaconda3"
    "/opt/miniconda3"
)

log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $*" | tee -a "$LOG_FILE"
}

log_success() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SUCCESS] $*" | tee -a "$LOG_FILE"
}

log_warning() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARNING] $*" | tee -a "$LOG_FILE" >&2
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $*" | tee -a "$LOG_FILE" >&2
}

test_conda_installed() {
    log_info "======================================"
    log_info "步骤 1: 检测 Conda 是否安装"
    log_info "======================================"

    if command -v conda &> /dev/null; then
        local version
        version=$(conda --version 2>&1)
        log_success "Conda 已安装: $version"
        return 0
    fi

    for conda_path in "${CONDA_PATHS[@]}"; do
        if [[ -f "$conda_path/conda" ]]; then
            export PATH="$conda_path:$PATH"
            local version
            version=$(conda --version 2>&1)
            log_success "Conda 已安装: $version (路径: $conda_path)"
            return 0
        fi
    done

    log_error "系统未安装 Conda"
    log_info "请先安装 Miniconda 或 Anaconda"
    log_info "下载链接: https://docs.conda.io/en/latest/miniconda.html"
    return 1
}

test_conda_environment_exists() {
    local env_name="$1"

    log_info "检测 Conda 环境 '$env_name'..."

    if ! test_conda_installed &>/dev/null; then
        log_error "Conda 未安装，无法检测环境"
        return 1
    fi

    if conda env list 2>/dev/null | grep -qE "(^|\s)${env_name}(\s|$)"; then
        log_success "Conda 环境 '$env_name' 已存在 ✓"
        return 0
    else
        log_info "Conda 环境 '$env_name' 不存在，将自动创建"
        return 1
    fi
}

new_conda_environment() {
    local env_name="$1"

    log_info "======================================"
    log_info "步骤 2: 自动创建 Conda 环境"
    log_info "======================================"

    if ! test_conda_installed &>/dev/null; then
        log_error "无法创建环境: Conda 未安装"
        return 1
    fi

    log_info "正在创建 Conda 环境 '$env_name' (python=3.11)..."

    if conda create -n "$env_name" python=3.11 -y 2>&1 | tee -a "$LOG_FILE"; then
        log_success "Conda 环境 '$env_name' 创建成功 ✓"
        return 0
    else
        log_error "Conda 环境创建失败"
        return 1
    fi
}

get_conda_python_path() {
    local env_name="$1"

    for conda_path in "${CONDA_PATHS[@]}"; do
        local python_path="$conda_path/envs/$env_name/bin/python"

        if [[ "$SCRIPT_OS" == "Windows" ]]; then
            python_path="$conda_path/envs/$env_name/Scripts/python.exe"
        fi

        if [[ -f "$python_path" ]]; then
            echo "$python_path"
            return 0
        fi
    done

    return 1
}

get_pip_mirror_index() {
    local mirror_type="$1"
    local custom_index="$2"

    case "$mirror_type" in
        tsinghua)
            echo "https://pypi.tuna.tsinghua.edu.cn/simple"
            ;;
        aliyun)
            echo "https://mirrors.aliyun.com/pypi/simple/"
            ;;
        douban)
            echo "https://pypi.doubanio.com/simple/"
            ;;
        custom)
            echo "$custom_index"
            ;;
        *)
            echo ""
            ;;
    esac
}

install_package() {
    local python_exe="$1"
    local package="$2"
    local mirror_type="$3"
    local custom_index="$4"

    log_info "======================================"
    log_info "步骤 3: 安装依赖包"
    log_info "======================================"
    log_info "安装 $package..."
    log_info "使用镜像: $mirror_type"

    local install_args=("-m" "pip" "install" "--no-cache-dir" "--timeout" "$PIP_TIMEOUT" "$package")

    local mirror_index
    mirror_index=$(get_pip_mirror_index "$mirror_type" "$custom_index")

    if [[ -n "$mirror_index" ]]; then
        local trusted_host
        trusted_host=$(echo "$mirror_index" | sed -E 's|https?://||' | sed -E 's|/simple.*$||')
        install_args+=("-i" "$mirror_index" "--trusted-host" "$trusted_host")
    fi

    local attempt=0
    local success=false

    while [[ $attempt -lt $PIP_RETRIES && "$success" == "false" ]]; do
        ((attempt++))

        if [[ $attempt -gt 1 ]]; then
            local wait_time=$((2 ** (attempt - 1)))
            log_warning "重试 $attempt/$PIP_RETRIES，等待 $wait_time 秒..."
            sleep "$wait_time"
        fi

        log_info "安装尝试 $attempt..."
        if "$python_exe" "${install_args[@]}" 2>&1 | tee -a "$LOG_FILE"; then
            log_success "$package 安装成功 ✓"
            success=true
        else
            log_warning "安装尝试 $attempt 失败"
        fi
    done

    if [[ "$success" == "false" ]]; then
        log_error "$package 安装失败"
        return 1
    fi

    return 0
}

setup_environment() {
    local env_name="$ENV_NAME"

    if ! test_conda_installed &>/dev/null; then
        log_error "Conda 未安装，无法继续"
        return 1
    fi

    log_info "======================================"
    log_info "环境设置开始"
    log_info "目标环境: $env_name"
    log_info "======================================"

    if test_conda_environment_exists "$env_name"; then
        log_info "使用现有 Conda 环境"
        local python_exe
        if python_exe=$(get_conda_python_path "$env_name"); then
            if install_package "$python_exe" 'markitdown[all]' "$PIP_MIRROR" "$CUSTOM_MIRROR"; then
                log_success "依赖安装完成 ✓"
                return 0
            fi
        fi
    else
        if new_conda_environment "$env_name"; then
            local python_exe
            if python_exe=$(get_conda_python_path "$env_name"); then
                if install_package "$python_exe" 'markitdown[all]' "$PIP_MIRROR" "$CUSTOM_MIRROR"; then
                    log_success "环境设置完成 ✓"
                    return 0
                fi
            fi
        fi
    fi

    return 1
}

get_environment_python() {
    if test_conda_installed &>/dev/null && test_conda_environment_exists "$ENV_NAME"; then
        local python_path
        if python_path=$(get_conda_python_path "$ENV_NAME"); then
            log_info "使用 Conda Python: $python_path"
            echo "$python_path"
            return 0
        fi
    fi

    return 1
}

run_command() {
    if [[ $# -eq 0 ]]; then
        log_error "请指定要运行的命令"
        return 1
    fi

    local python_exe
    if ! python_exe=$(get_environment_python); then
        log_error "未找到可用的 Python 环境"
        log_info "请先运行 setup 命令设置环境"
        return 1
    fi

    log_info "使用 Python: $python_exe"
    log_info "运行命令: $*"

    cd "$SCRIPT_DIR"
    if "$python_exe" "$@"; then
        return 0
    else
        log_error "命令执行失败"
        return 1
    fi
}

convert_document() {
    local input_path="$1"
    local output_dir="${2:-.}"

    if [[ -z "$input_path" ]]; then
        log_error "请提供输入文件路径"
        return 1
    fi

    if [[ ! -f "$input_path" ]]; then
        log_error "输入文件不存在: $input_path"
        return 1
    fi

    local input_base_name
    input_base_name=$(basename "$input_path" | sed 's/\.[^.]*$//')
    local output_file="$output_dir/$input_base_name.md"

    if [[ ! -d "$output_dir" ]]; then
        mkdir -p "$output_dir" 2>/dev/null || true
        log_info "创建输出目录: $output_dir"
    fi

    log_info "转换文档..."
    log_info "  输入: $(realpath "$input_path")"
    log_info "  输出: $output_file"

    local python_exe
    if ! python_exe=$(get_environment_python); then
        log_error "未找到可用的 Python 环境"
        return 1
    fi

    log_info "使用 Python: $python_exe"

    cd "$SCRIPT_DIR"
    if "$python_exe" "convert_document.py" "$input_path" -o "$output_file" 2>&1 | tee -a "$LOG_FILE"; then
        log_success "文档转换成功: $output_file"
        return 0
    else
        log_error "文档转换失败"
        return 1
    fi
}

show_help() {
    cat << EOF

================================================================================
MarkItDown 环境管理器 - Conda 环境检测与自动创建
================================================================================

平台: $SCRIPT_OS
版本: v5.0.0

用法: $0 <命令> [选项]

--------------------------------------------------------------------------------
环境检测与创建流程 (仅 Conda):
--------------------------------------------------------------------------------
  步骤 1: 检测 Conda 是否安装
  步骤 2: 检测 Conda 环境是否存在
  步骤 3: 自动创建 Conda 环境（如不存在）
  步骤 4: 安装 markitdown[all]

--------------------------------------------------------------------------------
命令:
--------------------------------------------------------------------------------
    check              检查 Conda 环境状态
    setup             自动设置 Conda 环境（推荐）
    run <命令>         运行命令
    convert           转换文档
    help              显示帮助

--------------------------------------------------------------------------------
选��:
--------------------------------------------------------------------------------
    -m, --mirror <镜像>  pip 镜像源:
                        - default:   官方 PyPI
                        - tsinghua:  清华大学镜像
                        - aliyun:    阿里云镜像（推荐）
                        - douban:    豆瓣镜像
                        - custom:    使用 CUSTOM_MIRROR 环境变量

--------------------------------------------------------------------------------
使用示例:
--------------------------------------------------------------------------------
    # 检查环境状态
    $0 check

    # 自动设置环境（自动检测并创建 Conda 环境）
    $0 setup

    # 使用阿里云镜像设置环境
    $0 setup --mirror aliyun

    # 运行脚本
    $0 run python --version

    # 转换文档
    $0 convert input.pdf -o output/

--------------------------------------------------------------------------------
环境要求:
--------------------------------------------------------------------------------
    Conda (Miniconda/Anaconda) - 必需
    网络: PyPI 或国内镜像

--------------------------------------------------------------------------------
环境信息:
--------------------------------------------------------------------------------
    Conda 环境: ~/.conda/envs/$ENV_NAME
    日志文件:  $LOG_FILE

================================================================================

EOF
}

main() {
    local command="${1:-help}"
    shift || true

    local mirror_type="$PIP_MIRROR"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -m|--mirror)
                mirror_type="$2"
                export MARKITDOWN_PIP_MIRROR="$mirror_type"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                break
                ;;
        esac
    done

    echo ""
    echo -e "\033[36mMarkItDown 环境管理器 v5.0.0\033[0m"
    echo -e "\033[36m平台: $SCRIPT_OS\033[0m"
    echo ""

    case "$command" in
        check)
            log_info "======================================"
            log_info "Conda 环境状态检测"
            log_info "======================================"

            log_info "检测 Conda 安装状态..."
            if test_conda_installed; then
                log_success "Conda 已安装 ✓"
                log_info ""
                log_info "检测 Conda 环境..."
                test_conda_environment_exists "$ENV_NAME"
            else
                log_error "Conda 未安装"
            fi

            log_info ""
            log_info "检测 Python 环境..."
            if python_exe=$(get_environment_python); then
                log_success "已设置 Python: $python_exe"
            else
                log_warning "未设置环境，请运行 setup 命令"
            fi
            ;;
        setup)
            export PIP_MIRROR="$mirror_type"
            if setup_environment; then
                log_info ""
                log_success "环境设置完成！✓"
                exit 0
            else
                log_error ""
                log_error "环境设置失败"
                exit 1
            fi
            ;;
        run)
            shift || true
            run_command "$@"
            ;;
        convert)
            local input_file=""
            local output_dir="."

            shift || true
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    -o|--output)
                        output_dir="$2"
                        shift 2
                        ;;
                    -*)
                        shift
                        ;;
                    *)
                        input_file="$1"
                        shift
                        ;;
                esac
            done

            convert_document "$input_file" "$output_dir"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "未知命令: $command"
            show_help
            exit 1
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi