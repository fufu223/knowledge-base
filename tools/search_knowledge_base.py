#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Fastsun 知识库搜索工具

在知识库中快速搜索相关内容。

使用方法:
    python search_knowledge_base.py --keyword "关键词" [--module 模块名] [--case-sensitive]
"""

import os
import re
import argparse
from pathlib import Path
from typing import List, Tuple


class KnowledgeBaseSearcher:
    """知识库搜索器"""
    
    def __init__(self, kb_dir: str):
        self.kb_dir = Path(kb_dir)
        
    def search(self, keyword: str, module: str = None, case_sensitive: bool = False) -> List[Tuple[str, List[str]]]:
        """
        搜索知识库
        
        Args:
            keyword: 搜索关键词
            module: 指定模块名称（可选）
            case_sensitive: 是否区分大小写
            
        Returns:
            搜索结果列表，每项为 (文件路径, 匹配行列表)
        """
        results = []
        
        # 确定搜索范围
        if module:
            search_dirs = [
                self.kb_dir / 'modules' / f"{module}.md",
                self.kb_dir / 'architecture',
                self.kb_dir / 'development',
                self.kb_dir / 'configuration',
            ]
            search_files = [f for f in search_dirs if f.exists()]
        else:
            search_files = list(self.kb_dir.rglob('*.md'))
            
        # 编译正则表达式
        flags = 0 if case_sensitive else re.IGNORECASE
        pattern = re.compile(re.escape(keyword), flags)
        
        # 搜索每个文件
        for file_path in search_files:
            if not file_path.is_file():
                continue
                
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    lines = f.readlines()
                    
                matched_lines = []
                for line_num, line in enumerate(lines, 1):
                    if pattern.search(line):
                        # 提取上下文
                        context = self._get_context(lines, line_num - 1)
                        matched_lines.append({
                            'line_num': line_num,
                            'content': line.strip(),
                            'context': context
                        })
                        
                if matched_lines:
                    results.append((str(file_path.relative_to(self.kb_dir)), matched_lines))
                    
            except Exception as e:
                print(f"读取文件失败 {file_path}: {e}")
                
        return results
        
    def _get_context(self, lines: List[str], line_idx: int, context_size: int = 2) -> List[str]:
        """获取匹配行的上下文"""
        start = max(0, line_idx - context_size)
        end = min(len(lines), line_idx + context_size + 1)
        return [lines[i].strip() for i in range(start, end)]
        
    def display_results(self, results: List[Tuple[str, List[dict]]], show_context: bool = True):
        """显示搜索结果"""
        if not results:
            print("未找到匹配内容")
            return
            
        print(f"\n找到 {len(results)} 个文件包含匹配内容:\n")
        
        for file_path, matches in results:
            print(f"📄 {file_path}")
            print(f"   匹配 {len(matches)} 处\n")
            
            for match in matches[:5]:  # 最多显示5个匹配
                print(f"   第 {match['line_num']} 行:")
                print(f"   {match['content']}")
                
                if show_context and match['context']:
                    print("   上下文:")
                    for ctx_line in match['context']:
                        print(f"     {ctx_line}")
                print()
                
            if len(matches) > 5:
                print(f"   ... 还有 {len(matches) - 5} 个匹配\n")
                
            print("-" * 80)
            print()


def main():
    parser = argparse.ArgumentParser(description='Fastsun 知识库搜索工具')
    parser.add_argument('--keyword', '-k', required=True, help='搜索关键词')
    parser.add_argument('--module', '-m', help='指定模块名称')
    parser.add_argument('--kb-dir', default='.', help='知识库目录（默认: .）')
    parser.add_argument('--case-sensitive', '-c', action='store_true', help='区分大小写')
    parser.add_argument('--no-context', action='store_true', help='不显示上下文')
    
    args = parser.parse_args()
    
    searcher = KnowledgeBaseSearcher(args.kb_dir)
    results = searcher.search(args.keyword, args.module, args.case_sensitive)
    searcher.display_results(results, show_context=not args.no_context)


if __name__ == '__main__':
    main()
