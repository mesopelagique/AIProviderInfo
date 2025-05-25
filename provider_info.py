#!/usr/bin/env python3
"""
Provider Information Script

This script reads provider configurations from providers.json and prints
the base URL and token for a specified provider.

Usage:
    python provider_info.py [provider_name]

If no provider_name is specified, defaults to "OpenAI".
For OpenAI provider, if OPENAI_BASE_URL environment variable is set,
it will be used instead of the base_url from the JSON configuration.

Examples:
    python provider_info.py           # Uses OpenAI by default
    python provider_info.py "OpenAI"
    python provider_info.py "Anthropic"
"""

import json
import os
import sys
import argparse


def load_providers(json_file_path):
    """Load provider configurations from JSON file."""
    try:
        with open(json_file_path, 'r', encoding='utf-8') as file:
            return json.load(file)
    except FileNotFoundError:
        print(f"Error: File '{json_file_path}' not found.")
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON in '{json_file_path}': {e}")
        sys.exit(1)


def find_provider(providers, provider_name):
    """Find a provider by name (case-insensitive)."""
    for provider in providers:
        if provider['name'].lower() == provider_name.lower():
            return provider
    return None


def get_token_from_env(token_env_key) -> str:
    """Retrieve token from environment variable."""
    if not token_env_key:
        return "No token required"
    
    token = os.getenv(token_env_key)
    if token:
        return token
    else:
        return f"Environment variable '{token_env_key}' not found"


def main():
    parser = argparse.ArgumentParser(
        description="Get provider information from providers.json",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python provider_info.py "OpenAI"
  python provider_info.py "Anthropic"
  python provider_info.py "Ollama"
  python provider_info.py  # Uses OpenAI by default
        """
    )
    parser.add_argument('provider_name', nargs='?', default='OpenAI', 
                       help='Name of the provider to look up (default: OpenAI)')
    parser.add_argument('--json-file', default='providers.json', 
                       help='Path to the providers JSON file (default: providers.json)')
    
    args = parser.parse_args()
    
    # Load providers from JSON file
    providers = load_providers(args.json_file)
    
    # Find the specified provider
    provider = find_provider(providers, args.provider_name)
    
    if not provider:
        print(f"Error: Provider '{args.provider_name}' not found.")
        print("\nAvailable providers:")
        for p in providers:
            print(f"  - {p['name']}")
        sys.exit(1)
      # Get token from environment variable
    token = get_token_from_env(provider['token_env_key'])
    
    # Get base URL - check for OPENAI_BASE_URL if provider is OpenAI
    base_url = provider['base_url']
    if provider['name'].lower() == 'openai':
        openai_base_url = os.getenv('OPENAI_BASE_URL')
        if openai_base_url:
            base_url = openai_base_url
    
    # Print provider information
    print(f"Provider: {provider['name']}")
    print(f"Base URL: {base_url}")
    print(f"Token Environment Key: {provider['token_env_key'] or 'None'}")
    print(f"Token: {token}")


if __name__ == "__main__":
    main()
