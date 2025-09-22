# didatodolist-mcp Docker Image
# Based on https://github.com/GalaxyXieyu/didatodolist-mcp
FROM python:3.11-slim

LABEL maintainer="MrLYC"
LABEL description="didatodolist-mcp - A Model Context Protocol server for DidaTick"
LABEL source="https://github.com/GalaxyXieyu/didatodolist-mcp"

# 设置工作目录
WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

# 克隆源代码
RUN git clone https://github.com/GalaxyXieyu/didatodolist-mcp.git .

# 安装 Python 依赖
# requirements.txt from repo:
# fastmcp
# python-dotenv
# requests
# pandas>=1.3.0
# jieba>=0.42.1
# numpy>=1.20.0
# wordcloud>=1.8.1
# matplotlib>=3.4.0
# scikit-learn>=0.24.0
RUN pip install --no-cache-dir \
    fastmcp \
    python-dotenv \
    requests \
    pandas \
    jieba \
    numpy \
    wordcloud \
    matplotlib \
    scikit-learn

# 创建数据目录
RUN mkdir -p /app/data/backups

# 创建非 root 用户
RUN groupadd -r mcpuser && useradd -r -g mcpuser -d /app -s /bin/bash mcpuser && \
    chown -R mcpuser:mcpuser /app

# 切换到非 root 用户
USER mcpuser

# 设置环境变量
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1

# 暴露端口（用于 SSE 模式）
EXPOSE 3000

# 默认命令
CMD ["python", "main.py"]
