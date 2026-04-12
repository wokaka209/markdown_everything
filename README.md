# markdown_everything.skill

[![](https://img.shields.io/badge/skill-AI%20Agent%20Skill-purple.svg)]() [![](https://img.shields.io/badge/version-v0.0.1-blue.svg)]() [![](https://img.shields.io/badge/license-MIT-green.svg)]() [![](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-green.svg)]() [![](https://img.shields.io/badge/python-3.11%2B-yellow.svg)]() [![](https://img.shields.io/badge/AI%20Agents-Claude%20Code%20%7C%20Cursor%20%7C%20Trae%20%7C%20Solo%20%7C%20WorkBuddy%20%7C%20Qoder-orange.svg)]()

文档格式转换工具，支持将 PDF、Word、Excel、PPT、图片等 20+ 种格式转换为 Markdown 格式，帮助 LLM 更好地理解和处理文档内容。

## 核心使用场景

这个技能的核心用途是：**将 docx、PDF 等文档转换为 Markdown 格式，帮助 LLM 更好地理解和处理文档内容**。

LLM 在处理结构化文档时，直接读取 Markdown 比读取 docx、PDF 等二进制格式效果更好。Markdown 的纯文本格式和清晰的结构让 LLM 能够准确识别标题层级、表格、列表等元素，避免解析格式丢失信息的问题。

### 使用方法

在调用此技能时，**必须**提供两个关键信息：

| 参数 | 说明 | 示例 |
|------|------|------|
| 待读取文档的完整路径 | 需要转换的源文件 | `C:\docs\report.docx` |
| Markdown 保存路径 | 生成的 Markdown 文件存放位置 | `C:\output\report.md` |

### 项目文件

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

### 实际应用情况

已在以下平台验证可用：

- **Claude Code** - 通过 MCP 工具或自定义工具调用
- **Cursor** - Agent 模式下执行 shell 命令
- **Trae** - 通过 skill 机制加载，支持直接调用
- **Solo** - 通过 Shell 命令执行
- **WorkBuddy** - 通过命令行接口调用
- **Obsidian YOLO** - Obsidian 插件，可在笔记中调用本地 LLM

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

## 部署到 AI Agent

将 skill.md 文件添加到 AI Agent 工具后，即可通过自然语言调用此技能。

### 前置要求

- 已安装 Python 3.11+
- 已安装 markitdown 库（运行 `pip install markitdown`）
- skill.md 文件（位于本项目根目录）

### Claude Code / Claude CLI 部署步骤

1. 在 Claude Code 配置目录创建 `~/.claude/commands/` 文件夹
2. 将 skill.md 复制到该目录并命名为 `markdown.md`
3. 重启 Claude Code
4. 通过自然语言调用：`将 report.docx 转成 Markdown`

### Cursor 部署步骤

1. 打开 Cursor 设置
2. 进入 Agent 配置页面
3. 添加自定义命令或脚本路径
4. 配置 markitdown 调用方式
5. 重启 Cursor

### Trae 部署步骤

1. 打开 Trae 设置
2. 进入 Skills 或技能管理页面
3. 点击添加新技能
4. 复制 skill.md 文件内容到技能配置中
5. 保存并重启 Trae

### Solo 部署步骤

1. 打开 Solo 配置目录
2. 找到 skills 或自定义技能文件夹
3. 将 skill.md 复制到该目录
4. 重启 Solo 使配置生效

### WorkBuddy 部署步骤

1. 进入 WorkBuddy 设置
2. 找到工具扩展或插件管理
3. 选择导入自定义技能
4. 上传 skill.md 文件
5. 确认导入成功

### Obsidian YOLO 部署步骤

1. 在 Obsidian 中安装 YOLO 插件
2. 配置本地 LLM 连接
3. 将 skill.md 内容添加到 YOLO 的自定义提示中
4. 在笔记中直接调用：`将当前文档转为 Markdown`

### 验证部署

部署完成后，尝试用以下方式调用：

```
将 C:\docs\report.docx 转换为 Markdown 并保存到桌面
```

如果 AI Agent 正确响应并执行转换，说明部署成功。

### 常见问题

**技能无法识别**：检查 skill.md 文件格式是否正确，确保文件保存为 UTF-8 编码。

**转换失败**：确认已安装 markitdown 库，可运行 `pip show markitdown` 检查。

## 支持的 AI Agent 平台

| 平台 | 集成方式 |
|------|----------|
| Claude Code | 通过自定义工具调用 |
| Cursor | Agent 模式下执行 shell 命令 |
| Trae | skill 机制或直接调用脚本 |
| Solo | Shell 命令执行 |
| WorkBuddy | 命令行接口调用 |
| Qoder | 脚本路径集成 |

## 核心功能

### 解决 LLM 读取文档的痛点

当 AI Agent 需要处理 PDF、DOCX、XLSX 等文档时，往往遇到格式识别不准、表格结构丢失、图片内容无法理解等问题。这个 skill 把文档转成纯文本 Markdown，让 LLM 直接读文本，避免解析二进制格式的各种坑。

工作流程很简单：

1. 用户提供文档路径
2. Skill 调用 markitdown 转成 Markdown
3. LLM 直接读取 Markdown 纯文本
4. 输出结构清晰的结果

### 支持的格式

- PDF、DOCX、XLSX、PPTX、EPUB 等常见格式
- 自动提取标题层级、表格、代码块、图片
- 图片支持 OCR 文字识别
- 中文 PDF 自动修复编码问题

### 技术细节

- 使用 markitdown 作为转换引擎
- 支持中文 PDF Unicode 级别提取
- 自动处理多编码混合文本
- 保留文档结构（标题、列表、表格）

### 跨平台脚本

| 操作系统 | 脚本 |
|----------|------|
| Windows | PowerShell: `manage_environment.ps1` |
| Linux/macOS | Bash: `manage_environment.sh` |

脚本自动检测 Conda 环境，不行就切 pip。

## 调用示例

### Claude Code

在 Claude Code 中可以直接说：

```
把 report.docx 转成 Markdown 保存到桌面
```

### Cursor

Cursor Agent 模式下调用：

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
# 手动添加 Conda 到 PATH
$env:Path += ";D:\anaconda;D:\anaconda\Scripts"

# 或者使用 pip
.\manage_environment.ps1 -Command setup -UsePip
```

### 转换失败

检查文件是否存在：

```powershell
Test-Path "C:\input\document.pdf"
```

## 版本信息

- 当前版本: v0.0.1
- Python 版本: 3.11+
- 依赖: markitdown[all]

## 相关链接

- MarkItDown: https://pypi.org/project/markitdown/
- Conda: https://docs.conda.io/

---

License: MIT
