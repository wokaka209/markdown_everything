---
name: "markdown_everything"
description: "Converts documents (PDF, DOCX, XLSX, PPTX, images, audio) to Markdown format. Invoke when user asks to convert documents, extract text from files, or transform formats to Markdown."
---

# markdown_everything - 智能文档转换技能

## 简介

这是一个通用的文档格式转换技能，可以将各种常见文档格式一键转换为 Markdown 格式。

## 核心功能

### 1. 文档格式转换

使用 `markitdown` 库实现文档到 Markdown 的转换，支持的格式包括：

- **办公文档**: PDF, Word (`.docx`), PowerPoint (`.pptx`), Excel (`.xlsx`, `.xls`)
- **图片格式**: JPG, PNG, GIF, BMP（可提取图片中的文字和描述）
- **音频文件**: MP3, WAV, OGG, M4A（可提取音频内容）
- **网页格式**: HTML, HTM
- **数据格式**: CSV, JSON, XML
- **其他格式**: EPUB, ZIP

### 2. 智能 PDF 编码处理

对于中文 PDF 文件，系统会自动使用 `pdfplumber` 库的 Unicode 字符级提取技术来解决乱码问题，确保中文内容正确转换。

### 3. 可选 LLM 增强（高级功能）

可以选择集成 OpenAI GPT-4 或 Anthropic Claude 等大语言模型，对转换后的内容进行智能优化和结构化处理。

---

## 使用方法

### 步骤 1：环境准备

**检查并创建 Conda 环境**：

```powershell
# 检查 conda 是否已安装
conda --version

# 创建名为 markitdown 的 Python 3.11 环境（如果不存在）
conda create -n markitdown python=3.11 -y

# 激活环境
conda activate markitdown

# 安装 markitdown 及所有依赖
pip install "markitdown[all]"
```

**国内用户建议使用镜像加速**：

```powershell
# 清华镜像
pip install "markitdown[all]" -i https://pypi.tuna.tsinghua.edu.cn/simple

# 阿里云镜像（推荐）
pip install "markitdown[all]" -i https://mirrors.aliyun.com/pypi/simple/

# 豆瓣镜像
pip install "markitdown[all]" -i https://pypi.doubanio.com/simple/
```

### 步骤 2：执行文档转换

#### 基本用法

```powershell
# 激活 conda 环境
conda activate markitdown

# 转换单个文件（输出到终端）
markitdown "文档路径.docx"

# 转换并保存为指定文件
markitdown "文档路径.pdf" -o "输出路径.md"

# 或者使用完整参数
markitdown "文档路径.docx" --output "输出路径.md"
```

#### 实用示例

```powershell
# 示例 1: 转换 Word 文档
markitdown "C:\Users\用户名\Documents\报告.docx"

# 示例 2: 转换 PDF 并保存
markitdown "C:\Users\用户名\Downloads\论文.pdf" -o "C:\Users\用户名\论文.md"

# 示例 3: 转换 Excel 表格
markitdown "C:\Users\用户名\数据.xlsx" -o "C:\Users\用户名\数据.md"

# 示例 4: 转换 PowerPoint
markitdown "C:\Users\用户名\演示.pptx" -o "C:\Users\用户名\演示.md"

# 示例 5: 批量转换（使用 PowerShell）
Get-ChildItem "C:\Users\用户名\Documents\*.docx" | ForEach-Object {
    markitdown $_.FullName -o "$($_.DirectoryName)\$($_.BaseName).md"
}

# 示例 6: 转换图片（自动识别图片中的文字）
markitdown "C:\Users\用户名\Screenshots\截图.png" -o "C:\Users\用户名\截图内容.md"
```

### 步骤 3：高级选项（可选）

#### 查看支持的所有格式

```powershell
markitdown --list-formats
```

#### 启用详细日志

```powershell
markitdown "文档.docx" --verbose
```

#### 使用 JSON 格式输出（便于程序处理）

```powershell
markitdown "文档.docx" --json-output
```

#### 集成 OpenAI GPT-4 进行智能转换

```powershell
# 需要先安装 OpenAI 库
pip install openai

# 设置环境变量（或者在代码中设置）
$env:OPENAI_API_KEY = "your-api-key"

# 使用 GPT-4 优化转换结果
markitdown "文档.docx" --llm-client openai --llm-model gpt-4o -o "文档.md"
```

#### 集成 Anthropic Claude 进行智能转换

```powershell
# 需要先安装 Anthropic 库
pip install anthropic

# 设置环境变量
$env:ANTHROPIC_API_KEY = "your-api-key"

# 使用 Claude 优化转换结果
markitdown "文档.docx" --llm-client anthropic --llm-model claude-3-sonnet-20240229 -o "文档.md"
```

---

## 常用场景

### 场景 1：处理中文 PDF 论文

