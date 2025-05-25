# Provider Information Scripts

This repository contains scripts to read provider configurations from `providers.json` and display the base URL and token information for API providers.

## Available Scripts

### Python Version (`provider_info.py`)

**Requirements:** Python 3.6+

**Usage:**
```bash
python provider_info.py [provider_name]
```

### JavaScript Version (`provider_info.js`)

**Requirements:** Node.js 12.0+

**Usage:**
```bash
node provider_info.js [provider_name]
```

## Features

- **Default Provider:** If no provider name is specified, defaults to "OpenAI"
- **Environment Variable Override:** For OpenAI provider, if `OPENAI_BASE_URL` environment variable is set, it will be used instead of the base_url from the JSON configuration
- **Case-Insensitive:** Provider names are matched case-insensitively
- **Error Handling:** Displays helpful error messages and lists available providers if an invalid name is provided

## Examples

### Using Default (OpenAI)
```bash
# Python
python provider_info.py

# JavaScript
node provider_info.js
```

### Using Specific Provider
```bash
# Python
python provider_info.py "Anthropic"

# JavaScript
node provider_info.js "Anthropic"
```

### Using Custom JSON File
```bash
# Python
python provider_info.py "OpenAI" --json-file custom_providers.json

# JavaScript
node provider_info.js "OpenAI" --json-file custom_providers.json
```

### Using Custom OpenAI Base URL
```bash
# Windows PowerShell
$env:OPENAI_BASE_URL="https://custom.endpoint.com/v1/"
python provider_info.py
# or
node provider_info.js

# Linux/macOS
export OPENAI_BASE_URL="https://custom.endpoint.com/v1/"
python provider_info.py
# or
node provider_info.js
```

## Help

Both scripts support help flags:

```bash
# Python
python provider_info.py --help

# JavaScript
node provider_info.js --help
```

## Available Providers

The scripts work with the following providers configured in `providers.json`:

- OpenAI
- Azure OpenAI
- Anthropic
- Google Gemini
- Mistral AI
- Groq
- Perplexity AI
- Cohere
- Together AI
- OpenRouter
- Ollama
- Replicate
- Hugging Face
- Amazon Bedrock
- DeepInfra
- LM Studio

## Output Format

Both scripts output information in the following format:

```
Provider: OpenAI
Base URL: https://api.openai.com/v1/
Token Environment Key: OPENAI_API_KEY
Token: Environment variable 'OPENAI_API_KEY' not found
```