---
name: markdown_everything
description: |
  智能文档转换技能 - 将各类文档格式转换为 Markdown

  ## 核心能力
- 跨平台支持：Windows PowerShell / Linux Bash / macOS Bash
- **仅 Conda 环境**：仅支持 Conda 环境检测与自动创建
- **自动创建 Conda 环境**：Conda 环境不存在时自动创建
- **PDF中文编码自动修复**：智能检测并修复中文PDF乱码问题
- 多格式支持：PDF、Word、Excel、PPT、图片、音频等 20+ 种格式
- 零配置使用：首次自动初始化，后续即开即用
- **详细日志**：完整的环境检测和问题排查日志

  ## 技术特性
  - 统一的命令行接口（CLI）
  - 完善的错误处理和日志记录
  - 环境变量灵活配置
  - 跨平台路径自动适配
  - 自动环境创建流程
  - 仅 Conda，无 venv 回退

---

## 快速开始

### 一键初始化

```powershell
# PowerShell (Windows) - 使用默认源
.\manage_environment.ps1 -Command setup

# PowerShell - 使用国内镜像
.\manage_environment.ps1 -Command setup -Mirror aliyun

# Bash (Linux/macOS) - 使用默认源
./manage_environment.sh setup

# Bash - 使用国内镜像
./manage_environment.sh setup --mirror aliyun
```

### 文档转换（推荐使用 convert 命令）⭐

```powershell
# PowerShell - 转换文档到当前目录
.\manage_environment.ps1 -Command convert -InputFile "document.pdf"

# PowerShell - 转换文档到指定目录
.\manage_environment.ps1 -Command convert -InputFile "document.pdf" -OutputDir "C:\output"

# Bash - 转换文档
./manage_environment.sh convert document.pdf
./manage_environment.sh convert document.pdf -o /path/to/output
```

---

## 支持的文档格式

| 类别 | 格式 | 说明 |
|------|------|------|
| 文档 | `.pdf` `.docx` `.doc` | PDF、Word 文档 |
| 表格 | `.xlsx` `.xls` `.csv` | Excel、CSV 表格 |
| 演示 | `.pptx` `.ppt` | PowerPoint 幻灯片 |
| 图片 | `.jpg` `.png` `.gif` `.bmp` | 支持 OCR 文字识别 |
| 音频 | `.mp3` `.wav` `.ogg` `.m4a` | 语音转文字 |
| 网页 | `.html` `.htm` | HTML 源码提取 |
| 数据 | `.json` `.xml` | 结构化数据转换 |
| 电子书 | `.epub` `.azw3` | 电子书格式 |
| 压缩 | `.zip` | 批量文档处理 |
| 视频 | YouTube URL | 字幕提取 |

---

## 命令参考

### 环境管理命令

#### check - 检查环境
检查 conda 和 pip 环境状态。

```powershell
# PowerShell
.\manage_environment.ps1 -Command check
```

```bash
# Bash
./manage_environment.sh check
```

**输出示例：**
```
Found conda (Windows): conda 23.3.1
Found Python: Python 3.12.0
```

#### list - 列出环境
显示所有 Conda 环境。

```powershell
.\manage_environment.ps1 -Command list
```

```bash
./manage_environment.sh list
```

#### exists - 检查环境
验证指定环境是否存在。

```powershell
# 默认检查 markitdown 环境
.\manage_environment.ps1 -Command exists

# 检查自定义环境
.\manage_environment.ps1 -Command exists -EnvironmentName "myenv"
```

#### setup - 一键安装 ⭐
安装 markitdown（自动选择最佳方式）。

```powershell
# PowerShell - 使用默认源
.\manage_environment.ps1 -Command setup

# PowerShell - 使用清华镜像
.\manage_environment.ps1 -Command setup -Mirror tsinghua

# PowerShell - 使用阿里云镜像
.\manage_environment.ps1 -Command setup -Mirror aliyun
```

```bash
# Bash - 使用默认源
./manage_environment.sh setup

# Bash - 使用清华镜像
./manage_environment.sh setup --mirror tsinghua

# Bash - 使用阿里云镜像
./manage_environment.sh setup --mirror aliyun
```

