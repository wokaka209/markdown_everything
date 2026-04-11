---
name: markdown_everything
description: |
  智能文档转换技能 - 将各类文档格式转换为 Markdown

  ## 核心能力
- 跨平台支持：Windows PowerShell / Linux Bash / macOS Bash
- 自动环境管理：智能检测、自动创建、自动激活 Conda 环境
- **pip Fallback**：conda 不可用时自动使用 pip 安装
- **PDF中文编码自动修复**：智能检测并修复中文PDF乱码问题
- 多格式支持：PDF、Word、Excel、PPT、图片、音频等 20+ 种格式
- 零配置使用：首次自动初始化，后续即开即用

  ## 技术特性
  - 统一的命令行接口（CLI）
  - 完善的错误处理和日志记录
  - 环境变量灵活配置
  - 跨平台路径自动适配
  - 智能 fallback 机制（conda → pip）

---

## 快速开始

### 一键初始化

```powershell
# PowerShell (Windows)
.\manage_environment.ps1 -Command setup

# Bash (Linux/macOS)
./manage_environment.sh setup
```

### 文档转换（推荐使用 convert 命令）⭐

```powershell
# PowerShell - 转换文档到当前目录
.\manage_environment.ps1 -Command convert -InputFile "document.pdf"

# PowerShell - 转换文档到指定目录
.\manage_environment.ps1 -Command convert -InputFile "document.pdf" -OutputDir "C:\output"

# Bash - 转换文档到当前目录
./manage_environment.sh convert -i document.pdf

# Bash - 转换文档到指定目录
./manage_environment.sh convert -i document.pdf -o /path/to/output
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
检查 conda 和 MarkItDown 环境状态。

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
Conda path: D:\anaconda\conda.exe
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

#### create - 创建环境
新建 Conda 环境并安装 Python。

```powershell
# 创建默认环境 (Python 3.12)
.\manage_environment.ps1 -Command create

# 创建自定义环境
.\manage_environment.ps1 -Command create -EnvironmentName "myenv" -PythonVersion "3.11"
```

#### remove - 移除环境
删除指定的 Conda 环境。

```powershell
.\manage_environment.ps1 -Command remove -EnvironmentName "old_env"
```

#### install - 安装包
在指定环境中安装 MarkItDown。

```powershell
.\manage_environment.ps1 -Command install -EnvironmentName "markitdown"
```

#### setup - 完整设置 ⭐
一键完成环境创建和包安装（推荐）。

```powershell
# 标准设置
.\manage_environment.ps1 -Command setup

# 强制重建（删除旧环境）
.\manage_environment.ps1 -Command setup -Force
```

#### run - 执行命令 ⭐
在指定环境中运行命令（conda 优先，pip 作为 fallback）。

```powershell
# 检查 Python 版本
.\manage_environment.ps1 -Command run -RunCommand @("python", "--version")

# 列出支持的格式
.\manage_environment.ps1 -Command run -RunCommand @("python", "convert_document.py", "--list-formats")

# 转换文档（使用 run 命令）
.\manage_environment.ps1 -Command run -RunCommand @("python", "convert_document.py", "input.pdf", "-o", "output.md")
```

#### convert - 转换文档 ⭐⭐⭐（推荐）
一键转换文档，自动处理输入输出路径（conda 优先，pip 作为 fallback）。

```powershell
# PowerShell - 转换文档到当前目录
.\manage_environment.ps1 -Command convert -InputFile "document.pdf"

# PowerShell - 转换文档到指定目录
.\manage_environment.ps1 -Command convert -InputFile "document.pdf" -OutputDir "C:\output"

# PowerShell - 强制使用 pip
.\manage_environment.ps1 -Command convert -InputFile "document.pdf" -OutputDir "C:\output" -UsePip
```

```bash
# Bash - 转换文档到当前目录
./manage_environment.sh convert -i document.pdf

# Bash - 转换文档到指定目录
./manage_environment.sh convert -i document.pdf -o /path/to/output

# Bash - 强制使用 pip
./manage_environment.sh convert --pip-only -i document.pdf -o /path/to/output
```

---

## 使用示例

### 场景 1：首次使用

```powershell
# 1. 检查环境（自动检测conda和pip）
.\manage_environment.ps1 -Command check

# 2. 一键初始化（conda优先，pip作为fallback）
.\manage_environment.ps1 -Command setup

# 3. 转换文档（推荐使用convert命令）
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

### 场景 3：自定义环境

```powershell
# 创建 Python 3.11 环境
.\manage_environment.ps1 -Command setup -EnvironmentName "py311_markitdown" -PythonVersion "3.11"

# 使用自定义环境转换
.\manage_environment.ps1 -Command convert -InputFile "file.pdf" -OutputDir "C:\output"
```

