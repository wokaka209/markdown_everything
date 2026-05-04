---
name: markdown-everything
description: "Converts 20+ document formats (PDF, DOCX, XLSX, PPTX, images, audio) to Markdown. Invoke when user asks to convert documents, extract text from files, or transform formats to Markdown."
license: MIT
compatibility: "Requires Python 3.11+ and markitdown package. Supports Windows (PowerShell), macOS, and Linux (Bash)."
metadata:
  author: wokaka209
  version: "1.1"
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# markdown-everything

将 PDF、Word、Excel、PPT、图片、音频等 20+ 种文档格式转换为 Markdown，让 AI Agent 能直接读取文档内容。

## 触发条件

当用户要求以下操作时调用此技能：
- 将文档转换为 Markdown
- 读取/提取文档内容
- 批量处理文档
- 处理中文 PDF 乱码

**注意**：如果用户只是问"怎么用 markitdown"，先回答问题，不要直接触发转换。

## 支持的格式

| 类别 | 格式 |
|------|------|
| 办公文档 | `.pdf` `.docx` `.doc` `.pptx` `.ppt` `.xlsx` `.xls` `.csv` |
| 图片 | `.jpg` `.png` `.gif` `.bmp` (OCR) |
| 音频 | `.mp3` `.wav` `.ogg` `.m4a` |
| 网页/数据 | `.html` `.htm` `.json` `.xml` |
| 其他 | `.epub` `.azw3` `.zip` |

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
python SKILL/markdown-everything/scripts/convert_document.py "输入文件.pdf" -o "输出.md"
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
python SKILL/markdown-everything/scripts/convert_document.py "文档.docx" --json-output

# 详细日志
python SKILL/markdown-everything/scripts/convert_document.py "文档.docx" --verbose

# LLM 增强（需设置 OPENAI_API_KEY 或 ANTHROPIC_API_KEY）
python SKILL/markdown-everything/scripts/convert_document.py "文档.docx" --llm-client openai --llm-model gpt-4o -o "输出.md"
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

## 故障排除

### 转换失败

| 错误 | 原因 | 解决方案 |
|------|------|----------|
| `ModuleNotFoundError: No module named 'markitdown'` | 未安装依赖 | `pip install "markitdown[all]"` |
| `No module named 'pdfplumber'` | PDF 处理依赖缺失 | `pip install pdfplumber` |
| `Unsupported format` | 文件格式不支持 | 检查文件扩展名是否在支持列表中 |
| `Permission denied` | 文件被占用或权限不足 | 关闭文件，或用管理员权限运行 |
| `FileNotFoundError` | 文件路径错误 | 使用绝对路径，检查文件名拼写 |

### 输出格式问题

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| 表格错乱 | markitdown 对复杂表格支持有限 | 用 `--json-output` 获取结构化数据，或用 Excel 打开原文件 |
| 图片丢失 | markitdown 不提取图片 | 图片需要单独处理，用 OCR 工具提取文字 |
| 中文乱码 | 编码问题 | 确保安装 pdfplumber；用 VS Code 以 UTF-8 打开输出文件 |
| 链接失效 | 相对路径转换问题 | 检查原文件链接，手动修复 |

### 环境问题

| 问题 | 解决方案 |
|------|----------|
| conda 命令找不到 | 安装 [Miniconda](https://docs.conda.io/en/latest/miniconda.html)；Windows 用户使用 Anaconda Prompt |
| pip 安装超时 | 使用镜像源：`-i https://pypi.tuna.tsinghua.edu.cn/simple` |
| PowerShell 不支持 `&&` | 改用分号 `;` 连接命令，或分行执行 |

## 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `MARKITDOWN_ENV_NAME` | `markitdown` | Conda 环境名称 |
| `MARKITDOWN_PYTHON_VER` | `3.12` | Python 版本 |
| `MARKITDOWN_USE_PIP` | `false` | 设为 `true` 跳过 conda，使用系统 pip |
| `MARKITDOWN_PIP_MIRROR` | `default` | 镜像源（tsinghua/aliyun/douban） |
| `OPENAI_API_KEY` | — | GPT-4 增强转换 |
| `ANTHROPIC_API_KEY` | — | Claude 增强转换 |

## 注意事项

- 首次使用会自动检测并安装依赖
- PDF 中文文档优先使用 pdfplumber 处理
- 大文件转换可能需要较长时间
- LLM 增强功能需要 API Key
- 输出文件默认保存在输入文件同目录
- Windows 用户：路径中包含空格时，用引号包裹路径
