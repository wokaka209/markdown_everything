English | **[中文版](README.md)**

# markdown-everything

![Python](https://img.shields.io/badge/Python-3.11+-3776AB?style=flat-square&logo=python&logoColor=fff)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-0A0A0A?style=flat-square)

Drop in a PDF, Word doc, spreadsheet, slide deck, image, or audio file — get clean Markdown out. Built for AI Agents that need to read documents directly.

## Table of Contents

- [What is this](#what-is-this)
- [Getting started](#getting-started)
- [Supported formats](#supported-formats)
- [Usage](#usage)
- [Chinese PDF handling](#chinese-pdf-handling)
- [Batch conversion](#batch-conversion)
- [LLM enhancement](#llm-enhancement)
- [Troubleshooting](#troubleshooting)
- [Environment variables](#environment-variables)
- [Contributing](#contributing)
- [Built with](#built-with)
- [License](#license)

## What is this

A document conversion tool. Uses markitdown under the hood, with pdfplumber for proper Unicode extraction from Chinese PDFs (no more garbled text).

Tell your AI Agent "convert this docx to Markdown" and it handles the rest. No commands to memorize.

## Getting started

```bash
pip install "markitdown[all]" pdfplumber
```

If pip is slow in your region, use a mirror:

```bash
pip install "markitdown[all]" pdfplumber -i https://pypi.tuna.tsinghua.edu.cn/simple
```

Conda works too:

```bash
conda create -n markitdown python=3.12 -y
conda activate markitdown
pip install "markitdown[all]" pdfplumber
```

That's it. Ready to go.

## Supported formats

**Documents**: `.pdf` `.docx` `.doc` `.pptx` `.ppt` `.xlsx` `.xls` `.csv`

**Images** (OCR): `.jpg` `.png` `.gif` `.bmp`

**Audio**: `.mp3` `.wav` `.ogg` `.m4a`

**Web/Data**: `.html` `.htm` `.json` `.xml`

**eBooks**: `.epub` `.azw3`

## Usage

The easiest way — just tell your AI Agent what to convert:

```
Convert weekly-report.docx to Markdown
```

Or use the CLI:

```bash
markitdown document.pdf -o output.md
```

**Windows PowerShell note**: Don't chain commands with `&&`. Use semicolons `;` or separate lines:

```powershell
# Works
conda activate markitdown; markitdown "doc.pdf" -o "output.md"

# Breaks
conda activate markitdown && markitdown "doc.pdf" -o "output.md"
```

## Chinese PDF handling

Garbled Chinese text in PDFs? Install pdfplumber:

```bash
pip install pdfplumber
```

The tool automatically uses pdfplumber for character-level extraction. Falls back to standard markitdown if that fails.

## Batch conversion

**PowerShell**:

```powershell
Get-ChildItem "C:\Docs\*.docx" | ForEach-Object {
    markitdown $_.FullName -o "$($_.DirectoryName)\$($_.BaseName).md"
}
```

**Linux / macOS**:

```bash
for f in /path/to/docs/*.docx; do
    markitdown "$f" -o "${f%.docx}.md"
done
```

## LLM enhancement

Want cleaner output? Run it through GPT-4 or Claude first:

```bash
# GPT-4
export OPENAI_API_KEY="your-key"
python SKILL/markdown-everything/scripts/convert_document.py "doc.docx" --llm-client openai --llm-model gpt-4o -o "output.md"

# Claude
export ANTHROPIC_API_KEY="your-key"
python SKILL/markdown-everything/scripts/convert_document.py "doc.docx" --llm-client anthropic --llm-model claude-3-sonnet -o "output.md"
```

## Troubleshooting

**conda not found** → Install [Miniconda](https://docs.conda.io/en/latest/miniconda.html). Windows users: use Anaconda Prompt.

**pip timeout** → Add `-i https://pypi.tuna.tsinghua.edu.cn/simple`.

**Tables look broken** → markitdown has limited support for complex tables. Try `--json-output` for structured data, or open the original in Excel.

**Output file garbled** → Output is UTF-8. In VS Code, use "Reopen with Encoding" → UTF-8.

**PowerShell `&&` error** → Use semicolons `;` instead.

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MARKITDOWN_ENV_NAME` | `markitdown` | Conda environment name |
| `MARKITDOWN_PYTHON_VER` | `3.12` | Python version |
| `MARKITDOWN_USE_PIP` | `false` | Set `true` to skip Conda |
| `OPENAI_API_KEY` | — | GPT-4 enhancement |
| `ANTHROPIC_API_KEY` | — | Claude enhancement |

## Contributing

Fork → branch → fix → PR. Issues welcome.

## Built with

- [markitdown](https://pypi.org/project/markitdown/) — core conversion engine
- [pdfplumber](https://github.com/jsvine/pdfplumber) — PDF text extraction, fixes Chinese encoding

## License

MIT — see [LICENSE](LICENSE).

---

Author: wokaka209 · [GitHub](https://github.com/wokaka209/markdown_everything)
