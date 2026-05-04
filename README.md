**[English](README_en.md)** | 中文

# markdown-everything

![Python](https://img.shields.io/badge/Python-3.11+-3776AB?style=flat-square&logo=python&logoColor=fff)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-0A0A0A?style=flat-square)

把 PDF、Word、Excel、PPT、图片、音频等 20+ 种格式丢给它，出来就是干净的 Markdown。主要给 AI Agent 用——让它能直接读懂各种文档。

## 目录

- [这是什么](#这是什么)
- [跑起来](#跑起来)
- [支持的格式](#支持的格式)
- [用法](#用法)
- [PDF 中文处理](#pdf-中文处理)
- [批量转换](#批量转换)
- [LLM 增强](#llm-增强)
- [常见问题](#常见问题)
- [环境变量](#环境变量)
- [参与贡献](#参与贡献)
- [用到的东西](#用到的东西)
- [许可协议](#许可协议)

## 这是什么

一个文档转换工具。底层用 markitdown，针对中文 PDF 做了 pdfplumber 的 Unicode 级提取，解决乱码问题。

你跟 AI Agent 说"帮我把这个 docx 转成 Markdown"，它就自动调用了。不需要记命令。

## 跑起来

```bash
pip install "markitdown[all]" pdfplumber
```

国内慢的话加镜像：

```bash
pip install "markitdown[all]" pdfplumber -i https://pypi.tuna.tsinghua.edu.cn/simple
```

用 Conda 也行：

```bash
conda create -n markitdown python=3.12 -y
conda activate markitdown
pip install "markitdown[all]" pdfplumber
```

装完就能用了。

## 支持的格式

**办公文档**：`.pdf` `.docx` `.doc` `.pptx` `.ppt` `.xlsx` `.xls` `.csv`

**图片**（OCR）：`.jpg` `.png` `.gif` `.bmp`

**音频**：`.mp3` `.wav` `.ogg` `.m4a`

**网页/数据**：`.html` `.htm` `.json` `.xml`

**电子书**：`.epub` `.azw3`

## 用法

最简单的方式——直接跟 AI Agent 说你要转换什么：

```
帮我把周报.docx 转成 Markdown
```

命令行也行：

```bash
markitdown 文档.pdf -o 输出.md
```

**Windows PowerShell 注意**：别用 `&&` 连命令，用分号 `;` 或者分行写：

```powershell
# 对
conda activate markitdown; markitdown "文档.pdf" -o "输出.md"

# 错
conda activate markitdown && markitdown "文档.pdf" -o "输出.md"
```

## PDF 中文处理

中文 PDF 乱码？装 pdfplumber 就好：

```bash
pip install pdfplumber
```

工具会自动用 pdfplumber 做字符级提取。如果还是不行，会回退到标准 markitdown。

## 批量转换

**PowerShell**：

```powershell
Get-ChildItem "C:\文档\*.docx" | ForEach-Object {
    markitdown $_.FullName -o "$($_.DirectoryName)\$($_.BaseName).md"
}
```

**Linux / macOS**：

```bash
for f in /path/to/docs/*.docx; do
    markitdown "$f" -o "${f%.docx}.md"
done
```

## LLM 增强

想让转换结果更干净？可以用 GPT-4 或 Claude 再处理一遍：

```bash
# GPT-4
export OPENAI_API_KEY="你的key"
python SKILL/markdown-everything/scripts/convert_document.py "文档.docx" --llm-client openai --llm-model gpt-4o -o "输出.md"

# Claude
export ANTHROPIC_API_KEY="你的key"
python SKILL/markdown-everything/scripts/convert_document.py "文档.docx" --llm-client anthropic --llm-model claude-3-sonnet -o "输出.md"
```

## 常见问题

**conda 命令找不到** → 装 [Miniconda](https://docs.conda.io/en/latest/miniconda.html)，Windows 用 Anaconda Prompt。

**pip 超时** → 加 `-i https://pypi.tuna.tsinghua.edu.cn/simple`。

**表格转换后乱了** → markitdown 对复杂表格支持有限。用 `--json-output` 拿结构化数据，或者直接用 Excel 打开原文件。

**输出文件乱码** → 输出是 UTF-8。VS Code 打开后选"通过编码重新打开" → UTF-8。

**PowerShell 报错 `&&`** → 改用分号 `;` 连接。

## 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `MARKITDOWN_ENV_NAME` | `markitdown` | Conda 环境名 |
| `MARKITDOWN_PYTHON_VER` | `3.12` | Python 版本 |
| `MARKITDOWN_USE_PIP` | `false` | 设为 `true` 跳过 Conda |
| `OPENAI_API_KEY` | — | GPT-4 增强 |
| `ANTHROPIC_API_KEY` | — | Claude 增强 |

## 参与贡献

Fork → 建分支 → 改 → PR。欢迎 Issue。

## 用到的东西

- [markitdown](https://pypi.org/project/markitdown/) — 核心转换引擎
- [pdfplumber](https://github.com/jsvine/pdfplumber) — PDF 文字提取，解决中文乱码

## 许可证

MIT — 详见 [LICENSE](LICENSE)。

---

项目作者：wokaka209 · [GitHub](https://github.com/wokaka209/markdown_everything)
