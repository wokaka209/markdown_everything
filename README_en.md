# markdown-everything

[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://mit-license.org/zh-CN)
[![Python](https://img.shields.io/badge/python-3.11%2B-yellow.svg)](https://www.python.org/downloads/release/python-3110/)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-green.svg)]()

[English](README_en.md) | [简体中文](#功能说明)

markdown-everything converts various document formats to Markdown, enabling AI Agents to read document content directly.

---

## Project Structure

```
markdown-everything/
├── README.md                      # Project documentation
├── README_en.md                  # English documentation
├── SKILL.md                      # AI Agent Skill configuration
└── scripts/
    ├── convert_document.py        # Conversion engine
    ├── pdf_encoding_fixer.py       # PDF encoding handler
    ├── manage_environment.ps1       # Windows environment manager
    └── manage_environment.sh        # Linux/macOS environment manager
```

---

## Features

This tool handles the following document types:

- PDF documents (including Chinese PDFs)
- Word documents (docx, doc)
- Excel spreadsheets (xlsx, xls, csv)
- PowerPoint presentations (pptx, ppt)
- Text extraction from images (OCR)
- Audio transcription
- Web content extraction
- JSON, XML and other data files
- eBook formats (epub, azw3)

---

## Environment Setup

### System Requirements

- Python 3.11 or higher
- pip package manager (or conda)

### Dependency Installation

Install core dependencies with pip:

```bash
pip install "markitdown[all]"
pip install pdfplumber
```

Use China mirror (recommended):

```bash
pip install "markitdown[all]" -i https://pypi.tuna.tsinghua.edu.cn/simple
pip install pdfplumber -i https://pypi.tuna.tsinghua.edu.cn/simple
```

Optional dependencies for LLM enhancement:

```bash
pip install openai      # GPT-4 enhancement
pip install anthropic   # Claude enhancement
```

### Conda Environment Setup

```bash
conda create -n markitdown python=3.11 -y
conda activate markitdown
pip install "markitdown[all]"
pip install pdfplumber
```

---

## Usage

### Using with AI Agent

When you need the AI Agent to process a document, simply state your requirement:

```
Convert weekly-report.docx to Markdown format
AI Agent will automatically call markitdown for conversion
```

Supported trigger methods:

1. Direct description: Convert this document for me
2. Specify format: Convert to Markdown
3. Batch processing: Convert all documents in the directory

### Command Line Usage

```bash
markitdown document.pdf -o output.md
```

---

## Advanced Features

### Chinese PDF Processing

If Chinese text in PDFs appears garbled, ensure pdfplumber is installed:

```bash
pip install pdfplumber
```

### LLM Enhancement

Enable GPT-4 optimization:

```bash
export OPENAI_API_KEY="your-api-key"
python scripts/convert_document.py "document.docx" --llm-client openai --llm-model gpt-4o -o "output.md"
```

Enable Claude optimization:

```bash
export ANTHROPIC_API_KEY="your-api-key"
python scripts/convert_document.py "document.docx" --llm-client anthropic --llm-model claude-3-sonnet -o "output.md"
```

### Batch Conversion

PowerShell batch conversion:

```powershell
Get-ChildItem "C:\Documents\*.docx" | ForEach-Object {
    markitdown $_.FullName -o "$($_.DirectoryName)\$($_.BaseName).md"
}
```

Linux/macOS batch conversion:

```bash
for f in /path/to/docs/*.docx; do
    markitdown "$f" -o "${f%.docx}.md"
done
```

---

## Common Parameters

| Parameter | Description |
|-----------|-------------|
| -o, --output | Specify output file path |
| --list-formats | List all supported formats |
| --verbose | Show detailed execution information |
| --json-output | Output in JSON format |
| --llm-client | Select LLM client (openai/anthropic) |
| --llm-model | Specify LLM model |

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| MARKDOWN_ENV_NAME | markitdown | Conda environment name |
| MARKDOWN_PYTHON_VER | 3.12 | Python version |
| MARKDOWN_USE_PIP | false | Set to true to skip Conda |
| MARKDOWN_PIP_MIRROR | default | pip mirror source |
| OPENAI_API_KEY | - | GPT-4 API key |
| ANTHROPIC_API_KEY | - | Claude API key |

---

## Troubleshooting

### conda command not found

Install Miniconda: https://docs.conda.io/en/latest/miniconda.html
Windows users should use Anaconda Prompt to execute commands.

### pip installation fails

Use a mirror source:

```bash
pip install markitdown[all] -i https://pypi.tuna.tsinghua.edu.cn/simple
```

### Chinese PDF garbled

Install pdfplumber:

```bash
pip install pdfplumber
```

### Output file garbled

markitdown outputs UTF-8 encoding. Open the file with VS Code, select "Reopen with Encoding" and choose UTF-8.

---

## Contributing

Contributions are welcome! Please feel free to submit Issues and Pull Requests.

1. Fork the repository
2. Create your feature branch (git checkout -b feature/AmazingFeature)
3. Commit your changes (git commit -m 'Add some AmazingFeature')
4. Push to the branch (git push origin feature/AmazingFeature)
5. Open a Pull Request

---

## Resources

- markitdown project: https://pypi.org/project/markitdown/
- Agent Skills standard: https://agentskills.io/
- Conda documentation: https://docs.conda.io/

---

## License

This project is licensed under the MIT License - see the LICENSE file for details

---

## Contact

Project author: wokaka209
Project URL: https://github.com/wokaka209/markdown_everything

[Back to Top](#markdown-everything)
