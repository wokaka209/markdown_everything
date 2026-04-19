# markdown-everything

[![skill-AI-Agent](https://img.shields.io/badge/skill-AI%20Agent%20Skill-purple.svg)]()
[![version-v1.0.0](https://img.shields.io/badge/version-v1.0.0-blue.svg)](https://github.com/wokaka209/markdown_everything)
[![license-MIT](https://img.shields.io/badge/license-MIT-green.svg)]()
[![platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-green.svg)]()
[![python-3.11](https://img.shields.io/badge/python-3.11%2B-yellow.svg)]()
[![AI-Agents](https://img.shields.io/badge/AI%20Agents-Codex%20%7C%20Claude%20Code%20%7C%20Cursor%20%7C%20Trae-orange.svg)]()
[![made-with-markitdown](https://img.shields.io/badge/Made%20with-Markitdown-orange)](https://github.com/microsoft/markitdown)

[简体中文](README.md)

Convert PDF, Word, Excel, PPT, images, audio and 20+ other formats to Markdown, enabling AI Agents to read document content directly.

## Quick Start

```bash
pip install "markitdown[all]"
markitdown "document.pdf" -o "output.md"
```

## Supported Formats

| Category | Format | Description |
|----------|--------|-------------|
| Documents | `.pdf` `.docx` `.doc` | PDF, Word documents |
| Spreadsheets | `.xlsx` `.xls` `.csv` | Excel, CSV spreadsheets |
| Presentations | `.pptx` `.ppt` | PowerPoint slides |
| Images | `.jpg` `.png` `.gif` `.bmp` | Image text recognition (OCR) |
| Audio | `.mp3` `.wav` `.ogg` `.m4a` | Speech to text |
| Web | `.html` `.htm` | HTML source extraction |
| Data | `.json` `.xml` | Structured data conversion |
| eBooks | `.epub` `.azw3` | eBook formats |
| Archives | `.zip` | Batch document processing |

## Key Features

- **Chinese PDF Fix** — Automatically uses `pdfplumber` Unicode-level character extraction to resolve Chinese PDF encoding issues
- **Environment Management** — Cross-platform scripts auto-detect Conda/pip, one-click setup
- **LLM Enhancement** — Optional integration with OpenAI/Anthropic for intelligent optimization
- **Agent Skills Standard** — Compliant with the [Agent Skills Open Standard](https://agentskills.io), compatible with Codex, Claude Code, and more

## Project Structure

```
SKILL/markdown-everything/
├── SKILL.md                      # Skill definition (Agent Skills standard)
└── scripts/
    ├── convert_document.py        # Core conversion engine
    ├── pdf_encoding_fixer.py      # PDF encoding fix module
    ├── manage_environment.ps1     # Windows environment manager
    └── manage_environment.sh      # Linux/macOS environment manager
```

## Installation

### Option 1: pip (Recommended)

```bash
pip install "markitdown[all]"
pip install pdfplumber
```

### Option 2: Conda

```bash
conda create -n markitdown python=3.12 -y
conda activate markitdown
pip install "markitdown[all]"
pip install pdfplumber
```

### Option 3: Environment Manager Script

```powershell
# Windows
.\SKILL\markdown-everything\scripts\manage_environment.ps1 -Command setup

# Linux/macOS
bash SKILL/markdown-everything/scripts/manage_environment.sh setup
```

Use a mirror for faster downloads in China:

```bash
pip install "markitdown[all]" -i https://pypi.tuna.tsinghua.edu.cn/simple
```

## Usage

### Command Line

```bash
# Convert and save
markitdown "document.pdf" -o "output.md"

# Using Python script (supports PDF encoding fix and LLM enhancement)
python SKILL/markdown-everything/scripts/convert_document.py "document.pdf" -o "output.md"
```

### Windows PowerShell Note

PowerShell does not support `&&` for chaining commands. Use semicolons `;` or separate lines:

```powershell
# Correct: semicolon
conda activate markitdown; markitdown "document.pdf" -o "output.md"

# Correct: separate lines
conda activate markitdown
markitdown "document.pdf" -o "output.md"

# Wrong: && not available in some PowerShell versions
conda activate markitdown && markitdown "document.pdf" -o "output.md"
```

### Advanced Options

```bash
# JSON output
python scripts/convert_document.py "document.docx" --json-output

# Verbose logging
python scripts/convert_document.py "document.docx" --verbose

# LLM enhancement
python scripts/convert_document.py "document.docx" --llm-client openai --llm-model gpt-4o -o "output.md"
```

### Batch Conversion

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

## Deploy to AI Agent

### OpenAI Codex

```bash
# Install skill to Codex skills directory
$skill-installer install https://github.com/wokaka209/markdown_everything/tree/main/SKILL/markdown-everything
```

Or manually copy `SKILL/markdown-everything/` to `~/.codex/skills/markdown-everything/`.

### Claude Code

```bash
# Option 1: Skills format (recommended, supports auto-triggering)
cp -r SKILL/markdown-everything ~/.claude/skills/markdown-everything

# Option 2: Commands format (manual trigger only)
mkdir -p ~/.claude/commands
cp SKILL/markdown-everything/SKILL.md ~/.claude/commands/markdown.md
```

### Cursor / Trae / Obsidian YOLO

Add custom commands or script paths in the Agent configuration page.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MARKITDOWN_ENV_NAME` | `markitdown` | Conda environment name |
| `MARKITDOWN_PYTHON_VER` | `3.12` | Python version for Conda env |
| `MARKITDOWN_USE_PIP` | `false` | Set to `true` to skip Conda and use system pip |
| `MARKITDOWN_PIP_MIRROR` | `default` | pip mirror source (tsinghua/aliyun/douban/custom) |
| `MARKITDOWN_CUSTOM_MIRROR` | — | Custom pip mirror URL |
| `OPENAI_API_KEY` | — | GPT-4 enhanced conversion (optional) |
| `ANTHROPIC_API_KEY` | — | Claude enhanced conversion (optional) |

## FAQ

| Issue | Solution |
|-------|----------|
| conda command not found | Install [Miniconda](https://docs.conda.io/en/latest/miniconda.html); Windows users use Anaconda Prompt |
| pip install timeout | Use mirror: `pip install "markitdown[all]" -i https://pypi.tuna.tsinghua.edu.cn/simple` |
| Chinese PDF garbled text | Ensure pdfplumber is installed: `pip install pdfplumber` |
| Output file garbled | Output is UTF-8, open with VS Code |
| PowerShell doesn't support `&&` | Use semicolons `;` to chain commands, or separate lines |

## Related Links

- MarkItDown: https://pypi.org/project/markitdown/
- Agent Skills Standard: https://agentskills.io/
- Conda: https://docs.conda.io/

---

License: MIT