#### run - 执行命令
在指定环境中运行命令（conda 优先，pip 作为 fallback）。

```powershell
# PowerShell - 检查 Python 版本
.\manage_environment.ps1 -Command run -RunCommand @("python", "--version")

# PowerShell - 转换文档
.\manage_environment.ps1 -Command run -RunCommand @("python", "convert_document.py", "input.pdf", "-o", "output.md")
```

```bash
# Bash - 检查 Python 版本
./manage_environment.sh run python --version

# Bash - 转换文档
./manage_environment.sh run python convert_document.py input.pdf -o output.md
```

#### convert - 转换文档 ⭐⭐⭐（推荐）
一键转换文档，自动处理输入输出路径。

```powershell
# PowerShell - 转换文档到当前目录
.\manage_environment.ps1 -Command convert -InputFile "document.pdf"

# PowerShell - 转换文档到指定目录
.\manage_environment.ps1 -Command convert -InputFile "document.pdf" -OutputDir "C:\output"
```

```bash
# Bash - 转换文档到当前目录
./manage_environment.sh convert document.pdf

# Bash - 转换文档到指定目录
./manage_environment.sh convert document.pdf -o /path/to/output
```

---

## 使用示例

### 场景 1：首次使用

```powershell
# 1. 检查环境（自动检测conda和pip）
.\manage_environment.ps1 -Command check

# 2. 一键安装（推荐使用国内镜像）
.\manage_environment.ps1 -Command setup -Mirror aliyun

# 3. 转换文档
.\manage_environment.ps1 -Command convert -InputFile "report.pdf" -OutputDir "C:\markdown"
```

### 场景 2：批量转换

```powershell
# 转换多个文件到指定目录
$files = @("doc1.pdf", "doc2.docx", "doc3.xlsx")
$outputDir = "C:\markdown_docs"
foreach ($file in $files) {
    .\manage_environment.ps1 -Command convert -InputFile $file -OutputDir $outputDir
}
```

### 场景 3：网络超时解决

```powershell
# 使用清华镜像
.\manage_environment.ps1 -Command setup -Mirror tsinghua

# 使用阿里云镜像
.\manage_environment.ps1 -Command setup -Mirror aliyun

# 使用豆瓣镜像
.\manage_environment.ps1 -Command setup -Mirror douban
```

---

## 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `MARKITDOWN_ENV_NAME` | `markitdown` | Conda 环境名称 |
| `MARKITDOWN_PYTHON_VER` | `3.12` | Python 版本 |
| `MARKITDOWN_USE_PIP` | `false` | 强制使用 pip（设为 `true`）|

**示例：**

```powershell
# PowerShell
$env:MARKITDOWN_ENV_NAME = "myenv"
$env:MARKITDOWN_PYTHON_VER = "3.11"
.\manage_environment.ps1 -Command setup
```

```bash
# Bash
export MARKITDOWN_ENV_NAME="myenv"
export MARKITDOWN_PYTHON_VER="3.11"
export MARKITDOWN_USE_PIP="true"
./manage_environment.sh setup
```

---

## PDF中文编码自动修复

### 问题背景

处理中文PDF时，经常遇到文本提取后出现乱码、问号或方框字符。这通常是由于：

- PDF使用了非标准中文字体
- 仅嵌入了字体子集
- 编码映射不正确或缺失
- 使用了自定义CID字体

### 解决方案：Unicode级提取

本技能使用**pdfplumber**的字符级提取功能，直接从PDF的字符对象获取Unicode码点，绕过字节级编码问题：

```python
# 传统方法（可能乱码）
text = page.extract_text()

# Unicode级提取（推荐）
chars = page.chars  # 获取字符对象列表
for char in chars:
    char_unicode = char.get('unicode', '')  # 直接获取Unicode字符
```

### 工作流程

```
PDF文件输入
    ↓
检测是否为PDF格式
    ↓
使用pdfplumber的chars对象提取文本
    ↓
获取每个字符的unicode字段
    ↓
绕过PDF底层编码映射问题
    ↓
清理和标准化文本
    ↓
输出UTF-8编码的Markdown
```

### 技术优势

