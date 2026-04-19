---
name: markdown-everything
description: "Converts 20+ document formats (PDF, DOCX, XLSX, PPTX, images, audio) to Markdown. Invoke when user asks to convert documents, extract text from files, or transform formats to Markdown."
license: MIT
compatibility: "Requires Python 3.11+ and markitdown package. Supports Windows (PowerShell), macOS, and Linux (Bash)."
metadata:
  author: wokaka209
  version: "1.0"
allowed-tools: Bash(python:*) Bash(markitdown:*) Bash(pip:*) Bash(conda:*) Read Write
---

# markdown-everything

将 PDF、Word、Excel、PPT、图片、音频等 20+ 种文档格式转换为 Markdown，让 AI Agent 能直接读取文档内容。

## 支持的格式

| 类别 | 格式 |
|------|------|
| 办公文档 | `.pdf` `.docx` `.doc` `.pptx` `.ppt` `.xlsx` `.xls` `.csv` |
| 图片 | `.jpg` `.png` `.gif` `.bmp` (OCR) |
| 音频 | `.mp3` `.wav` `.ogg` `.m4a` |
| 网页/数据 | `.html` `.htm` `.json` `.xml` |
| 其他 | `.epub` `.azw3` `.zip` |

## 触发条件

当用户要求以下操作时调用此技能：
- 将文档转换为 Markdown
- 读取/提取文档内容
- 批量处理文档
- 处理中文 PDF 乱码

## 使用方法

### 第一步：环境准备

首次使用需安装依赖。根据操作系统选择对应命令：

**Windows (PowerShell)**：

```powershell
pip install "markitdown[all]"
pip install pdfplumber
```

如果使用 Conda：

```powershell
conda create -n markitdown python=3.12 -y
conda activate markitdown
pip install "markitdown[all]"
pip install pdfplumber
```

**Linux / macOS**：

```bash
pip install "markitdown[all]"
pip install pdfplumber
```

如果使用 Conda：

```bash
conda create -n markitdown python=3.12 -y
conda activate markitdown
pip install "markitdown[all]"
pip install pdfplumber
```

国内用户可使用镜像加速：

```powershell
pip install "markitdown[all]" -i https://pypi.tuna.tsinghua.edu.cn/simple
```

### 第二步：转换文档

**基本转换**：

```bash
python scripts/convert_document.py "输入文件.pdf" -o "输出.md"
```

或直接使用 markitdown CLI：

```bash
markitdown "输入文件.docx" -o "输出.md"
```

**Windows PowerShell 用户注意**：不要使用 `&&` 链接命令，请用分号 `;` 或分行：

```powershell
# 正确：分号链接
conda activate markitdown; markitdown "文档.pdf" -o "输出.md"

# 正确：分行
conda activate markitdown
markitdown "文档.pdf" -o "输出.md"

# 错误：&& 在部分 PowerShell 版本不可用
conda activate markitdown && markitdown "文档.pdf" -o "输出.md"
```

### PDF 中文文档特殊处理

PDF 文件会自动使用 `pdfplumber` 进行 Unicode 字符级提取，解决中文乱码问题。如果自动处理失败，会回退到标准 markitdown 转换。

### 高级选项

```bash
# JSON 格式输出
python scripts/convert_document.py "文档.docx" --json-output

# 详细日志
python scripts/convert_document.py "文档.docx" --verbose

# LLM 增强（需设置 OPENAI_API_KEY 或 ANTHROPIC_API_KEY）
python scripts/convert_document.py "文档.docx" --llm-client openai --llm-model gpt-4o -o "输出.md"
```

### 批量转换

**Windows PowerShell**：

```powershell
Get-ChildItem "C:\Documents\*.docx" | ForEach-Object {
    markitdown $_.FullName -o "$($_.DirectoryName)\$($_.BaseName).md"
}
```

**Linux / macOS**：

```bash
for f in /path/to/docs/*.docx; do
    markitdown "$f" -o "${f%.docx}.md"
done
```

## 常见问题

| 问题 | 解决方案 |
|------|----------|
| conda 命令找不到 | 安装 [Miniconda](https://docs.conda.io/en/latest/miniconda.html)；Windows 用户使用 Anaconda Prompt |
| pip 安装超时 | 使用镜像源：`-i https://pypi.tuna.tsinghua.edu.cn/simple` |
| PDF 中文乱码 | 确保安装了 pdfplumber：`pip install pdfplumber` |
| 输出文件乱码 | 输出为 UTF-8，用 VS Code 打开即可 |
| PowerShell 不支持 `&&` | 改用分号 `;` 连接命令，或分行执行 |

## 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `MARKITDOWN_ENV_NAME` | `markitdown` | Conda 环境名称 |
| `MARKITDOWN_PYTHON_VER` | `3.12` | Python 版本 |
| `MARKITDOWN_USE_PIP` | `false` | 设为 `true` 跳过 conda，使用系统 pip |
| `OPENAI_API_KEY` | — | GPT-4 增强转换 |
| `ANTHROPIC_API_KEY` | — | Claude 增强转换 |
