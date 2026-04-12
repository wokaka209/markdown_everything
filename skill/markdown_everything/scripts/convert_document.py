"""
MarkItDown Document Converter
将各种文档格式转换为 Markdown
支持PDF中文编码自动修复
"""

import sys
import os
import argparse
import logging
import re
from pathlib import Path
from typing import Optional
import json

try:
    from markitdown import MarkItDown
except ImportError:
    print("Error: markitdown is not installed. Please run setup_environment.ps1 first.")
    sys.exit(1)


logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class DocumentConverter:
    """文档转换器类"""

    def __init__(self, llm_client=None, llm_model=None, llm_prompt=None, enable_plugins=False):
        """
        初始化文档转换器

        Args:
            llm_client: LLM 客户端实例（如 OpenAI）
            llm_model: LLM 模型名称
            llm_prompt: 自定义 LLM 提示词
            enable_plugins: 是否启用插件
        """
        self.llm_client = llm_client
        self.llm_model = llm_model
        self.llm_prompt = llm_prompt
        self.enable_plugins = enable_plugins
        self.markitdown = None

    def initialize(self):
        """初始化 MarkItDown 实例"""
        try:
            self.markitdown = MarkItDown(
                enable_plugins=self.enable_plugins,
                llm_client=self.llm_client,
                llm_model=self.llm_model,
                llm_prompt=self.llm_prompt
            )
            logger.info("MarkItDown initialized successfully")
            return True
        except Exception as e:
            logger.error(f"Failed to initialize MarkItDown: {e}")
            return False

    def convert(self, input_path: str, output_path: Optional[str] = None) -> dict:
        """
        转换文档

        Args:
            input_path: 输入文件路径
            output_path: 输出文件路径（可选）

        Returns:
            dict: 包含成功状态、Markdown 内容和可选的输出文件路径
        """
        if not self.markitdown:
            if not self.initialize():
                return {
                    'success': False,
                    'error': 'Failed to initialize MarkItDown',
                    'text_content': None,
                    'output_file': None
                }

        if not os.path.exists(input_path):
            return {
                'success': False,
                'error': f'File not found: {input_path}',
                'text_content': None,
                'output_file': None
            }

        try:
            logger.info(f"Converting document: {input_path}")
            result = self.markitdown.convert(input_path)

            text_content = result.text_content

            if output_path:
                output_file = Path(output_path)
                output_file.parent.mkdir(parents=True, exist_ok=True)
                output_file.write_text(text_content, encoding='utf-8')
                logger.info(f"Output written to: {output_path}")

                return {
                    'success': True,
                    'error': None,
                    'text_content': text_content,
                    'output_file': str(output_file.absolute())
                }
            else:
                return {
                    'success': True,
                    'error': None,
                    'text_content': text_content,
                    'output_file': None
                }

        except Exception as e:
            logger.error(f"Conversion failed: {e}")
            return {
                'success': False,
                'error': str(e),
                'text_content': None,
                'output_file': None
            }

    def get_supported_formats(self) -> list:
        """获取支持的文档格式列表"""
        return [
            '.pdf', '.pptx', '.docx', '.xlsx', '.xls',
            '.jpg', '.jpeg', '.png', '.gif', '.bmp',
            '.mp3', '.wav', '.ogg', '.m4a',
            '.html', '.htm',
            '.csv', '.json', '.xml',
            '.zip',
            '.epub'
        ]