| 特性 | 说明 |
|------|------|
| **无需额外依赖** | 使用pdfplumber内置功能（markitdown已有） |
| **直接获取Unicode** | 从字符对象获取，不依赖编码映射 |
| **智能检测** | 自动检测文本质量和乱码率 |
| **自动回退** | 如果失败，自动回退到markitdown标准转换 |

### 使用方法

转换PDF时自动应用，无需额外参数：

```powershell
# 自动使用编码修复模式
.\manage_environment.ps1 -Command convert -InputFile "中文文档.pdf" -OutputDir "C:\output"
```

### 输出示例

```
[使用 pdfplumber_unicode 转换]
[中文比例: 85.32%]
[文件已保存到: C:\output\中文文档.md]
```

### 质量检测

转换后会自动检测文本质量：

- **中文比例**：中文字符占总字符的比例
- **乱码检测**：检测替换字符（\ufffd）和异常问号
- **替换比率**：替换字符占总字符的比例

## pip Fallback 机制

### 工作原理

脚本采用智能 fallback 机制，确保在各种环境下都能正常工作：

1. **Python 版本检测**：首先检查 Python >= 3.11
2. **Conda 检测**：检查是否安装了 Conda
3. **自动选择**：优先使用 Conda 环境，自动降级到 venv
4. **临时镜像**：使用命令行参数指定镜像，不修改系统配置
5. **网络优化**：自动重试机制和多镜像支持，解决网络超时问题

### 优先级流程

```
步骤 1: 检测 Python >= 3.11
    ↓
Python 可用? ──否──→ 提示安装 Python
    ↓是
步骤 2: 检测 Conda 环境
    ↓
Conda 可用? ───是──→ 使用 Conda 环境
    ↓否
步骤 3: 创建 venv 虚拟环境
    ↓
安装 markitdown[all]
```

### 使用场景

| 场景 | 推荐方式 |
|------|---------|
| 已安装 Conda | 使用 Conda 环境（推荐）|
| 未安装 Conda | 自动创建 venv 虚拟环境 |
| 网络超时问题 | 使用国内镜像源 |
| Python 版本过低 | 提示升级 Python |

---

## 智能环境检测与设置

### 环境检测流程

脚本会自动完成以下检测和设置：

#### 步骤 1: Python 环境检测

检查用户系统是否安装了 Python，并且版本 >= 3.11。

```powershell
# PowerShell - 检查环境
.\manage_environment.ps1 -Command check
```

**输出示例：**
```
[2024-XX-XX XX:XX:XX] [INFO] 步骤 1: 检测 Python 环境
[2024-XX-XX XX:XX:XX] [SUCCESS] Python 版本: 3.12.0 (>= 3.11 ✓)
```

**如果 Python 版本过低：**
```
[2024-XX-XX XX:XX:XX] [ERROR] Python 版本过低: 3.9.0 (需要 >= 3.11)
下载地址: https://www.python.org/downloads/
```

**如果未安装 Python：**
```
[2024-XX-XX XX:XX:XX] [ERROR] 未找到 Python，请先安装 Python 3.11+
下载地址: https://www.python.org/downloads/
```

#### 步骤 2: Conda 安装检测

检查是否安装了 Conda (Miniconda 或 Anaconda)。

```powershell
# PowerShell
.\manage_environment.ps1 -Command check
```

**输出示例：**
```
[2024-XX-XX XX:XX:XX] [INFO] ======================================
[2024-XX-XX XX:XX:XX] [INFO] 步骤 1: 检测 Conda 是否安装
[2024-XX-XX XX:XX:XX] [INFO] ======================================
[2024-XX-XX XX:XX:XX] [SUCCESS] Conda 已安装: conda 23.3.1
```

**如果 Conda 不可用：**
```
[2024-XX-XX XX:XX:XX] [WARNING] 系统未安装 Conda
[2024-XX-XX XX:XX:XX] [WARNING] Conda 不可用，将使用 venv 虚拟环境
```

#### 步骤 3: Conda 环境检测

检查 markitdown 环境是否存在。