### 场景 4：pip Fallback 使用

```powershell
# 强制使用 pip（即使 conda 可用）
.\manage_environment.ps1 -Command setup -UsePip

# 转换文档强制使用 pip
.\manage_environment.ps1 -Command convert -InputFile "file.pdf" -OutputDir "C:\output" -UsePip
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

1. **优先使用 Conda**：检查 conda 是否可用，优先使用 conda 环境
2. **自动检测**：如果 conda 不可用或环境不存在，自动切换到 pip
3. **强制模式**：通过 `-UsePip`（PowerShell）或 `--pip-only`（Bash）强制使用 pip

### 优先级流程

```
环境检查
    ↓
Conda 可用? ───是──→ Conda 环境存在? ──是──→ 使用 Conda 环境
    ↓否                ↓否
使用 pip            创建/安装
                        ↓
                    失败? ──是──→ 回退到 pip
                        ↓否
                    成功
```

### 使用场景

| 场景 | 推荐方式 |
|------|---------|
| 已安装 Conda | 使用 conda 环境（推荐）|
| 未安装 Conda | 自动使用 pip |
| Conda 环境损坏 | 自动回退到 pip |
| 隔离环境需求 | 使用 conda 环境 |
| 快速测试 | 使用 pip（`--pip-only`）|

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
# 手动指定 conda 路径
$env:Path += ";D:\anaconda;D:\anaconda\Scripts"
.\manage_environment.ps1 -Command check

# 或者使用 pip fallback
.\manage_environment.ps1 -Command setup -UsePip
```

### 问题 2：环境创建失败

**原因**: Python 版本不存在或网络问题。

**解决**:
```powershell
# 使用已验证的版本
.\manage_environment.ps1 -Command create -PythonVersion "3.11"

# 或使用 pip fallback
.\manage_environment.ps1 -Command setup -UsePip
```

### 问题 3：权限不足

**原因**: Windows 权限限制。

**解决**:
```powershell
# 以管理员身份运行 PowerShell
Start-Process powershell -Verb RunAs
.\manage_environment.ps1 -Command setup
```

### 问题 4：pip 安装失败

**原因**: 网络问题或 pip 版本过旧。

**解决**:
```powershell
# 升级 pip
python -m pip install --upgrade pip

# 重新尝试安装
.\manage_environment.ps1 -Command setup -UsePip
```

### 问题 5：markitdown 安装失败

**原因**: 依赖库安装失败或版本冲突。

**解决**:
```powershell
# 清理并重新安装
python -m pip uninstall markitdown -y
.\manage_environment.ps1 -Command setup -UsePip
```

### 问题 6：转换文档失败

**原因**: 输入文件不存在或格式不支持。

**解决**:
```powershell
# 检查文件是否存在
Test-Path "C:\input\document.pdf"

# 查看支持的格式
.\manage_environment.ps1 -Command run -RunCommand @("python", "convert_document.py", "--list-formats")
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

def setup_environment():
    """自动设置 MarkItDown 环境"""
    result = subprocess.run(
        ["powershell", "-File", "manage_environment.ps1", "-Command", "setup"],
        capture_output=True,
        text=True
    )
    return result.returncode == 0

def convert_document(input_file, output_dir=""):
    """转换文档"""
    cmd = ["powershell", "-File", "manage_environment.ps1", "-Command", "convert", "-InputFile", input_file]
    if output_dir:
        cmd.extend(["-OutputDir", output_dir])

    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.returncode == 0, result.stdout, result.stderr

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
# AI Agent 完整工作流

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

    def setup(self):
        """初始化环境"""
        print("正在检查并设置环境...")
        result = subprocess.run(
            ["powershell", "-File", os.path.join(self.script_dir, "manage_environment.ps1"),
             "-Command", "setup"],
            capture_output=True,
            text=True
        )
        return result.returncode == 0

    def convert(self, input_file, output_dir):
        """转换文档"""
        print(f"正在转换文档: {input_file}")
        cmd = [
            "powershell", "-File", os.path.join(self.script_dir, "manage_environment.ps1"),
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

# 使用示例
converter = DocumentConverter("e:\\whx_Graduation project\\tools\\.trae\\skills\\markdown_everything\\scripts")

# 向用户获取信息
input_file, output_dir = converter.ask_user_for_paths()

# 转换文档
converter.setup()
success = converter.convert(input_file, output_dir)

if success:
    # 读取并展示结果
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

### v3.1.0 (当前版本)
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
