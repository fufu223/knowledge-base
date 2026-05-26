#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Fastsun 平台知识库自动生成工具

该工具用于扫描 Fastsun 平台源码，自动生成和更新知识库文档。
避免每次使用时都需要重新扫描源码，提高开发效率。

使用方法:
    python generate_knowledge_base.py [--module MODULE_NAME] [--output OUTPUT_DIR]
    
参数:
    --module: 指定要生成的模块名称（可选，默认生成所有模块）
    --output: 指定输出目录（可选，默认为 knowledge-base）
"""

import os
import sys
import json
import re
from pathlib import Path
from typing import Dict, List, Optional
from dataclasses import dataclass, field
import argparse


@dataclass
class ModuleInfo:
    """模块信息"""
    name: str
    path: str
    description: str = ""
    classes: List[str] = field(default_factory=list)
    apis: List[Dict] = field(default_factory=list)
    configurations: List[Dict] = field(default_factory=list)


@dataclass
class ClassInfo:
    """类信息"""
    name: str
    package: str
    type: str  # Controller, Service, Entity, DTO, etc.
    description: str = ""
    methods: List[Dict] = field(default_factory=list)
    annotations: List[str] = field(default_factory=list)


class KnowledgeBaseGenerator:
    """知识库生成器"""
    
    def __init__(self, project_root: str, output_dir: str):
        self.project_root = Path(project_root)
        self.output_dir = Path(output_dir)
        self.modules: Dict[str, ModuleInfo] = {}
        
    def scan_project(self):
        """扫描项目结构"""
        print(f"开始扫描项目: {self.project_root}")
        
        # 扫描所有模块
        for item in self.project_root.iterdir():
            if item.is_dir() and item.name.startswith('fastsun-'):
                module_info = self._scan_module(item)
                if module_info:
                    self.modules[module_info.name] = module_info
                    
        print(f"共发现 {len(self.modules)} 个模块")
        
    def _scan_module(self, module_path: Path) -> Optional[ModuleInfo]:
        """扫描单个模块"""
        module_name = module_path.name
        
        # 查找 pom.xml 获取模块描述
        pom_file = module_path / 'pom.xml'
        description = self._extract_module_description(pom_file)
        
        module_info = ModuleInfo(
            name=module_name,
            path=str(module_path),
            description=description
        )
        
        # 扫描 Java 源文件
        src_dir = module_path / 'src' / 'main' / 'java'
        if src_dir.exists():
            self._scan_java_files(src_dir, module_info)
            
        return module_info
        
    def _scan_java_files(self, src_dir: Path, module_info: ModuleInfo):
        """扫描 Java 文件"""
        for java_file in src_dir.rglob('*.java'):
            class_info = self._parse_java_file(java_file)
            if class_info:
                module_info.classes.append(class_info.name)
                
                # 如果是 Controller，提取 API 信息
                if class_info.type == 'Controller':
                    apis = self._extract_apis(class_info, java_file)
                    module_info.apis.extend(apis)
                    
    def _parse_java_file(self, file_path: Path) -> Optional[ClassInfo]:
        """解析 Java 文件"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                
            # 提取包名
            package_match = re.search(r'package\s+([\w.]+);', content)
            if not package_match:
                return None
            package = package_match.group(1)
            
            # 提取类名
            class_match = re.search(r'(?:public\s+)?(?:abstract\s+)?class\s+(\w+)', content)
            if not class_match:
                return None
            class_name = class_match.group(1)
            
            # 判断类型
            class_type = self._determine_class_type(content, class_name)
            
            # 提取注释
            description = self._extract_class_description(content)
            
            # 提取注解
            annotations = self._extract_annotations(content)
            
            return ClassInfo(
                name=class_name,
                package=package,
                type=class_type,
                description=description,
                annotations=annotations
            )
        except Exception as e:
            print(f"解析文件失败 {file_path}: {e}")
            return None
            
    def _determine_class_type(self, content: str, class_name: str) -> str:
        """判断类类型"""
        if 'Controller' in class_name or '@RestController' in content or '@Controller' in content:
            return 'Controller'
        elif 'Service' in class_name or '@Service' in content:
            return 'Service'
        elif 'Repository' in class_name or '@Repository' in content:
            return 'Repository'
        elif 'DTO' in class_name or class_name.endswith('DTO'):
            return 'DTO'
        elif 'Entity' in class_name or '@Entity' in content:
            return 'Entity'
        elif 'Config' in class_name or '@Configuration' in content:
            return 'Configuration'
        else:
            return 'Other'
            
    def _extract_class_description(self, content: str) -> str:
        """提取类描述"""
        # 查找类注释
        match = re.search(r'/\*\*\s*\n(?:\s*\*\s*(.*?)\n)*?\s*\*/\s*\n(?:@\w+\s*\n)*?(?:public\s+)?(?:abstract\s+)?class', 
                         content, re.DOTALL)
        if match:
            # 提取注释内容
            comment_section = match.group(0)
            lines = []
            for line in comment_section.split('\n'):
                line = line.strip()
                if line.startswith('*'):
                    line = line[1:].strip()
                if line and not line.startswith('/') and not line.startswith('@'):
                    lines.append(line)
            return ' '.join(lines)
        return ""
        
    def _extract_annotations(self, content: str) -> List[str]:
        """提取类注解"""
        annotations = []
        # 查找 @ 开头的注解
        matches = re.findall(r'@(\w+)(?:\(.*?\))?', content)
        return list(set(matches))  # 去重
        
    def _extract_apis(self, class_info: ClassInfo, file_path: Path) -> List[Dict]:
        """提取 API 信息"""
        apis = []
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                
            # 查找方法
            method_pattern = r'@(GetMapping|PostMapping|PutMapping|DeleteMapping|RequestMapping)\s*\(\s*["\']([^"\']+)["\']'
            matches = re.finditer(method_pattern, content)
            
            for match in matches:
                http_method = match.group(1).replace('Mapping', '').upper()
                if http_method == 'REQUEST':
                    http_method = 'GET'  # 默认
                    
                path = match.group(2)
                
                # 提取方法名和描述
                method_info = self._extract_method_info(content, match.end())
                
                apis.append({
                    'method': http_method,
                    'path': path,
                    'class': class_info.name,
                    'description': method_info.get('description', ''),
                    'methodName': method_info.get('name', '')
                })
        except Exception as e:
            print(f"提取 API 失败 {file_path}: {e}")
            
        return apis
        
    def _extract_method_info(self, content: str, start_pos: int) -> Dict:
        """提取方法信息"""
        # 查找方法定义
        method_match = re.search(r'public\s+\w+\s+(\w+)\s*\([^)]*\)', content[start_pos:start_pos+500])
        if method_match:
            method_name = method_match.group(1)
            
            # 查找方法注释
            comment_match = re.search(r'/\*\*\s*\n(?:\s*\*\s*(.*?)\n)*?\s*\*/\s*\n(?:@\w+.*\n)*?public', 
                                     content[max(0, start_pos-500):start_pos], re.DOTALL)
            description = ""
            if comment_match:
                lines = []
                for line in comment_match.group(0).split('\n'):
                    line = line.strip()
                    if line.startswith('*'):
                        line = line[1:].strip()
                    if line and not line.startswith('/') and not line.startswith('@'):
                        lines.append(line)
                description = ' '.join(lines)
                
            return {'name': method_name, 'description': description}
            
        return {}
        
    def _extract_module_description(self, pom_file: Path) -> str:
        """从 pom.xml 提取模块描述"""
        if not pom_file.exists():
            return ""
            
        try:
            with open(pom_file, 'r', encoding='utf-8') as f:
                content = f.read()
                
            # 提取 description
            match = re.search(r'<description>(.*?)</description>', content, re.DOTALL)
            if match:
                return match.group(1).strip()
        except Exception as e:
            print(f"读取 pom.xml 失败: {e}")
            
        return ""
        
    def generate_readme(self):
        """生成 README.md"""
        readme_path = self.output_dir / 'README.md'
        
        content = """# Fastsun 平台知识库

## 概述

Fastsun 是一个基于 Spring Boot 的多租户微服务框架，提供企业级应用开发所需的核心功能。本知识库旨在为开发者提供全面的框架文档，避免每次使用时都需要扫描源码。

## 知识库结构

- **[架构设计](./architecture/)** - 系统整体架构和核心设计原理
- **[模块详解](./modules/)** - 各功能模块的详细说明
- **[API 参考](./api-reference/)** - REST API 和 SDK API 文档
- **[配置指南](./configuration/)** - 应用配置和属性说明
- **[开发指南](./development/)** - 快速开始、最佳实践和扩展开发
- **[部署指南](./deployment/)** - 单体和分布式部署方案
- **[故障排查](./troubleshooting/)** - 常见问题和调试指南

## 核心特性

### 1. 多租户支持
- 字段隔离模式
- 数据库隔离模式
- 租户上下文管理

### 2. 安全认证
- OAuth2 + Spring Security
- 多种登录方式（用户名密码、微信、企业微信等）
- 细粒度权限控制

### 3. 工作流引擎
- 基于 Activiti 7.x
- 可视化流程设计
- 动态节点添加

### 4. 低代码平台
- 动态表单配置
- 视图元数据管理
- 代码自动生成

### 5. 消息通知
- 多渠道消息推送
- 消息模板管理
- WebSocket 实时通信

### 6. 数据权限
- 行级数据过滤
- 角色资源权限
- 动态权限拦截

## 技术栈

- **Java**: 17
- **Spring Boot**: 2.7.6
- **Spring Cloud**: 2021.0.5
- **Hibernate**: 5.6.15.Final
- **Activiti**: 7.1.0.M6
- **Redis**: Jedis 3.8.0
- **数据库**: MySQL 8.0+, Oracle, PostgreSQL

## 版本信息

当前版本: 2.3.26-20260326-RELEASE

## 如何使用本知识库

1. **快速入门**: 查看 [开发指南](./development/getting-started.md)
2. **架构理解**: 阅读 [架构设计](./architecture/overview.md)
3. **模块使用**: 参考 [模块详解](./modules/) 中的相关文档
4. **API 调用**: 查阅 [API 参考](./api-reference/)
5. **问题排查**: 搜索 [故障排查](./troubleshooting/)

## 维护说明

本知识库通过自动化工具生成和维护，确保与源码保持同步。如需更新知识库，请运行知识库生成工具。

## 许可证

内部使用，请勿外传。
"""
        
        with open(readme_path, 'w', encoding='utf-8') as f:
            f.write(content)
            
        print(f"生成 README.md: {readme_path}")
        
    def generate_module_docs(self):
        """生成模块文档"""
        modules_dir = self.output_dir / 'modules'
        modules_dir.mkdir(parents=True, exist_ok=True)
        
        for module_name, module_info in self.modules.items():
            self._generate_module_doc(module_name, module_info, modules_dir)
            
    def _generate_module_doc(self, module_name: str, module_info: ModuleInfo, modules_dir: Path):
        """生成单个模块文档"""
        module_file = modules_dir / f"{module_name}.md"
        
        content = f"""# {module_name}

## 模块概述

{module_info.description or '暂无描述'}

**路径**: `{module_info.path}`

## 主要类

"""
        
        # 按类型分组
        class_types = {}
        for class_name in module_info.classes[:50]:  # 限制数量
            # 简单判断类型
            if 'Controller' in class_name:
                class_type = 'Controller'
            elif 'Service' in class_name:
                class_type = 'Service'
            elif 'DTO' in class_name:
                class_type = 'DTO'
            elif 'Entity' in class_name or 'Repository' in class_name:
                class_type = 'Data Access'
            else:
                class_type = 'Other'
                
            if class_type not in class_types:
                class_types[class_type] = []
            class_types[class_type].append(class_name)
            
        for class_type, classes in class_types.items():
            content += f"### {class_type}\n\n"
            for class_name in classes[:20]:  # 每个类型最多20个
                content += f"- `{class_name}`\n"
            content += "\n"
            
        # API 列表
        if module_info.apis:
            content += "## API 接口\n\n"
            for api in module_info.apis[:30]:  # 限制数量
                content += f"### {api['method']} `{api['path']}`\n\n"
                content += f"**类**: {api['class']}\n\n"
                if api['description']:
                    content += f"**描述**: {api['description']}\n\n"
                content += "---\n\n"
                
        with open(module_file, 'w', encoding='utf-8') as f:
            f.write(content)
            
        print(f"生成模块文档: {module_file}")
        
    def generate_index(self):
        """生成索引文件"""
        index_path = self.output_dir / 'INDEX.md'
        
        content = """# 知识库索引

## 架构设计

- [架构概述](./architecture/overview.md)
- [多租户架构](./architecture/multi-tenancy.md)
- [安全架构](./architecture/security.md)

## 模块文档

"""
        
        for module_name in sorted(self.modules.keys()):
            content += f"- [{module_name}](./modules/{module_name}.md)\n"
            
        content += """
## 开发指南

- [快速开始](./development/getting-started.md)
- [最佳实践](./development/best-practices.md)

## 配置指南

- [配置说明](./configuration/properties.md)

## 故障排查

- [常见问题](./troubleshooting/common-issues.md)
"""
        
        with open(index_path, 'w', encoding='utf-8') as f:
            f.write(content)
            
        print(f"生成索引文件: {index_path}")
        
    def generate_all(self):
        """生成所有文档"""
        print("开始生成知识库...")
        
        # 扫描项目
        self.scan_project()
        
        # 创建输出目录
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        # 生成文档
        self.generate_readme()
        self.generate_module_docs()
        self.generate_index()
        
        print(f"\n知识库生成完成！输出目录: {self.output_dir}")
        print(f"共处理 {len(self.modules)} 个模块")


def main():
    parser = argparse.ArgumentParser(description='Fastsun 知识库生成工具')
    parser.add_argument('--project', default='.', help='项目根目录')
    parser.add_argument('--output', default='knowledge-base', help='输出目录')
    parser.add_argument('--module', help='指定模块名称（可选）')
    
    args = parser.parse_args()
    
    generator = KnowledgeBaseGenerator(args.project, args.output)
    generator.generate_all()


if __name__ == '__main__':
    main()