**[2024-XX-XX XX:XX:XX] [INFO] 检测 Conda 环境 'markitdown'...
[2024-XX-XX XX:XX:XX] [SUCCESS] Conda 环境 'markitdown' 已存在 ✓

如果不存在：
```
[2024-XX-XX XX:XX:XX] [INFO] 检测 Conda 环境 'markitdown'...
[2024-XX-XX XX:XX:XX] [INFO] Conda 环境 'markitdown' 不存在
```

#### 步骤 4: 自动创建 Conda 环境

如果 Conda 环境不存在，脚本会自动创建：

```
[2024-XX-XX XX:XX:XX] [INFO] ======================================
[2024-XX-XX XX:XX:XX] [INFO] 自动创建 Conda 环境: markitdown
[2024-XX-XX XX:XX:XX] [INFO] ======================================
[2024-XX-XX XX:XX:XX] [INFO] 正在创建环境 (python=3.11)...
[2024-XX-XX XX:XX:XX] [SUCCESS] Conda 环境 'markitdown' 创建成功 ✓
```

#### 步骤 5: 安装依赖

在创建的环境中安装 markitdown[all]：

```
[2024-XX-XX XX:XX:XX] [INFO] 安装 markitdown[all]...
[2024-XX-XX XX:XX:XX] [INFO] 使用镜像: aliyun
[2024-XX-XX XX:XX:XX] [SUCCESS] markitdown[all] 安装成功 ✓
[2024-XX-XX XX:XX:XX] [SUCCESS] Conda 环境设置完成 ✓
```

### 环境类型选择

可以通过 `-EnvironmentType` 参数指定环境类型：

```powershell
# 自动选择（默认，优先 Conda）
.\manage_environment.ps1 -Command setup

# 强制使用 Conda
.\manage_environment.ps1 -Command setup -EnvironmentType conda

# 强制使用 venv
.\manage_environment.ps1 -Command setup -EnvironmentType venv
```

### 环境信息

| 项目 | 路径 |
|------|------|
| Conda 环境 | `~/.conda/envs/markitdown` 或 `~/anaconda3/envs/markitdown` |
| Venv 目录 | `scripts/.venv` |
| 日志文件 | `scripts/environment.log` |

### 日志文件分析

日志文件 (`environment.log`) 记录了所有的检测和创建过程，可以用于问题排查。

**日志级别说明：**

| 级别 | 说明 | 颜色 |
|------|------|------|
| `[INFO]` | 一般信息 | 青色 |
| `[SUCCESS]` | 成功信息 | 绿色 |
| `[WARNING]` | 警告信息 | 黄色 |
| `[ERROR]` | 错误信息 | 红色 |

**查看日志：**

```powershell
# PowerShell - 查看最近 20 行日志
Get-Content environment.log -Tail 20

# Bash - 查看最近 20 行日志
tail -20 environment.log

# 实时查看日志
Get-Content environment.log -Wait
```

**常见日志模式分析：**

| 日志模式 | 含义 | 解决方案 |
|----------|------|----------|
| `Python 版本: 3.12.0 (>= 3.11 ✓)` | Python 正常 | 无需操作 |
| `Conda 已安装: conda 23.3.1` | Conda 正常 | 无需操作 |
| `系统未安装 Conda` | 未安装 Conda | 脚本会自动使用 venv |
| `Conda 环境 'markitdown' 已存在 ✓` | 环境已存在 | 无需操作 |
| `Conda 环境 'markitdown' 不存在` | 环境不存在 | 脚本会自动创建 |
| `Conda 环境创建成功 ✓` | 创建成功 | 无需操作 |

### 一键设置

最简单的方式是一键设置：

```powershell
# PowerShell - 使用默认源
.\manage_environment.ps1 -Command setup

# PowerShell - 使用阿里云镜像（推荐国内用户）
.\manage_environment.ps1 -Command setup -Mirror aliyun

# PowerShell - 使用清华镜像
.\manage_environment.ps1 -Command setup -Mirror tsinghua
```

```bash
# Bash - 使用默认源
./manage_environment.sh setup

# Bash - 使用阿里云镜像
./manage_environment.sh setup --mirror aliyun
```

### 环境要求

- **Conda**: Miniconda 或 Anaconda (必需)
- **网络**: PyPI 或国内镜像

