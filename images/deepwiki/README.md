# deepwiki

这个镜像会在容器内完成以下流程：

1. 使用 `deepwiki-rs`（Litho）从输入目录生成文档
2. 使用 `mermaid-fixer` 修复输出目录中的 Mermaid 图
3. 使用 `mise run deepwiki` 作为统一任务入口
4. 预初始化 `fnox` 与 age key，默认可解密 `fnox` secrets

## 构建

```bash
docker build -t deepwiki:local images/deepwiki
```

## 运行

```bash
docker run --rm \
  -e LLM_PROVIDER=openai \
  -e LLM_BASE_URL=https://api.openai.com/v1 \
  -e LLM_API_KEY=your-api-key \
  -e LLM_MODEL=gpt-4.1-mini \
  -e INPUT_DIR=/input \
  -e OUTPUT_DIR=/output \
  -v "$PWD:/input:ro" \
  -v "$PWD/.deepwiki-output:/output" \
  deepwiki:local
```

## 环境变量

- `LLM_PROVIDER`: Mermaid Fixer 使用的 provider，默认 `openai`
- `LLM_BASE_URL`: OpenAI-compatible base URL；不传则使用工具默认值
- `LLM_API_KEY`: 必填，也可放进 `fnox`
- `LLM_MODEL`: 必填，`deepwiki-rs` 会作为 `--model-efficient` 传入
- `INPUT_DIR`: 输入目录，默认 `/workspace/input`
- `OUTPUT_DIR`: 输出目录，默认 `/workspace/output`
- `TARGET_LANGUAGE`: 可选，透传到 `deepwiki-rs --target-language`
- `DEEPWIKI_DISABLE_PRESET_TOOLS`: 可选，设为 `true` 时透传 `--disable-preset-tools`

除了上面的标准大写变量，入口脚本也兼容 `llm-provider`、`llm-base-url`、`llm-api-key`、`llm-model`、`input-dir`、`output-dir` 这类 kebab-case 环境变量。

## fnox

镜像构建时会执行：

- `fnox init`
- `age-keygen -o /root/.config/fnox/age.txt`
- 在 `/root/.config/fnox/fnox.toml` 中写入 `providers.age`

容器启动时如果没有显式提供 `FNOX_AGE_KEY`，入口脚本会自动从 `/root/.config/fnox/age.txt`（也可通过 `FNOX_AGE_KEY_PATH` 覆盖）读取私钥并导出，这样默认任务可以直接解密 age secrets。

如果你把 `LLM_API_KEY` 等值存进 `fnox`，默认任务会按以下顺序取值：

1. 显式环境变量（例如 `LLM_API_KEY`）
2. kebab-case 环境变量（例如 `llm-api-key`）
3. `fnox get LLM_API_KEY`
4. `fnox get llm-api-key`
