#!/bin/bash
# MarkItDown Environment Manager
# 跨平台Conda环境管理器 - 支持Windows (Git Bash)、Linux、macOS

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_NAME="${MARKITDOWN_ENV_NAME:-markitdown}"
PYTHON_VERSION="${MARKITDOWN_PYTHON_VER:-3.12}"
LOG_FILE="${SCRIPT_DIR}/environment.log"

PIP_TIMEOUT="${MARKITDOWN_PIP_TIMEOUT:-120}"
PIP_RETRIES="${MARKITDOWN_PIP_RETRIES:-3}"
PIP_MIRROR="${MARKITDOWN_PIP_MIRROR:-default}"
CUSTOM_MIRROR="${MARKITDOWN_CUSTOM_MIRROR:-}"

# ============================================
# 跨平台配置和检测
# ============================================

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

if [[ "$SCRIPT_OS" == "Windows" ]]; then
    PATH_SEPARATOR="\\"
    ENV_SEPARATOR=";"
    CONDA_PATHS=(
        "$USERPROFILE/.conda"
        "$USERPROFILE/Anaconda3"
        "$USERPROFILE/Miniconda3"
        "/c/.conda"
        "/c/Anaconda3"
        "/c/Miniconda3"
    )
else
    PATH_SEPARATOR="/"
    ENV_SEPARATOR=":"
    CONDA_PATHS=(
        "$HOME/.conda"
        "$HOME/anaconda3"
        "$HOME/miniconda3"
        "/opt/anaconda3"
        "/opt/miniconda3"
    )
fi

# ============================================
# 日志函数
# ============================================

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

# ============================================
# 跨平台工具函数
# ============================================

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

get_pip_install_options() {
    local mirror_type="$1"
    local custom_index="$2"
    local options=()

    options+=("--no-cache-dir" "--retries" "$PIP_RETRIES" "--timeout" "$PIP_TIMEOUT")

    local mirror_index
    mirror_index=$(get_pip_mirror_index "$mirror_type" "$custom_index")

    if [[ -n "$mirror_index" ]]; then
        options+=("-i" "$mirror_index")
        local trusted_host
        trusted_host=$(echo "$mirror_index" | sed -E 's|https?://||' | sed -E 's|/simple.*$||')
        options+=("--trusted-host" "$trusted_host")
    fi

    echo "${options[@]}"
}

install_with_retry() {
    local pip_cmd="$1"
    shift
    local install_args=("$@")

    local attempt=0
    local success=false

    while [[ $attempt -lt $PIP_RETRIES && "$success" == "false" ]]; do
        ((attempt++))

        if [[ $attempt -gt 1 ]]; then
            local wait_time=$((2 ** (attempt - 1)))
            log_warning "Retry attempt $attempt/$PIP_RETRIES, waiting $wait_time seconds..."
            sleep "$wait_time"
        else
            log_info "Attempt $attempt/$PIP_RETRIES..."
        fi

        if "$pip_cmd" install "${install_args[@]}" 2>&1 | tee -a "$LOG_FILE"; then
            success=true
        else
            log_warning "Attempt $attempt failed with exit code $?"
        fi
    done

    if [[ "$success" == "true" ]]; then
        return 0
    else
        log_error "Failed to install after $attempt attempts"
        log_info "Try using a different mirror: --mirror tsinghua|aliyun|douban"
        return 1
    fi
}

check_conda_cmd() {
    if command -v conda &> /dev/null; then
        return 0
    fi

    for conda_path in "${CONDA_PATHS[@]}"; do
        if [[ -f "$conda_path/conda.exe" ]] || [[ -f "$conda_path/conda" ]]; then
            return 0
        fi
    done

    return 1
}

get_conda_exe() {
    if command -v conda &> /dev/null; then
        command -v conda
        return 0
    fi

    for conda_path in "${CONDA_PATHS[@]}"; do
        if [[ -f "$conda_path/conda.exe" ]]; then
            echo "$conda_path/conda.exe"
            return 0
        elif [[ -f "$conda_path/conda" ]]; then
            echo "$conda_path/conda"
            return 0
        fi
    done

    return 1
}

