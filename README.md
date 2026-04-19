# markdown-everything

[![skill-AI-Agent](https://img.shields.io/badge/skill-AI%20Agent%20Skill-purple.svg)]()
[![version-v1.0.0](https://img.shields.io/badge/version-v1.0.0-blue.svg)](https://github.com/wokaka209/markdown_everything)
[![license-MIT](https://img.shields.io/badge/license-MIT-green.svg)]()
[![platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-green.svg)]()
[![python-3.11](https://img.shields.io/badge/python-3.11%2B-yellow.svg)]()
[![AI-Agents](https://img.shields.io/badge/AI%20Agents-Codex%20%7C%20Claude%20Code%20%7C%20Cursor%20%7C%20Trae-orange.svg)]()
[![made-with-markitdown](https://img.shields.io/badge/Made%20with-Markitdown-orange)](https://github.com/microsoft/markitdown)

[English](README_en.md)

将 PDF、Word、Excel、PPT、图片、音频等 20+ 种格式转换为 Markdown，让 AI Agent 能直接读取文档内容。

## 快速开始

```bash
pip install "markitdown[all]"
markitdown "文档.pdf" -o "输出.md"
```

## 支持的格式

| 类别 | 格式 | 说明 |
|------|------|------|
| 文档 | `.pdf` `.docx` `.doc` | PDF、Word 文档 |
| 表格 | `.xlsx` `.xls` `.csv` | Excel、CSV 表格 |
| 演示 | `.pptx` `.ppt` | PowerPoint 幻灯片 |
| 图片 | `.jpg` `.png` `.gif` `.bmp` | 图片文字识别 (OCR) |
| 音频 | `.mp3` `.wav` `.ogg` `.m4a` | 语音转文字 |
| 网页 | `.html` `.htm` | HTML 源码提取 |
| 数据 | `.json` `.xml` | 结构化数据转换 |
| 电子书 | `.epub` `.azw3` | 电子书格式 |
| 压缩 | `.zip` | 批量文档处理 |

## 核心特性

- **中文 PDF 修复** — 自动使用 `pdfplumber` Unicode 字符级提取，解决中文 PDF 乱码问题
- **环境自动管理** — 跨平台脚本自动检测 Conda / pip，一键配置环境
- **LLM 增强** — 可选集成 OpenAI / Anthropic 进行智能优化
- **Agent Skills 标准** — 符合 [Agent Skills 开放标准](https://agentskills.io)，兼容 Codex、Claude Code 等

## 项目结构

```
SKILL/markdown-everything/
├── SKILL.md                      # Skill 定义（Agent Skills 标准）
└── scripts/
    ├── convert_document.py        # 核心转换引擎
    ├── pdf_encoding_fixer.py      # PDF 编码修复模块
    ├── manage_environment.ps1     # Windows 环境管理器
    └── manage_environment.sh      # Linux/macOS 环境管理器
```

## 安装

### 方式一：pip（推荐）

```bash
pip install "markitdown[all]"
pip install pdfplumber
```

### 方式二：Conda

```bash
conda create -n markitdown python=3.12 -y
conda activate markitdown
pip install "markitdown[all]"
pip install pdfplumber
```

### 方式三：环境管理脚本

```powershell
# Windows
.\SKILL\markdown-everything\scripts\manage_environment.ps1 -Command setup

# Linux/macOS
bash SKILL/markdown-everything/scripts/manage_environment.sh setup
```

国内用户使用镜像加速：

```bash
pip install "markitdown[all]" -i https://pypi.tuna.tsinghua.edu.cn/simple
```

## 使用

### 命令行

```bash
# 转换并保存
markitdown "文档.pdf" -o "输出.md"

# 使用 Python 脚本（支持 PDF 编码修复和 LLM 增强）
python SKILL/markdown-everything/scripts/convert_document.py "文档.pdf" -o "输出.md"
```

### Windows PowerShell 注意事项

PowerShell 不支持 `&&` 链接命令，请使用分号 `;` 或分行：

```powershell
# 正确
conda activate markitdown; markitdown "文档.pdf" -o "输出.md"

# 正确（分行）
conda activate markitdown
markitdown "文档.pdf" -o "输出.md"

# 错误（&& 在部分 PowerShell 版本不可用）
conda activate markitdown && markitdown "文档.pdf" -o "输出.md"
```

### 高级选项

```bash
# JSON 格式输出
python scripts/convert_document.py "文档.docx" --json-output

# 详细日志
python scripts/convert_document.py "文档.docx" --verbose

# LLM 增强
python scripts/convert_document.py "文档.docx" --llm-client openai --llm-model gpt-4o -o "输出.md"
```

### 批量转换

```powershell
# Windows PowerShell
Get-ChildItem "C:\Documents\*.docx" | ForEach-Object {
    markitdown $_.FullName -o "$($_.DirectoryName)\$($_.BaseName).md"
}
```

```bash
# Linux/macOS
for f in /path/to/docs/*.docx; do
    markitdown "$f" -o "${f%.docx}.md"
done
```

## 部署到 AI Agent

### OpenAI Codex

```bash
# 下载 skill 到 Codex skills 目录
$skill-installer install https://github.com/wokaka209/markdown_everything/tree/main/SKILL/markdown-everything
```

或手动将 `SKILL/markdown-everything/` 复制到 `~/.codex/skills/markdown-everything/`。

### Claude Code

```bash
# 方式一：Skills 格式（推荐，支持自动触发）
cp -r SKILL/markdown-everything ~/.claude/skills/markdown-everything

# 方式二：Commands 格式（仅手动触发）
mkdir -p ~/.claude/commands
cp SKILL/markdown-everything/SKILL.md ~/.claude/commands/markdown.md
```

### Cursor / Trae / Obsidian YOLO

在 Agent 配置页面添加自定义命令或脚本路径。

## 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `MARKITDOWN_ENV_NAME` | `markitdown` | Conda 环境名称 |
| `MARKITDOWN_PYTHON_VER` | `3.12` | Conda 环境 Python 版本 |
| `MARKITDOWN_USE_PIP` | `false` | 设为 `true` 跳过 conda，直接使用系统 pip |
| `MARKITDOWN_PIP_MIRROR` | `default` | pip 镜像源 (tsinghua/aliyun/douban/custom) |
| `MARKITDOWN_CUSTOM_MIRROR` | — | 自定义 pip 镜像 URL |
| `OPENAI_API_KEY` | — | GPT-4 增强转换（可选） |
| `ANTHROPIC_API_KEY` | — | Claude 增强转换（可选） |

## 常见问题

| 问题 | 解决方案 |
|------|----------|
| conda 命令找不到 | 安装 [Miniconda](https://docs.conda.io/en/latest/miniconda.html)；Windows 使用 Anaconda Prompt |
| pip 安装超时 | 使用镜像源：`pip install "markitdown[all]" -i https://pypi.tuna.tsinghua.edu.cn/simple` |
| PDF 中文乱码 | 确保安装了 pdfplumber：`pip install pdfplumber` |
| 输出文件乱码 | 输出为 UTF-8，用 VS Code 打开即可 |
| PowerShell 不支持 `&&` | 改用分号 `;` 连接命令，或分行执行 |

## 相关链接

- MarkItDown: https://pypi.org/project/markitdown/
- Agent Skills 标准: https://agentskills.io/
- Conda: https://docs.conda.io/

---

License: MIT