class PDFEncodingFixer:
    """
    PDF编码修复器 - 解决中文PDF乱码问题
    使用pdfplumber的字符级提取，直接获取Unicode字符
    """

    def __init__(self):
        self.name = "pdfplumber_unicode"

    @staticmethod
    def is_available() -> bool:
        """检查pdfplumber是否可用"""
        try:
            import pdfplumber
            return True
        except ImportError:
            return False

    @staticmethod
    def _detect_text_quality(text: str) -> dict:
        """检测文本质量"""
        if not text:
            return {'is_garbled': True, 'chinese_ratio': 0.0}

        replacement_char = '\ufffd'
        replacement_count = text.count(replacement_char)
        chinese_chars = len(re.findall(r'[\u4e00-\u9fff\u3400-\u4dbf]', text))
        total_chars = len(text)

        chinese_ratio = chinese_chars / total_chars if total_chars > 0 else 0.0
        replacement_ratio = replacement_count / total_chars if total_chars > 0 else 0.0

        is_garbled = replacement_ratio > 0.01 or (chinese_ratio < 0.1 and '?' in text)

        return {
            'is_garbled': is_garbled,
            'chinese_ratio': chinese_ratio,
            'replacement_ratio': replacement_ratio
        }

    @staticmethod
    def _extract_chars_unicode(pdf_path: str) -> tuple:
        """
        使用pdfplumber的chars对象提取Unicode文本
        关键：直接从字符对象获取unicode字段，绕过编码问题
        """
        import pdfplumber

        try:
            full_text = ""

            with pdfplumber.open(pdf_path) as pdf:
                for page_num, page in enumerate(pdf.pages):
                    chars = page.chars

                    if not chars:
                        text = page.extract_text()
                        if text:
                            full_text += f"\n\n## Page {page_num + 1}\n\n{text}"
                        continue

                    text_parts = []
                    current_text = ""
                    last_bottom = None

                    sorted_chars = sorted(
                        chars,
                        key=lambda c: (round(c.get('bottom', 0), 1), c.get('x0', 0))
                    )

                    for char in sorted_chars:
                        char_bottom = round(char.get('bottom', 0), 1)

                        if last_bottom is not None and abs(char_bottom - last_bottom) > 5:
                            if current_text.strip():
                                text_parts.append(current_text.strip())
                            current_text = ""

                        char_unicode = char.get('unicode', '')
                        if char_unicode:
                            current_text += char_unicode
                        else:
                            current_text += char.get('text', '')

                        last_bottom = char_bottom

                    if current_text.strip():
                        text_parts.append(current_text.strip())

                    page_text = '\n'.join(text_parts)
                    if page_text.strip():
                        full_text += f"\n\n## Page {page_num + 1}\n\n{page_text.strip()}"

            return True, full_text.strip()

        except Exception as e:
            logger.error(f"pdfplumber chars extraction failed: {e}")
            return False, str(e)

    @staticmethod
    def _clean_text(text: str) -> str:
        """清理提取的文本"""
        text = re.sub(r'\n{3,}', '\n\n', text)
        text = re.sub(r'[ \t]+', ' ', text)
        text = re.sub(r'([。！？；])\n([A-Za-z\u4e00-\u9fff])', r'\1\2', text)
        return text.strip()

    def convert(self, pdf_path: str) -> dict:
        """
        转换PDF文件，优先使用Unicode字符级提取

        Args:
            pdf_path: PDF文件路径

        Returns:
            dict: 包含success, text_content, method等信息
        """
        if not os.path.exists(pdf_path):
            return {
                'success': False,
                'error': f'File not found: {pdf_path}',
                'text_content': '',
                'method': 'none'
            }

        logger.info(f"使用pdfplumber Unicode级提取转换PDF: {pdf_path}")

        success, text = self._extract_chars_unicode(pdf_path)

        if not success:
            logger.warning("Unicode级提取失败")
            return {
                'success': False,
                'error': text,
                'text_content': '',
                'method': 'failed'
            }

        quality = self._detect_text_quality(text)
        logger.info(f"文本质量 - 乱码: {quality['is_garbled']}, "
                   f"中文比例: {quality['chinese_ratio']:.2%}")

        cleaned_text = self._clean_text(text)

        return {
            'success': True,
            'text_content': cleaned_text,
            'method': 'pdfplumber_unicode',
            'quality': quality
        }


