# markdown_everything.skill

[![](https://img.shields.io/badge/skill-AI%20Agent%20Skill-purple.svg)]() [![](https://img.shields.io/badge/version-v0.0.2-blue.svg)]() [![](https://img.shields.io/badge/license-MIT-green.svg)]() [![](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-green.svg)]() [![](https://img.shields.io/badge/python-3.11%2B-yellow.svg)]() [![](https://img.shields.io/badge/AI%20Agents-Claude%20Code%20%7C%20Cursor%20%7C%20Trae%20%7C%20Obsidian%20YOLO-orange.svg)]()

- ENreadme [English](README_en.md)

将 PDF、Word、Excel、PPT、图片等 20+ 种格式转换为 Markdown，让 AI Agent 能直接读取文档内容。

 ## 项目文件

```
markdown_everything/
├── README.md
├── skill.md
└── scripts/
    ├── manage_environment.ps1     # 环境管理器 (PowerShell)
    ├── manage_environment.sh      # 环境管理器 (Bash)
    ├── convert_document.py        # 核心转换引擎
    ├── pdf_encoding_fixer.py      # PDF 编码修复模块
    └── environment.log            # 操作日志
```

## 核心用途

LLM 处理 PDF、DOCX 等文档时，直接读取 Markdown 效果更好。Markdown 纯文本格式和清晰的结构让 LLM 能准确识别标题层级、表格、列表等元素，避免解析二进制格式丢失信息。

## 支持的文档格式

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
| 视频 | YouTube URL | 字幕提取 |

## 使用方法

调用时提供两个参数：

| 参数 | 说明 | 示例 |
|------|------|------|
| 待读取文档的完整路径 | 需要转换的源文件 | `C:\docs\report.docx` |
| Markdown 保存路径 | 生成的 Markdown 文件存放位置 | `C:\output\report.md` |

## 部署到 AI Agent

将 skill.md 文件添加到 AI Agent 工具后，即可通过自然语言调用。

### 前置要求

- Python 3.11+
- markitdown 库（运行 `pip install markitdown`）
- skill.md 文件

### Claude Code / Claude CLI

1. 创建 `~/.claude/commands/` 目录
2. 将 skill.md 复制到该目录并命名为 `markdown.md`
3. 重启 Claude Code
4. 调用示例：`将 report.docx 转成 Markdown`

### Cursor

在 Agent 配置页面添加自定义命令或脚本路径。

### Trae

进入 Skills 管理页面，添加新技能并复制 skill.md 内容。

### Obsidian YOLO

1. 安装 YOLO 插件
2. 配置本地 LLM 连接
3. 将 skill.md 内容添加到自定义提示中
4. 调用示例：`将当前文档转为 Markdown`

### 验证部署

```
将 C:\docs\report.docx 转换为 Markdown 并保存到桌面
```

AI Agent 正确响应并执行转换，说明部署成功。

## 核心功能

### 技术实现

- 使用 markitdown 作为转换引擎
- 支持中文 PDF Unicode 级别提取
- 自动处理多编码混合文本
- 保留文档结构（标题、列表、表格）
- 图片支持 OCR 文字识别

### 跨平台脚本

| 操作系统 | 脚本 |
|----------|------|
| Windows | PowerShell: `manage_environment.ps1` |
| Linux/macOS | Bash: `manage_environment.sh` |

脚本自动检测 Conda 环境，不存在时使用 pip。

## 调用示例

### Claude Code

```
把 report.docx 转成 Markdown 保存到桌面
```

### Cursor

```
./manage_environment.sh convert -i document.pdf -o output/
```

### Python 调用

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

## 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `MARKITDOWN_ENV_NAME` | `markitdown` | Conda 环境名称 |
| `MARKITDOWN_PYTHON_VER` | `3.12` | Python 版本 |
| `MARKITDOWN_USE_PIP` | `false` | 强制使用 pip |

## 常见问题

### conda not found

Conda 未安装或未添加到 PATH。

```powershell
$env:Path += ";D:\anaconda;D:\anaconda\Scripts"
.\manage_environment.ps1 -Command setup -UsePip
```

### 转换失败

检查文件是否存在：

```powershell
Test-Path "C:\input\document.pdf"
```

## 相关链接

- MarkItDown: https://pypi.org/project/markitdown/
- Conda: https://docs.conda.io/

---

License: MIT
