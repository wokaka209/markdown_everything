# markdown_everything.skill

[![skill-AI-Agent](https://img.shields.io/badge/skill-AI%20Agent%20Skill-purple.svg)]() 
[![version-v0.0.3](https://img.shields.io/badge/version-v0.0.3-blue.svg)](https://github.com/wokaka209/markdown_everything)
[![license-MIT](https://img.shields.io/badge/license-MIT-green.svg)]() 
[![platform-WindowsOS](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-green.svg)]()
[![python-3.11](https://img.shields.io/badge/python-3.11%2B-yellow.svg)](https://www.python.org/downloads/release/python-3111/) 
[![AI-Agents](https://img.shields.io/badge/AI%20Agents-Claude%20Code%20%7C%20Cursor%20%7C%20Trae%20%7C%20Obsidian%20YOLO-orange.svg)]() 
[![made-with-markdown](https://img.shields.io/badge/Made%20with-Markitdown-orange)](https://github.com/microsoft/markitdown)

- 中文文档 [简体中文](README.md)

[Project Files](#project-files) · [Core Purpose](#core-purpose) · [Usage](#usage) · [Prerequisites](#prerequisites)

Convert PDF, Word, Excel, PPT, images and 20+ other formats to Markdown, enabling AI Agents to read document content directly.

## Project Files

```
markdown_everything/
├── README.md
├── skill.md
└── scripts/
    ├── manage_environment.ps1     # Environment manager (PowerShell)
    ├── manage_environment.sh      # Environment manager (Bash)
    ├── convert_document.py        # Core conversion engine
    ├── pdf_encoding_fixer.py      # PDF encoding fix module
    └── environment.log            # Operation log
```

## Core Purpose

When LLMs process documents like PDFs and DOCX files, reading Markdown directly produces better results. Markdown's plain text format and clear structure allow LLMs to accurately identify heading levels, tables, lists, and other elements, avoiding information loss from parsing binary formats.

## Supported Document Formats

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
| Video | YouTube URL | Subtitle extraction |

## Usage

Provide two parameters when calling:

| Parameter | Description | Example |
|----------|-------------|---------|
| Full path to document | Source file to convert | `C:\docs\report.docx` |
| Markdown save path | Where to save the output | `C:\output\report.md` |

## Deploy to AI Agent

Add the skill.md file to your AI Agent tools, then call it using natural language.

### Prerequisites

- Python 3.11+
- markitdown library (run `pip install markitdown`)
- skill.md file

### Claude Code / Claude CLI

1. Create the `~/.claude/commands/` directory
2. Copy skill.md to that directory and name it `markdown.md`
3. Restart Claude Code
4. Example usage: `convert report.docx to Markdown`

### Cursor

Add custom commands or script paths in the Agent configuration page.

### Trae

Go to the Skills management page, add a new skill, and paste the skill.md content.

### Obsidian YOLO

1. Install the YOLO plugin
2. Configure local LLM connection
3. Add skill.md content to custom prompts
4. Example usage: `convert current document to Markdown`

### Verify Deployment

```
Convert C:\docs\report.docx to Markdown and save to desktop
```

If the AI Agent responds correctly and executes the conversion, deployment is successful.

## Core Features

### Technical Implementation

- Uses markitdown as the conversion engine
- Supports Chinese PDF Unicode-level extraction
- Automatically handles mixed encoding text
- Preserves document structure (headings, lists, tables)
- Images support OCR text recognition

### Cross-Platform Scripts

| Operating System | Script |
|----------|--------|
| Windows | PowerShell: `manage_environment.ps1` |
| Linux/macOS | Bash: `manage_environment.sh` |

Scripts automatically detect Conda environments and fall back to pip when not available.

## Usage Examples

### Claude Code

```
convert report.docx to Markdown and save to desktop
```

### Cursor

```
./manage_environment.sh convert -i document.pdf -o output/
```

### Python Integration

```python
import subprocess

def convert_document(input_file, output_dir):
    cmd = [
        "powershell", "-File",
        "scripts/manage_environment.ps1",
        "-Command", "convert",
        "-InputFile", input_file,
        "-OutputDir", output_dir
    ]
    return subprocess.run(cmd, capture_output=True, text=True)
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MARKITDOWN_ENV_NAME` | `markitdown` | Conda environment name |
| `MARKITDOWN_PYTHON_VER` | `3.12` | Python version |
| `MARKITDOWN_USE_PIP` | `false` | Force pip usage |

## FAQ

### conda not found

Conda is not installed or not added to PATH.

```powershell
$env:Path += ";D:\anaconda;D:\anaconda\Scripts"
.\manage_environment.ps1 -Command setup -UsePip
```

### Conversion failed

Check if the file exists:

```powershell
Test-Path "C:\input\document.pdf"
```

## Related Links

- MarkItDown: https://pypi.org/project/markitdown/
- Conda: https://docs.conda.io/

---

License: MIT