---

## 环境检测与设置

## 网络超时解决方案

### 问题描述

在使用 `pip install` 时，有时会遇到网络超时、连接失败等问题，特别是在网络环境较差或访问国外资源时。

### 解决方案

脚本提供了多种网络优化功能来解决这个问题，采用**临时镜像配置**，不修改系统设置。

#### 1. 自动重试机制

默认配置下，pip 安装会**自动重试 3 次**，每次重试间隔递增（1秒、2秒、4秒）：

```powershell
# PowerShell - 默认自动重试
.\manage_environment.ps1 -Command setup
```

```bash
# Bash - 默认自动重试
./manage_environment.sh setup
```

#### 2. 使用国内镜像源（推荐）

脚本内置了多个国内镜像源，可以显著提升安装速度，采用**临时参数**方式，不持久化。

| 镜像源 | 命令行参数 | 说明 |
|--------|-----------|------|
| 清华大学 | `-Mirror tsinghua` | 速度快，稳定 |
| 阿里云 | `-Mirror aliyun` | 速度快，推荐 |
| 豆瓣 | `-Mirror douban` | 速度一般，备用 |

**PowerShell 使用示例：**

```powershell
# 使用清华镜像（临时配置，不修改系统）
.\manage_environment.ps1 -Command setup -Mirror tsinghua

# 使用阿里云镜像
.\manage_environment.ps1 -Command setup -Mirror aliyun

# 使用豆瓣镜像
.\manage_environment.ps1 -Command setup -Mirror douban
```

**Bash 使用示例：**

```bash
# 使用清华镜像（临时配置）
./manage_environment.sh setup --mirror tsinghua

# 使用阿里云镜像
./manage_environment.sh setup --mirror aliyun

# 使用豆瓣镜像
./manage_environment.sh setup --mirror douban
```

#### 3. 自定义镜像

如果需要使用其他镜像源，可以指定自定义镜像：

```powershell
# PowerShell - 自定义镜像
.\manage_environment.ps1 -Command setup -Mirror custom -CustomMirror "https://your-mirror.com/simple"
```

```bash
# Bash - 自定义镜像
export MARKITDOWN_PIP_MIRROR=custom
export MARKITDOWN_CUSTOM_MIRROR="https://your-mirror.com/simple"
./manage_environment.sh setup
```

### 工作流程

```
检测镜像配置
    ↓
使用临时 pip 参数（不修改系统配置）
    ↓
开始安装（首次尝试）
    ↓
成功? ──是──→ 完成
    ↓否
等待递增时间间隔
    ↓
重试安装（最多3次）
    ↓
所有尝试失败? ──是──→ 提示使用其他镜像
    ↓否
返回成功
```

### pip 安装参数说明

脚本自动添加以下 pip 参数来优化安装：

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `--timeout` | 120 | 超时时间（秒） |
| `--retries` | 3 | 重试次数 |
| `--no-cache-dir` | 启用 | 禁用缓存，加快下载速度 |
| `-i` | 镜像地址 | 指定镜像源（仅本次使用） |
| `--trusted-host` | 自动 | 信任镜像主机（仅本次使用） |

### 镜像源状态检查

如果某个镜像源不可用，可以尝试其他镜像源。推荐测试顺序：

1. **阿里云镜像**（`aliyun`）- 通常最快，推荐
2. **清华大学镜像**（`tsinghua`）- 稳定性好
3. **豆瓣镜像**（`douban`）- 备选方案
4. **自定义镜像** - 根据实际网络情况选择

### 安全说明

- ✅ 不修改系统 pip 配置
- ✅ 不修改 pip.conf 文件
- ✅ 仅使用临时命令行参数
- ✅ 不删除任何环境
- ✅ 不强制覆盖现有环境
- ✅ 安装失败不影响系统

---

## 跨平台支持

### 平台对应表

| 操作系统 | Shell 环境 | 推荐脚本 |
|----------|------------|----------|
| Windows 10/11 | PowerShell | `manage_environment.ps1` |
| Windows 10/11 | Git Bash / WSL | `manage_environment.sh` |
| Linux (Ubuntu/CentOS) | Bash | `manage_environment.sh` |
| macOS | Terminal / Zsh | `manage_environment.sh` |

