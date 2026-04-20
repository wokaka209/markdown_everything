# markdown-everything

[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://mit-license.org/zh-CN)
[![Python](https://img.shields.io/badge/python-3.11%2B-yellow.svg)](https://www.python.org/downloads/release/python-3110/)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-green.svg)]()

[English](README_en.md) | [项目文档](#功能说明)

markdown-everything 将各种格式的文档转换为 Markdown，让 AI Agent 能够直接读取文档内容。

---

## 项目结构

```
markdown-everything/
├── README.md                      # 项目说明文档
├── README_en.md                   # English documentation
├── SKILL.md                       # AI Agent Skill 配置
└── scripts/
    ├── convert_document.py        # 转换引擎
    ├── pdf_encoding_fixer.py      # PDF 编码处理
    ├── manage_environment.ps1      # Windows 环境管理
    └── manage_environment.sh       # Linux/macOS 环境管理
```

---

## 功能说明

这个工具可以处理以下类型的文档：

- PDF 文档（包括中文 PDF）
- Word 文档（docx, doc）
- Excel 表格（xlsx, xls, csv）
- PowerPoint 演示文稿（pptx, ppt）
- 图片中的文字（OCR）
- 音频文件转文字
- 网页内容提取
- JSON、XML 等数据文件
- 电子书格式（epub, azw3）

---

## 环境配置

### 系统要求

- Python 3.11 或更高版本
- pip 包管理器（或 conda）

### 依赖安装

使用 pip 安装核心依赖：

```bash
pip install "markitdown[all]"
pip install pdfplumber
```

使用国内镜像（推荐）：

```bash
pip install "markitdown[all]" -i https://pypi.tuna.tsinghua.edu.cn/simple
pip install pdfplumber -i https://pypi.tuna.tsinghua.edu.cn/simple
```

可选依赖 - 如果需要 LLM 增强功能：

```bash
pip install openai      # GPT-4 增强
pip install anthropic   # Claude 增强
```

### Conda 环境配置

```bash
conda create -n markitdown python=3.11 -y
conda activate markitdown
pip install "markitdown[all]"
pip install pdfplumber
```

---

## 使用方法

### 在 AI Agent 中使用

当你需要 AI Agent 处理某个文档时，可以直接说明需求：

```
帮我把周报.docx 转成 Markdown 格式
AI Agent 会自动调用 markitdown 进行转换
```

支持的触发方式：

1. 直接描述需求：帮我转换这个文档
2. 指定格式：转换为 Markdown
3. 批量处理：转换目录下所有文档

### 命令行使用

```bash
markitdown document.pdf -o output.md
```

---

## 进阶功能

### PDF 中文处理

如果 PDF 中文显示乱码，确保安装了 pdfplumber：

```bash
pip install pdfplumber
```

### LLM 增强

启用 GPT-4 优化输出：

```bash
export OPENAI_API_KEY="your-api-key"
python scripts/convert_document.py "文档.docx" --llm-client openai --llm-model gpt-4o -o "输出.md"
```

启用 Claude 优化输出：

```bash
export ANTHROPIC_API_KEY="your-api-key"
python scripts/convert_document.py "文档.docx" --llm-client anthropic --llm-model claude-3-sonnet -o "输出.md"
```

### 批量转换

PowerShell 批量转换：

```powershell
Get-ChildItem "C:\Documents\*.docx" | ForEach-Object {
    markitdown $_.FullName -o "$($_.DirectoryName)\$($_.BaseName).md"
}
```

Linux/macOS 批量转换：

```bash
for f in /path/to/docs/*.docx; do
    markitdown "$f" -o "${f%.docx}.md"
done
```

---

## 常用参数

| 参数 | 说明 |
|------|------|
| -o, --output | 指定输出文件路径 |
| --list-formats | 显示所有支持的格式 |
| --verbose | 显示详细执行信息 |
| --json-output | 输出 JSON 格式 |
| --llm-client | 选择 LLM 客户端 (openai/anthropic) |
| --llm-model | 指定 LLM 模型 |

---

## 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| MARKDOWN_ENV_NAME | markitdown | Conda 环境名称 |
| MARKDOWN_PYTHON_VER | 3.12 | Python 版本 |
| MARKDOWN_USE_PIP | false | 设为 true 跳过 Conda |
| MARKDOWN_PIP_MIRROR | default | 镜像源 |
| OPENAI_API_KEY | - | GPT-4 API 密钥 |
| ANTHROPIC_API_KEY | - | Claude API 密钥 |

---

## 常见问题

### conda 命令找不到

安装 Miniconda：https://docs.conda.io/en/latest/miniconda.html
Windows 用户使用 Anaconda Prompt 执行命令。

### pip 安装失败

使用国内镜像源：

```bash
pip install markitdown[all] -i https://pypi.tuna.tsinghua.edu.cn/simple
```

### PDF 中文乱码

安装 pdfplumber：

```bash
pip install pdfplumber
```

### 输出文件乱码

markitdown 输出 UTF-8 编码。用 VS Code 打开文件，选择"通过编码重新打开"选择 UTF-8。

---

## 贡献指南

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (git checkout -b feature/AmazingFeature)
3. 提交更改 (git commit -m 'Add some AmazingFeature')
4. 推送到分支 (git push origin feature/AmazingFeature)
5. 创建 Pull Request

---

## 相关资源

- markitdown 项目：https://pypi.org/project/markitdown/
- Agent Skills 标准：https://agentskills.io/
- Conda 文档：https://docs.conda.io/

---

## 许可证

本项目采用 MIT 许可证 - 详见 LICENSE 文件

---

## 联系方式

项目作者：wokaka209
项目地址：https://github.com/wokaka209/markdown_everything

[返回顶部](#markdown-everything)
