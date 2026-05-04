# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

markdown-everything 是一个 AI Agent Skill，将 20+ 种文档格式（PDF、Word、Excel、PPT、图片、音频）转换为 Markdown。核心依赖是 markitdown，针对中文 PDF 做了 pdfplumber 的 Unicode 字符级提取来解决乱码。

## 常用命令

```bash
# 基本转换
python SKILL/markdown-everything/scripts/convert_document.py "文档.pdf" -o "输出.md"

# 直接用 markitdown CLI
markitdown "文档.docx" -o "输出.md"

# JSON 格式输出
python SKILL/markdown-everything/scripts/convert_document.py "文档.docx" --json-output

# 详细日志
python SKILL/markdown-everything/scripts/convert_document.py "文档.docx" --verbose

# 环境管理（PowerShell）
.\SKILL\markdown-everything\scripts\manage_environment.ps1 -Command setup
.\SKILL\markdown-everything\scripts\manage_environment.ps1 -Command check

# 环境管理（Bash）
bash SKILL/markdown-everything/scripts/manage_environment.sh setup
bash SKILL/markdown-everything/scripts/manage_environment.sh check
```

## 架构

```
SKILL/markdown-everything/
├── SKILL.md                          # Skill 定义，Claude Code 加载此文件触发转换
└── scripts/
    ├── convert_document.py           # 主入口：DocumentConverter 类 + CLI
    ├── pdf_encoding_fixer.py         # PDF 专用：PDFEncodingFixer 类
    ├── manage_environment.ps1        # Windows 环境管理（Conda/pip）
    └── manage_environment.sh         # Linux/macOS 环境管理
```

### 转换流程

1. PDF 文件 → `PDFEncodingFixer.convert()` → pdfplumber Unicode 字符级提取
2. 如果 pdfplumber 失败 → 回退到 `page.extract_text()`
3. 如果仍然失败 → 回退到标准 markitdown
4. 非 PDF 文件 → 直接用 `DocumentConverter.convert()` 调 markitdown
5. 可选：LLM 后处理（GPT-4 / Claude）

### 关键类

- **`DocumentConverter`** (`convert_document.py`): 封装 markitdown，管理 LLM 客户端初始化，返回 `{success, text_content, output_file}` 结构
- **`PDFEncodingFixer`** (`pdf_encoding_fixer.py`): 用 pdfplumber 的 `page.chars` 对象按 Unicode 字段提取文字，绕过 PDF 字节编码问题。包含文本质量检测（中文比例、乱码率）

### 环境管理脚本

PowerShell 和 Bash 版本功能一致：
- 自动检测 Conda 安装路径（扫描多个默认位置）
- 自动创建 markitdown Conda 环境
- 支持 pip 镜像源（tsinghua/aliyun/douban）
- 支持 `MARKITDOWN_USE_PIP=true` 跳过 Conda 直接用系统 Python

## 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `MARKITDOWN_ENV_NAME` | `markitdown` | Conda 环境名 |
| `MARKITDOWN_PYTHON_VER` | `3.12` | Python 版本 |
| `MARKITDOWN_USE_PIP` | `false` | 跳过 Conda |
| `MARKITDOWN_PIP_MIRROR` | `default` | 镜像源 |
| `OPENAI_API_KEY` | — | GPT-4 增强 |
| `ANTHROPIC_API_KEY` | — | Claude 增强 |

## 注意事项

- Python 要求 3.11+
- Windows PowerShell 不支持 `&&` 连命令，用 `;` 或分行
- PDF 中文乱码的根因是 markitdown 用字节级解码，本工具改用 pdfplumber 的 chars.unicode 字段
- `convert_document.py` 通过 `sys.path.insert` 导入同目录的 `pdf_encoding_fixer`，不要移动文件位置
- 提交信息用中文，格式参考 git log