### 路径自动适配

脚本自动处理不同操作系统的路径差异：

- **Windows**: `C:\Users\...\Anaconda3\envs\markitdown\Scripts\python.exe`
- **Linux/macOS**: `/home/.../anaconda3/envs/markitdown/bin/python`

### Conda 安装位置检测

脚本自动搜索常见 Conda 安装路径：

**Windows:**
- `%USERPROFILE%\.conda`
- `%USERPROFILE%\Anaconda3`
- `%USERPROFILE%\Miniconda3`

**Linux/macOS:**
- `~/.conda`
- `~/anaconda3`
- `~/miniconda3`
- `/opt/anaconda3`
- `/opt/miniconda3`

---

## 文件结构

```
markdown_everything/
├── skill.md                      # 技能定义文档 ⭐
└── scripts/
    ├── manage_environment.ps1    # 环境管理器 (PowerShell) ⭐
    ├── manage_environment.sh     # 环境管理器 (Bash) ⭐
    ├── convert_document.py       # 核心转换引擎
    └── environment.log           # 操作日志
```

---

## 技术架构

### 模块说明

#### 1. manage_environment.ps1 / manage_environment.sh
跨平台环境管理器，提供统一的 CLI 接口：

- **环境检测**: 自动识别操作系统和 Conda 安装
- **环境创建**: 支持自定义名称和 Python 版本
- **环境激活**: 智能路径解析和命令适配
- **日志记录**: 完整操作历史记录

#### 2. convert_document.py
核心文档转换引擎：

- **格式识别**: 自动检测输入文件类型
- **内容提取**: 调用 MarkItDown 库进行转换
- **输出控制**: 支持文件输出和标准输出

### 工作流程

```
用户请求
    ↓
环境检查 → 存在? ──是──→ 执行命令
    ↓否
环境创建 → 包安装
    ↓
执行命令
    ↓
返回结果
```

---

## 故障排除

### 问题 1：conda not found

**原因**: Conda 未安装或未添加到 PATH。

**解决**:
```powershell
# 检查 Python 是否可用
.\manage_environment.ps1 -Command check

# 脚本会自动使用系统 pip 安装
.\manage_environment.ps1 -Command setup
```

### 问题 2：Python not found

**原因**: Python 未安装。

**解决**:
```powershell
# 安装 Python
# Windows: https://www.python.org/downloads/
# 或使用包管理器
```

### 问题 3：pip 安装失败/网络超时

**原因**: 网络问题或超时。

**解决**:
```powershell
# 使用国内镜像（推荐）
.\manage_environment.ps1 -Command setup -Mirror aliyun

# 或使用清华镜像
.\manage_environment.ps1 -Command setup -Mirror tsinghua

# 或使用豆瓣镜像
.\manage_environment.ps1 -Command setup -Mirror douban
```

**详细说明**：
- 默认超时时间：120秒
- 默认重试次数：3次
- 自动递增重试间隔（1秒、2秒、4秒）
- 推荐使用阿里云或清华镜像源

### 问题 4：转换文档失败

**原因**: 输入文件不存在或格式不支持。

**解决**:
```powershell
# 检查文件是否存在
Test-Path "C:\input\document.pdf"

# 使用正确的路径
.\manage_environment.ps1 -Command convert -InputFile "C:\input\document.pdf" -OutputDir "C:\output"
```

---

## AI Agent 集成指南

### 快速使用流程

AI Agent 使用本技能的标准流程：

```
1. 向用户获取输入文件路径
2. 向用户获取输出目录路径（可选，有默认值）
3. 执行 convert 命令
4. 读取生成的 markdown 文件内容
5. 向用户展示转换结果
```

### 向用户获取信息

AI Agent 应向用户询问以下信息：

1. **必需**：待转换的文档路径
2. **可选**：Markdown 输出目录（默认为当前目录或用户指定）

### 自动化调用示例

#### PowerShell 调用（推荐）