```powershell
# 激活环境
conda activate markitdown

# 转换中文 PDF，自动处理乱码问题
markitdown "论文.pdf" -o "论文.md"

# 如果自动处理失败，可以尝试指定 UTF-8 编码
# markitdown "论文.pdf" --encoding utf-8 -o "论文.md"
```

### 场景 2：批量转换文件夹中的所有文档

```powershell
# 激活环境
conda activate markitdown

# PowerShell 批量转换（示例：转换所有 Word 文档）
Get-ChildItem -Path "C:\Users\用户名\Documents" -Filter *.docx | ForEach-Object {
    $outputFile = [System.IO.Path]::Combine($_.DirectoryName, "$($_.BaseName).md")
    markitdown $_.FullName -o $outputFile
    Write-Host "已转换: $($_.Name) -> $($_.BaseName).md"
}
```

### 场景 3：从截图中提取文字

```powershell
# 转换图片为 Markdown
markitdown "截图.png" -o "截图内容.md"
```

### 场景 4：提取音频内容

```powershell
# 转换音频文件的转录内容
markitdown "录音.mp3" -o "录音内容.md"
```

---

## 故障排查

### 问题 1：conda 命令找不到

**解决方案**：
1. 确保已安装 [Miniconda](https://docs.conda.io/en/latest/miniconda.html) 或 Anaconda
2. 重新打开终端或重新加载环境变量
3. Windows 用户可以搜索 "Anaconda Prompt" 打开终端

### 问题 2：安装 markitdown 失败（网络超时）

**解决方案**：
1. 使用国内镜像源（推荐清华或阿里云）
2. 增加超时时间：`pip install --default-timeout=1000 "markitdown[all]"`
3. 检查网络连接，尝试重启路由器

### 问题 3：PDF 中文乱码

**解决方案**：
1. 系统会自动使用 `pdfplumber` 进行 Unicode 字符级提取，大部分情况能自动解决
2. 如果仍有问题，确保安装了 `pdfplumber`：`pip install pdfplumber`
3. 尝试使用 LLM 增强模式来优化内容

### 问题 4：转换失败（文件找不到）

**解决方案**：
1. 检查文件路径是否正确（注意空格和中文路径）
2. 使用绝对路径而不是相对路径
3. 确保文件存在且有读取权限

### 问题 5：输出文件乱码

**解决方案**：
1. 使用 `--verbose` 参数查看详细日志
2. Python 会自动使用 UTF-8 编码写入文件
3. Windows 用户可以用记事本或 VS Code 打开查看（这些编辑器支持 UTF-8）

---

## 技术细节

### 依赖包

- `markitdown[all]`: 核心转换库，包含所有格式支持
- `pdfplumber`: PDF 编码修复（自动安装）
- `openai`: OpenAI GPT 集成（可选）
- `anthropic`: Anthropic Claude 集成（可选）

### 环境要求

- **Python**: 3.11 或更高版本
- **Conda**: Miniconda 或 Anaconda（推荐）
- **操作系统**: Windows / macOS / Linux

### 性能提示

1. **小文件**（< 10MB）：转换速度快，通常几秒内完成
2. **大文件**（> 10MB）：可能需要更长时间，特别是 PDF 文件
3. **批量转换**：建议逐个文件转换，避免内存溢出
4. **图片识别**：带 LLM 增强的图片转换会比较慢，但质量更高

---

## 快速参考卡

### 最常用的命令

```powershell
# 1. 环境设置（仅需执行一次）
conda create -n markitdown python=3.11 -y
conda activate markitdown
pip install "markitdown[all]" -i https://pypi.tuna.tsinghua.edu.cn/simple

# 2. 转换文件（每次使用）
conda activate markitdown
markitdown "文档路径.docx" -o "输出路径.md"
```

### 参数速查

| 参数 | 说明 | 示例 |
|------|------|------|
| `输入文件` | 要转换的文档路径 | `"文档.docx"` |
| `-o` 或 `--output` | 输出 Markdown 文件路径 | `"-o 文档.md"` |
| `--list-formats` | 显示所有支持的格式 | `markitdown --list-formats` |
| `--verbose` | 显示详细日志 | `markitdown --verbose` |
| `--json-output` | JSON 格式输出 | `markitdown --json-output` |
| `--llm-client` | LLM 客户端类型 | `--llm-client openai` |
| `--llm-model` | LLM 模型名称 | `--llm-model gpt-4o` |

---

## 总结

这个技能的核心就是**简单、通用、强大**：

- ✅ **简单**：只需要几行命令就能完成转换
- ✅ **通用**：支持 20+ 种常见文档格式
- ✅ **强大**：自动处理中文 PDF 乱码，可选 LLM 增强

记住这个流程就够了：

```powershell
conda activate markitdown
markitdown "文档路径" -o "输出路径.md"
```

遇到任何问题，就回到这份文档的故障排查部分查找解决方案！