get_python_exe() {
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

# ============================================
# Conda管理函数
# ============================================

check_conda() {
    if check_conda_cmd; then
        local conda_version
        conda_version=$(conda --version 2>&1)
        log_success "Found conda ($SCRIPT_OS): $conda_version"

        local conda_exe
        if conda_exe=$(get_conda_exe); then
            log_info "Conda path: $conda_exe"
        fi

        return 0
    else
        log_error "Conda not found in PATH."
        log_info "Please install Miniconda or Anaconda first."
        log_info "Download: https://docs.conda.io/en/latest/miniconda.html"
        return 1
    fi
}

list_environments() {
    log_info "Listing all conda environments..."
    log_info "Operating System: $SCRIPT_OS"

    if ! check_conda_cmd; then
        log_error "Conda not available"
        return 1
    fi

    conda env list
    return 0
}

environment_exists() {
    local env_name="$1"
    log_info "Checking if environment '$env_name' exists..."

    if conda env list 2>/dev/null | grep -qE "(^|\s)${env_name}(\s|$)"; then
        log_info "Environment '$env_name' found"
        return 0
    else
        log_info "Environment '$env_name' not found"
        return 1
    fi
}

create_environment() {
    local env_name="$1"
    local python_ver="$2"
    local force="${3:-false}"

    if environment_exists "$env_name"; then
        if [[ "$force" == "true" ]]; then
            log_warning "Environment '$env_name' exists. Recreating with --force flag..."
            remove_environment "$env_name"
        else
            log_warning "Environment '$env_name' already exists. Use --force to recreate."
            return 0
        fi
    fi

    log_info "Creating new conda environment '$env_name' with Python $python_ver..."
    log_info "Platform: $SCRIPT_OS"

    if conda create -n "$env_name" "python=$python_ver" -y 2>&1 | tee -a "$LOG_FILE"; then
        log_success "Environment '$env_name' created successfully"
        return 0
    else
        log_error "Failed to create environment '$env_name'"
        return 1
    fi
}

remove_environment() {
    local env_name="$1"

    log_warning "Removing environment '$env_name'..."

    if conda env remove -n "$env_name" -y 2>&1 | tee -a "$LOG_FILE"; then
        log_success "Environment '$env_name' removed successfully"
        return 0
    else
        log_error "Failed to remove environment '$env_name'"
        return 1
    fi
}

install_markitdown() {
    local env_name="$1"

    if ! environment_exists "$env_name"; then
        log_error "Environment '$env_name' does not exist. Cannot install markitdown."
        return 1
    fi

    log_info "Installing markitdown with all optional dependencies in '$env_name'..."
    log_info "Mirror: $PIP_MIRROR"

    local pip_options
    pip_options=$(get_pip_install_options "$PIP_MIRROR" "$CUSTOM_MIRROR")
    read -ra pip_options_array <<< "$pip_options"

    local python_exe
    if python_exe=$(get_python_exe "$env_name"); then
        log_info "Using Python: $python_exe"
        if install_with_retry "$python_exe -m pip" install 'markitdown[all]' "${pip_options_array[@]}"; then
            log_success "Markitdown installed successfully in '$env_name'"
            return 0
        else
            log_error "Failed to install markitdown using direct pip"
            return 1
        fi
    else
        log_info "Python not found in expected path, using conda run"
        if install_with_retry conda run -n "$env_name" pip install 'markitdown[all]' "${pip_options_array[@]}"; then
            log_success "Markitdown installed successfully in '$env_name'"
            return 0
        else
            log_error "Failed to install markitdown"
            return 1
        fi
    fi
}

activate_and_run() {
    local env_name="$1"
    shift
    local cmd="$@"

    if ! environment_exists "$env_name"; then
        log_error "Environment '$env_name' does not exist"
        return 1
    fi

    log_info "Activating environment '$env_name' and running: $cmd"
    log_info "Platform: $SCRIPT_OS"

    conda run -n "$env_name" $cmd
}

setup_environment() {
    local force="${1:-false}"

    if ! check_conda; then
        return 1
    fi

    if environment_exists "$ENV_NAME"; then
        if [[ "$force" == "true" ]]; then
            log_warning "Environment exists. Recreating with --force flag..."
            remove_environment "$ENV_NAME"
        else
            log_info "Environment '$ENV_NAME' already exists"
            log_success "Setup completed successfully!"
            return 0
        fi
    fi

    if ! create_environment "$ENV_NAME" "$PYTHON_VERSION" "false"; then
        return 1
    fi

    if ! install_markitdown "$ENV_NAME"; then
        return 1
    fi

    log_success "Setup completed successfully!"
    return 0
}

get_activation_command() {
    echo ""
    echo "=== Environment Setup Complete ==="
    echo ""
    echo "Platform: $SCRIPT_OS"
    echo ""
    echo "To activate the $ENV_NAME environment, run:"
    echo ""
    echo -e "\033[33m    conda activate $ENV_NAME\033[0m"
    echo ""
    echo "Or use the following command to run markitdown:"
    echo ""
    echo -e "\033[33m    conda run -n $ENV_NAME python convert_document.py <file_path>\033[0m"
    echo ""
}

show_help() {
    cat << EOF

================================================================================
MarkItDown Environment Manager - 跨平台Conda环境管理器
================================================================================

当前平台: $SCRIPT_OS

用法: $0 <命令> [选项]

--------------------------------------------------------------------------------
命令:
--------------------------------------------------------------------------------
    check               检查conda是否可用
    list                列出所有conda环境
    exists [名称]       检查指定环境是否存在（默认: $ENV_NAME）
    create [名称]       创建新环境（默认: $ENV_NAME）
    remove [名称]       移除指定环境（默认: $ENV_NAME）
    install [名称]      安装markitdown到指定环境（默认: $ENV_NAME）
    setup               完整设置环境（创建+安装）
    run [命令]          在指定环境中运行命令（默认: $ENV_NAME）
    help                显示此帮助信息

--------------------------------------------------------------------------------
选项:
--------------------------------------------------------------------------------
    -f, --force              强制重新创建环境
    -p, --python 版本        指定Python版本（默认: $PYTHON_VERSION）
    -m, --mirror <镜像源>    指定pip镜像源
                             可选值: default, tsinghua, aliyun, douban, custom
                             - default:   使用官方 PyPI (默认)
                             - tsinghua:  清华大学镜像
                             - aliyun:    阿里云镜像
                             - douban:    豆瓣镜像
                             - custom:    使用CUSTOM_MIRROR环境变量指定的镜像
    -h, --help               显示帮助信息

--------------------------------------------------------------------------------
使用示例:
--------------------------------------------------------------------------------
    # 检查环境
    $0 check

    # 列出所有环境
    $0 list

    # 完整设置环境（使用官方源）
    $0 setup

    # 使用清华镜像设置（解决网络超时）
    $0 setup --mirror tsinghua

    # 使用阿里云镜像设置
    $0 setup --mirror aliyun

    # 强制重新设置
    $0 setup --force

    # 创建自定义环境
    $0 setup --force -p 3.11

    # 在环境中运行命令
    $0 run python --version

    # 转换文档
    $0 run python convert_document.py document.pdf

--------------------------------------------------------------------------------
网络超时解决方案:
--------------------------------------------------------------------------------
    如果遇到 pip install 超时问题，尝试以下方法：

    1. 使用国内镜像源（命令行）:
       $0 setup --mirror tsinghua
       $0 setup --mirror aliyun
       $0 setup --mirror douban

    2. 使用国内镜像源（环境变量）:
       export MARKITDOWN_PIP_MIRROR=tsinghua
       $0 setup

    3. 使用自定义镜像:
       export MARKITDOWN_PIP_MIRROR=custom
       export MARKITDOWN_CUSTOM_MIRROR="https://your-mirror.com/simple"
       $0 setup

    4. 调整超时和重试次数:
       export MARKITDOWN_PIP_TIMEOUT=180
       export MARKITDOWN_PIP_RETRIES=5
       $0 setup

--------------------------------------------------------------------------------
环境变量:
--------------------------------------------------------------------------------
    MARKITDOWN_ENV_NAME        覆盖默认环境名称（默认: $ENV_NAME）
    MARKITDOWN_PYTHON_VER      覆盖默认Python版本（默认: $PYTHON_VERSION）
    MARKITDOWN_PIP_MIRROR      指定pip镜像源（default/tsinghua/aliyun/douban/custom）
    MARKITDOWN_CUSTOM_MIRROR   自定义镜像URL（当PIP_MIRROR=custom时）
    MARKITDOWN_PIP_TIMEOUT     pip安装超时时间（默认: 120秒）
    MARKITDOWN_PIP_RETRIES     pip重试次数（默认: 3次）

--------------------------------------------------------------------------------
跨平台支持:
--------------------------------------------------------------------------------
    Windows (Git Bash): 使用本脚本
    Linux/macOS Bash:  使用本脚本

--------------------------------------------------------------------------------
日志:
--------------------------------------------------------------------------------
    日志文件: $LOG_FILE

================================================================================

EOF
}

# ============================================
# 主函数
# ============================================

main() {
    local command="${1:-help}"
    shift || true

    local force_flag="false"
    local python_ver="$PYTHON_VERSION"
    local target_env="${MARKITDOWN_ENV_NAME:-$ENV_NAME}"
    local mirror_type="$PIP_MIRROR"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f|--force)
                force_flag="true"
                shift
                ;;
            -p|--python)
                python_ver="$2"
                shift 2
                ;;
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
    echo -e "\033[36mMarkItDown Environment Manager\033[0m"
    echo -e "\033[36mPlatform: $SCRIPT_OS\033[0m"
    echo ""

    case "$command" in
        check)
            check_conda
            ;;
        list)
            list_environments
            ;;
        exists)
            local check_env="${1:-$target_env}"
            if environment_exists "$check_env"; then
                log_success "Environment '$check_env' exists"
                exit 0
            else
                log_warning "Environment '$check_env' not found"
                exit 1
            fi
            ;;
        create)
            local create_env="${1:-$target_env}"
            create_environment "$create_env" "$python_ver" "$force_flag"
            ;;
        remove)
            local remove_env="${1:-$target_env}"
            remove_environment "$remove_env"
            ;;
        install)
            local install_env="${1:-$target_env}"
            install_markitdown "$install_env"
            ;;
        setup)
            setup_environment "$force_flag"
            local status=$?
            if [ $status -eq 0 ]; then
                get_activation_command
            fi
            exit $status
            ;;
        run)
            if [ -z "${1:-}" ]; then
                log_error "Please specify command to run"
                show_help
                exit 1
            fi
            activate_and_run "$target_env" "$@"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