```powershell
# 基本转换
.\manage_environment.ps1 -Command convert -InputFile "C:\input\document.pdf" -OutputDir "C:\markdown"

# 批量转换
$files = @("doc1.pdf", "doc2.docx", "doc3.xlsx")
foreach ($file in $files) {
    .\manage_environment.ps1 -Command convert -InputFile "C:\input\$file" -OutputDir "C:\markdown"
}
```

#### Python 调用

```python
import subprocess
import os

def setup_environment(mirror="default"):
    """自动设置 MarkItDown 环境"""
    cmd = ["powershell", "-File", "manage_environment.ps1", "-Command", "setup"]
    if mirror != "default":
        cmd.extend(["-Mirror", mirror])

    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.returncode == 0

def convert_document(input_file, output_dir=""):
    """转换文档"""
    cmd = ["powershell", "-File", "manage_environment.ps1", "-Command", "convert", "-InputFile", input_file]
    if output_dir:
        cmd.extend(["-OutputDir", output_dir])

    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.returncode == 0

def read_markdown_file(file_path):
    """读取生成的 markdown 文件"""
    with open(file_path, 'r', encoding='utf-8') as f:
        return f.read()
```

#### JavaScript/Node.js 调用

```javascript
const { execSync } = require('child_process');
const fs = require('fs');

function setupEnvironment() {
    try {
        execSync('powershell -File manage_environment.ps1 -Command setup', {
            stdio: 'inherit'
        });
        console.log('Environment setup completed');
    } catch (error) {
        console.error('Setup failed:', error);
    }
}

function convertDocument(inputFile, outputDir) {
    let cmd = `powershell -File manage_environment.ps1 -Command convert -InputFile "${inputFile}"`;
    if (outputDir) {
        cmd += ` -OutputDir "${outputDir}"`;
    }
    return execSync(cmd, { encoding: 'utf-8' });
}

function readMarkdownFile(filePath) {
    return fs.readFileSync(filePath, 'utf-8');
}

// AI Agent 使用示例
const inputFile = "C:\\input\\document.pdf";
const outputDir = "C:\\markdown_docs";

// 1. 转换文档
console.log("Converting document...");
const result = convertDocument(inputFile, outputDir);
console.log(result);

// 2. 自动读取生成的文件
const markdownFile = `${outputDir}\\document.md`;
const content = readMarkdownFile(markdownFile);
console.log("Generated Markdown Content:");
console.log(content);
```

### 完整 AI Agent 工作流示例

```python
import subprocess
import os

class DocumentConverter:
    def __init__(self, script_dir):
        self.script_dir = script_dir

    def ask_user_for_paths(self):
        """向用户获取输入输出路径"""
        input_file = input("请输入待转换文档的完整路径: ").strip()
        output_dir = input("请输入 Markdown 输出目录（直接回车使用当前目录）: ").strip()

        if not output_dir:
            output_dir = os.getcwd()

        return input_file, output_dir

    def setup(self, mirror="aliyun"):
        """初始化环境（使用国内镜像）"""
        print(f"正在设置环境，使用镜像: {mirror}...")
        script_path = os.path.join(self.script_dir, "manage_environment.ps1")
        cmd = ["powershell", "-File", script_path, "-Command", "setup"]

        if mirror != "default":
            cmd.extend(["-Mirror", mirror])

        result = subprocess.run(cmd, capture_output=True, text=True)
        return result.returncode == 0

    def convert(self, input_file, output_dir):
        """转换文档"""
        print(f"正在转换文档: {input_file}")
        script_path = os.path.join(self.script_dir, "manage_environment.ps1")
        cmd = [
            "powershell", "-File", script_path,
            "-Command", "convert",
            "-InputFile", input_file,
            "-OutputDir", output_dir
        ]
        result = subprocess.run(cmd, capture_output=True, text=True)
        return result.returncode == 0

    def read_result(self, input_file, output_dir):
        """读取转换结果"""
        basename = os.path.splitext(os.path.basename(input_file))[0]
        md_file = os.path.join(output_dir, f"{basename}.md")

        if os.path.exists(md_file):
            with open(md_file, 'r', encoding='utf-8') as f:
                return f.read()
        return None

converter = DocumentConverter("scripts")

input_file, output_dir = converter.ask_user_for_paths()

success = converter.setup(mirror="aliyun")
if success:
    success = converter.convert(input_file, output_dir)

if success:
    content = converter.read_result(input_file, output_dir)
    if content:
        print("\n" + "="*80)
        print("转换结果:")
        print("="*80)
        print(content)
else:
    print("文档转换失败")
```

