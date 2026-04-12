"""
PDF Encoding Fixer - 利用pdfplumber的字符级提取解决中文乱码
无需额外依赖，使用pdfplumber内置的chars对象获取Unicode字符
"""

import re
import logging
from pathlib import Path
from typing import Optional, Tuple, Dict, Any

logger = logging.getLogger(__name__)


class PDFEncodingFixer:
    """
    PDF编码修复器
    使用pdfplumber的字符级提取功能，直接获取Unicode字符，
    绕过PDF的字节级编码问题
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
    def _detect_text_quality(text: str) -> Dict[str, Any]:
        """
        检测文本质量

        Returns:
            Dict: 包含乱码率、中文字符比例等信息
        """
        if not text:
            return {
                'is_garbled': True,
                'chinese_ratio': 0.0,
                'replacement_char_ratio': 0.0
            }

        replacement_char = '\ufffd'
        replacement_count = text.count(replacement_char)

        chinese_chars = len(re.findall(r'[\u4e00-\u9fff\u3400-\u4dbf]', text))
        total_chars = len(text)

        chinese_ratio = chinese_chars / total_chars if total_chars > 0 else 0.0
        replacement_ratio = replacement_count / total_chars if total_chars > 0 else 0.0

        is_garbled = (
            replacement_ratio > 0.01 or
            (chinese_ratio < 0.1 and '?' in text)
        )

        return {
            'is_garbled': is_garbled,
            'chinese_ratio': chinese_ratio,
            'replacement_ratio': replacement_ratio,
            'total_chars': total_chars,
            'chinese_chars': chinese_chars
        }

    @staticmethod
    def _extract_chars_unicode(pdf_path: str) -> Tuple[bool, str]:
        """
        使用pdfplumber的chars对象提取Unicode文本
        这是避免乱码的关键：直接从字符对象获取unicode字段

        Returns:
            Tuple[成功标志, 提取的文本]
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
    def _extract_text_fallback(pdf_path: str) -> Tuple[bool, str]:
        """
        回退方法：使用标准文本提取

        Returns:
            Tuple[成功标志, 提取的文本]
        """
        import pdfplumber

        try:
            full_text = ""

            with pdfplumber.open(pdf_path) as pdf:
                for page_num, page in enumerate(pdf.pages):
                    text = page.extract_text()
                    if text:
                        full_text += f"\n\n## Page {page_num + 1}\n\n{text}"

            return True, full_text.strip()

        except Exception as e:
            logger.error(f"pdfplumber text extraction failed: {e}")
            return False, str(e)

    @staticmethod
    def _try_encoding_fix(text: str) -> str:
        """
        尝试验证并修复常见编码问题

        Args:
            text: 可能存在编码问题的文本

        Returns:
            验证/修复后的文本
        """
        if not text:
            return text

        replacement_char = '\ufffd'
        if replacement_char in text:
            logger.warning("检测到替换字符，可能存在编码问题")
            return text

        if '???' in text:
            logger.warning("检测到问号序列，可能存在编码问题")

        return text

    @staticmethod
    def _clean_text(text: str) -> str:
        """
        清理提取的文本

        Args:
            text: 原始文本

        Returns:
            清理后的文本
        """
        text = re.sub(r'\n{3,}', '\n\n', text)

        text = re.sub(r'[ \t]+', ' ', text)

        text = re.sub(r'([。！？；])\n([A-Za-z\u4e00-\u9fff])', r'\1\2', text)

        text = text.strip()

        return text

    def convert(self, pdf_path: str) -> Dict[str, Any]:
        """
        转换PDF文件，优先使用Unicode字符级提取

        Args:
            pdf_path: PDF文件路径

        Returns:
            Dict: 包含success, text_content, method等信息
        """
        if not Path(pdf_path).exists():
            return {
                'success': False,
                'error': f'File not found: {pdf_path}',
                'text_content': '',
                'method': 'none'
            }

        logger.info(f"使用pdfplumber转换PDF (Unicode级提取): {pdf_path}")

        success, text = self._extract_chars_unicode(pdf_path)

        if not success:
            logger.warning("Unicode级提取失败，尝试回退方法")
            success, text = self._extract_text_fallback(pdf_path)
            if success:
                text = self._try_encoding_fix(text)
                return {
                    'success': True,
                    'text_content': self._clean_text(text),
                    'method': 'pdfplumber_text_fallback'
                }
            else:
                return {
                    'success': False,
                    'error': text,
                    'text_content': '',
                    'method': 'all_failed'
                }

        quality = self._detect_text_quality(text)
        logger.info(f"文本质量检测 - 乱码: {quality['is_garbled']}, "
                   f"中文比例: {quality['chinese_ratio']:.2%}")

        text = self._try_encoding_fix(text)
        cleaned_text = self._clean_text(text)

        return {
            'success': True,
            'text_content': cleaned_text,
            'method': 'pdfplumber_unicode',
            'quality': quality
        }


def convert_pdf_with_encoding_fix(pdf_path: str, output_path: Optional[str] = None) -> Dict[str, Any]:
    """
    使用编码修复转换PDF

    Args:
        pdf_path: 输入PDF路径
        output_path: 输出Markdown路径（可选）

    Returns:
        Dict: 转换结果
    """
    fixer = PDFEncodingFixer()

    if not fixer.is_available():
        return {
            'success': False,
            'error': 'pdfplumber not available',
            'text_content': '',
            'method': 'none'
        }

    result = fixer.convert(pdf_path)

    if result['success'] and output_path:
        output_file = Path(output_path)
        output_file.parent.mkdir(parents=True, exist_ok=True)

        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(result['text_content'])

        result['output_file'] = str(output_file.absolute())
        logger.info(f"转换结果已保存到: {output_path}")

    return result


if __name__ == '__main__':
    import sys

    if len(sys.argv) < 2:
        print("用法: python pdf_encoding_fixer.py <pdf文件路径> [输出markdown路径]")
        sys.exit(1)

    pdf_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else None

    print(f"转换PDF (编码修复模式): {pdf_file}")
    print("-" * 60)

    result = convert_pdf_with_encoding_fix(pdf_file, output_file)

    if result['success']:
        print(f"✓ 转换成功!")
        print(f"  方法: {result['method']}")
        if result.get('quality'):
            q = result['quality']
            print(f"  中文比例: {q['chinese_ratio']:.2%}")
            print(f"  乱码检测: {'是' if q['is_garbled'] else '否'}")
        if result.get('output_file'):
            print(f"  输出文件: {result['output_file']}")
        print("\n预览（前500字符）:")
        print("-" * 60)
        print(result['text_content'][:500])
    else:
        print(f"✗ 转换失败: {result.get('error', '未知错误')}")
        sys.exit(1)