def parse_arguments():
    """解析命令行参数"""
    parser = argparse.ArgumentParser(
        description='将各种文档格式转换为 Markdown',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  %(prog)s document.pdf
  %(prog)s document.pdf -o output.md
  %(prog)s document.docx --output result.md
  %(prog)s image.png --llm-model gpt-4o

支持的格式:
  PDF, PowerPoint, Word, Excel, 图片, 音频, HTML, CSV, JSON, XML, ZIP, EPUB
        """
    )

    parser.add_argument(
        'input_file',
        nargs='?',
        help='要转换的输入文件路径'
    )

    parser.add_argument(
        '-o', '--output',
        dest='output_file',
        help='输出 Markdown 文件路径'
    )

    parser.add_argument(
        '--llm-client',
        help='LLM 客户端类型 (openai, anthropic, 等)'
    )

    parser.add_argument(
        '--llm-model',
        help='LLM 模型名称 (如 gpt-4o, claude-3)'
    )

    parser.add_argument(
        '--llm-prompt',
        help='LLM 自定义提示词'
    )

    parser.add_argument(
        '--enable-plugins',
        action='store_true',
        help='启用插件支持'
    )

    parser.add_argument(
        '--list-formats',
        action='store_true',
        help='列出所有支持的文档格式'
    )

    parser.add_argument(
        '--json-output',
        action='store_true',
        help='以 JSON 格式输出结果'
    )

    parser.add_argument(
        '--verbose',
        action='store_true',
        help='显示详细日志信息'
    )

    return parser.parse_args()


def setup_llm_client(client_type: str, model: str, prompt: str):
    """设置 LLM 客户端"""
    if not client_type:
        return None, model, prompt

    try:
        if client_type.lower() == 'openai':
            from openai import OpenAI
            client = OpenAI()
            logger.info("OpenAI client configured")
            return client, model or "gpt-4o", prompt
        elif client_type.lower() == 'anthropic':
            from anthropic import Anthropic
            client = Anthropic()
            logger.info("Anthropic client configured")
            return client, model or "claude-3-sonnet-20240229", prompt
        else:
            logger.warning(f"Unknown client type: {client_type}, proceeding without LLM")
            return None, model, prompt
    except ImportError as e:
        logger.warning(f"Failed to import LLM client library: {e}")
        return None, model, prompt
    except Exception as e:
        logger.error(f"Failed to setup LLM client: {e}")
        return None, model, prompt


def main():
    """主函数"""
    args = parse_arguments()

    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)

    if args.list_formats:
        converter = DocumentConverter()
        formats = converter.get_supported_formats()
        print("支持的文档格式:")
        for fmt in formats:
            print(f"  {fmt}")
        return 0

    if not args.input_file:
        print("Error: 请提供输入文件路径")
        print("使用 --help 查看帮助信息")
        return 1

    input_ext = Path(args.input_file).suffix.lower()

    if input_ext == '.pdf':
        logger.info("检测到PDF文件，使用编码修复模式")
        pdf_fixer = PDFEncodingFixer()

        if pdf_fixer.is_available():
            result = pdf_fixer.convert(args.input_file)

            if result['success'] and args.output_file:
                output_file = Path(args.output_file)
                output_file.parent.mkdir(parents=True, exist_ok=True)
                with open(output_file, 'w', encoding='utf-8') as f:
                    f.write(result['text_content'])
                result['output_file'] = str(output_file.absolute())

            if args.json_output:
                print(json.dumps(result, indent=2, ensure_ascii=False))
            else:
                if result['success']:
                    print(f"[使用 {result['method']} 转换]")
                    if result['text_content']:
                        print(result['text_content'])
                    if result.get('output_file'):
                        print(f"\n[文件已保存到: {result['output_file']}]")
                    if result.get('quality'):
                        print(f"[中文比例: {result['quality']['chinese_ratio']:.2%}]")
                    return 0
                else:
                    logger.warning("PDF编码修复失败，回退到markitdown")
        else:
            logger.warning("pdfplumber不可用，使用markitdown")

    llm_client, llm_model, llm_prompt = setup_llm_client(
        args.llm_client,
        args.llm_model,
        args.llm_prompt
    )

    converter = DocumentConverter(
        llm_client=llm_client,
        llm_model=llm_model,
        llm_prompt=llm_prompt,
        enable_plugins=args.enable_plugins
    )

    result = converter.convert(args.input_file, args.output_file)

    if args.json_output:
        print(json.dumps(result, indent=2, ensure_ascii=False))
    else:
        if result['success']:
            if result['text_content']:
                print(result['text_content'])
            if result['output_file']:
                print(f"\n[文件已保存到: {result['output_file']}]")
            return 0
        else:
            print(f"Error: {result['error']}", file=sys.stderr)
            return 1

    return 0 if result['success'] else 1


if __name__ == '__main__':
    sys.exit(main())