---

## 最佳实践

### 1. 环境隔离
为不同项目创建独立环境，避免依赖冲突。

```powershell
# 项目 A 环境
.\manage_environment.ps1 -Command setup -EnvironmentName "project_a" -PythonVersion "3.11"

# 项目 B 环境
.\manage_environment.ps1 -Command setup -EnvironmentName "project_b" -PythonVersion "3.12"
```

### 2. 日志管理
定期清理日志文件，避免占用过多空间。

```powershell
# 查看日志
Get-Content environment.log -Tail 20

# 清理日志
Remove-Item environment.log
```

### 3. 版本控制
使用环境变量实现版本一致性。

```powershell
# 在项目根目录创建 .env 文件
$env:MARKITDOWN_ENV_NAME = "myproject"
$env:MARKITDOWN_PYTHON_VER = "3.11"
```

---

## 更新日志

### v5.0.0 (当前版本)
- 🔒 **移除 Python 检测**：仅保留 Conda 环境检测
- 🔒 **移除 venv 回退**：不再支持 venv 虚拟环境
- ✨ **仅 Conda**：只检测和创建 Conda 环境
- ✨ **简化流程**：4 步流程 (检测安装 -> 检测环境 -> 自动创建 -> 安装依赖)
- 📝 **环境要求更新**：Conda 变为必需

### v4.1.0
- 🔒 **安全优化**：移除所有高危操作（create、remove、install、force命令）
- 🔒 **临时镜像**：pip镜像配置仅在当前安装过程中使用，不持久化
- 🔒 **环境保护**：不删除任何环境，不强制覆盖现有环境
- 🔒 **系统安全**：不修改系统pip配置，不修改pip.conf文件
- ✨ **简化命令**：精简命令集，保留最常用的check、setup、convert命令
- ✨ **更好的兼容性**：提高在不同环境下的兼容性

### v3.1.0
- ✨ **PDF中文编码自动修复**：使用pdfplumber的Unicode级提取解决中文乱码
- ✨ **无需额外依赖**：利用pdfplumber内置功能，不增加包体积
- 📝 **智能文本质量检测**：自动检测乱码率和中文比例
- 🔄 **自动回退机制**：编码修复失败时自动回退到markitdown标准转换
- 📝 **详细的修复说明**：添加PDF编码问题背景和解决方案文档

### v3.0.0
- ✨ **pip Fallback 机制**：conda 不可用时自动使用 pip 安装
- ✨ **convert 命令**：一键转换文档，自动处理输入输出路径
- ✨ **智能环境检测**：自动检测并选择最佳安装方式
- 📝 **AI Agent 指南**：添加完整的工作流示例和代码模板
- 🔧 **参数简化**：`convert` 命令简化参数（`-InputFile`, `-OutputDir`）
- 📝 **完善的故障排除**：添加 pip fallback 相关问题解决方案

### v2.0.0
- ✨ 跨平台统一 CLI 接口
- ✨ 自动操作系统检测
- ✨ 智能 Conda 路径查找
- ✨ 完善的错误处理和日志
- 🔧 删除重复脚本，优化代码结构
- 📝 完善文档和使用示例

### v1.0.0
- 初始版本
- 支持 Windows PowerShell

---

## 技术要求

- **Conda**: Miniconda 4.12+ 或 Anaconda
- **Python**: 3.8+ (默认 3.12)
- **系统**: Windows 10+, Linux, macOS
- **依赖**: markitdown[all]

---

## 相关资源

- [MarkItDown 官方文档](https://pypi.org/project/markitdown/)
- [Conda 官方文档](https://docs.conda.io/)
- [Miniconda 下载](https://docs.conda.io/en/latest/miniconda.html)

---

## 许可说明

本技能基于 MIT 许可证开源，请参考各组件的相应许可证。
