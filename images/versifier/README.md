# Versifier Docker Image

这个 Docker 镜像包含了 [versifier](https://github.com/MrLYC/versifier) - 一套用于处理 Python 项目依赖管理的命令行工具集。

## 功能特性

- **requirements.txt 转 Poetry**: 将 requirements.txt 转化为 Poetry 的 pyproject.toml
- **Poetry 转 requirements.txt**: 将 Poetry 的 pyproject.toml 导出为 requirements.txt
- **私有包提取**: 将私有包提取到指定目录
- **项目目录混淆**: 混淆项目目录结构
- **私有包混淆**: 混淆私有包内容

## 构建镜像

```bash
docker build -t versifier ./images/versifier/
```

## 使用方法

### 1. 查看帮助信息

```bash
docker run --rm versifier
```

### 2. requirements.txt 转 Poetry

```bash
# 将当前目录的 requirements.txt 转换为 pyproject.toml
docker run --rm -v $(pwd):/workspace versifier \
  requirements-to-poetry --requirements requirements.txt
```

### 3. Poetry 转 requirements.txt

```bash
# 将 pyproject.toml 导出为 requirements.txt
docker run --rm -v $(pwd):/workspace versifier \
  poetry-to-requirements --output requirements.txt
```

### 4. 提取私有包

```bash
# 提取私有包到指定目录
docker run --rm -v $(pwd):/workspace versifier \
  extract-private-packages --output ./packages --private-packages "mypackage1,mypackage2"
```

### 5. 混淆项目目录

```bash
# 混淆项目目录
docker run --rm -v $(pwd):/workspace versifier \
  obfuscate-project-dirs --output ./obfuscated --sub-dirs "src,lib"
```

### 6. 混淆私有包

```bash
# 混淆私有包
docker run --rm -v $(pwd):/workspace versifier \
  obfuscate-private-packages --output ./obfuscated --private-packages "mypackage"
```

## 常用参数

### 通用参数

| 参数 | 描述 | 默认值 |
|------|------|--------|
| `-c, --config` | 配置文件路径 | 无 |
| `-r, --root` | 根目录 | 当前目录 |
| `--poetry-path` | Poetry 可执行文件路径 | "poetry" |
| `--nuitka-path` | Nuitka3 可执行文件路径 | "nuitka3" |
| `--log-level` | 日志级别 | INFO |

### requirements-to-poetry 参数

| 参数 | 描述 | 默认值 |
|------|------|--------|
| `-R, --requirements` | requirements 文件 | requirements.txt |
| `-d, --dev-requirements` | 开发环境 requirements 文件 | dev-requirements.txt |
| `-e, --exclude` | 要排除的包 | 无 |
| `--add-only` | 只添加包，不删除现有包 | False |

### poetry-to-requirements 参数

| 参数 | 描述 | 默认值 |
|------|------|--------|
| `-o, --output` | 输出文件 | 无 |
| `--exclude-specifiers` | 排除指定的包 | False |
| `--include-comments` | 包含注释 | False |
| `-d, --include-dev-requirements` | 包含开发依赖 | False |
| `-E, --extra-requirements` | 额外的 requirements | 无 |
| `-m, --markers` | 指定标记 | 无 |
| `-P, --private-packages` | 私有包 | 无 |

## 使用示例

### 示例 1: 完整的 requirements 转换

```bash
# 创建一个包含 requirements.txt 的目录
mkdir myproject && cd myproject
echo "requests>=2.25.0" > requirements.txt
echo "pytest>=6.0.0" > dev-requirements.txt

# 转换为 Poetry 项目
docker run --rm -v $(pwd):/workspace versifier \
  requirements-to-poetry \
  --requirements requirements.txt \
  --dev-requirements dev-requirements.txt \
  --exclude "setuptools,pip"
```

### 示例 2: Poetry 项目导出 requirements

```bash
# 假设已有 pyproject.toml 文件
docker run --rm -v $(pwd):/workspace versifier \
  poetry-to-requirements \
  --output requirements.txt \
  --include-comments \
  --include-dev-requirements
```

### 示例 3: 批量处理多个项目

```bash
# 批量转换多个项目
for project in project1 project2 project3; do
  echo "Processing $project..."
  docker run --rm -v $(pwd)/$project:/workspace versifier \
    requirements-to-poetry --requirements requirements.txt
done
```

## 目录结构

容器使用 `/workspace` 作为工作目录，建议将你的项目目录挂载到此路径：

```
/workspace/          # 工作目录 (挂载点)
├── requirements.txt # 输入文件
├── pyproject.toml   # 输出/输入文件
└── ...             # 其他项目文件
```

## 安全注意事项

- 容器以非 root 用户 (versifier:1001) 运行，增强安全性
- 建议以只读方式挂载不需要修改的文件
- 处理私有包时请注意数据保护

## 故障排除

1. **权限问题**: 确保挂载的目录有正确的读写权限
2. **文件找不到**: 检查文件路径是否正确挂载到 `/workspace`
3. **Poetry 命令失败**: 确保容器内有 Poetry 环境或使用 `--poetry-path` 指定路径

## 支持的功能

- ✅ requirements.txt ↔ pyproject.toml 转换
- ✅ 开发依赖管理
- ✅ 包排除和过滤
- ✅ 私有包处理
- ✅ 项目混淆
- ✅ 配置文件支持
- ✅ 多种输出格式