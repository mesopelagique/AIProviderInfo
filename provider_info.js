#!/usr/bin/env node
/**
 * Provider Information Script
 * 
 * This script reads provider configurations from providers.json and prints
 * the base URL and token for a specified provider.
 * 
 * Usage:
 *     node provider_info.js [provider_name]
 * 
 * If no provider_name is specified, defaults to "OpenAI".
 * For OpenAI provider, if OPENAI_BASE_URL environment variable is set,
 * it will be used instead of the base_url from the JSON configuration.
 * 
 * Examples:
 *     node provider_info.js           # Uses OpenAI by default
 *     node provider_info.js "OpenAI"
 *     node provider_info.js "Anthropic"
 */

const fs = require('fs');
const path = require('path');

/**
 * Load provider configurations from JSON file
 * @param {string} jsonFilePath - Path to the JSON file
 * @returns {Array} Array of provider configurations
 */
function loadProviders(jsonFilePath) {
    try {
        const data = fs.readFileSync(jsonFilePath, 'utf8');
        return JSON.parse(data);
    } catch (error) {
        if (error.code === 'ENOENT') {
            console.error(`Error: File '${jsonFilePath}' not found.`);
        } else if (error instanceof SyntaxError) {
            console.error(`Error: Invalid JSON in '${jsonFilePath}': ${error.message}`);
        } else {
            console.error(`Error reading file '${jsonFilePath}': ${error.message}`);
        }
        process.exit(1);
    }
}

/**
 * Find a provider by name (case-insensitive)
 * @param {Array} providers - Array of provider configurations
 * @param {string} providerName - Name of the provider to find
 * @returns {Object|null} Provider object or null if not found
 */
function findProvider(providers, providerName) {
    return providers.find(provider => 
        provider.name.toLowerCase() === providerName.toLowerCase()
    ) || null;
}

/**
 * Retrieve token from environment variable
 * @param {string} tokenEnvKey - Environment variable key
 * @returns {string} Token value or error message
 */
function getTokenFromEnv(tokenEnvKey) {
    if (!tokenEnvKey) {
        return "No token required";
    }
    
    const token = process.env[tokenEnvKey];
    if (token) {
        return token;
    } else {
        return `Environment variable '${tokenEnvKey}' not found`;
    }
}

/**
 * Display help information
 */
function showHelp() {
    console.log(`
Usage: node provider_info.js [provider_name] [options]

Arguments:
  provider_name           Name of the provider to look up (default: OpenAI)

Options:
  --json-file <path>      Path to the providers JSON file (default: providers.json)
  --help, -h              Show this help message

Examples:
  node provider_info.js                # Uses OpenAI by default
  node provider_info.js "OpenAI"
  node provider_info.js "Anthropic"
  node provider_info.js "Ollama"
  node provider_info.js --json-file custom_providers.json "OpenAI"
`);
}

/**
 * Parse command line arguments
 * @param {Array} args - Command line arguments
 * @returns {Object} Parsed arguments
 */
function parseArgs(args) {
    const parsed = {
        providerName: 'OpenAI',
        jsonFile: 'providers.json',
        showHelp: false
    };

    for (let i = 0; i < args.length; i++) {
        const arg = args[i];
        
        if (arg === '--help' || arg === '-h') {
            parsed.showHelp = true;
        } else if (arg === '--json-file') {
            if (i + 1 < args.length) {
                parsed.jsonFile = args[i + 1];
                i++; // Skip next argument as it's the value for --json-file
            } else {
                console.error('Error: --json-file requires a value');
                process.exit(1);
            }
        } else if (!arg.startsWith('--')) {
            // This is the provider name
            parsed.providerName = arg;
        }
    }

    return parsed;
}

function main() {
    // Get command line arguments (excluding node and script name)
    const args = process.argv.slice(2);
    
    // Parse arguments
    const parsedArgs = parseArgs(args);
    
    if (parsedArgs.showHelp) {
        showHelp();
        return;
    }

    // Load providers from JSON file
    const providers = loadProviders(parsedArgs.jsonFile);

    // Find the specified provider
    const provider = findProvider(providers, parsedArgs.providerName);

    if (!provider) {
        console.error(`Error: Provider '${parsedArgs.providerName}' not found.`);
        console.error('\nAvailable providers:');
        providers.forEach(p => {
            console.error(`  - ${p.name}`);
        });
        process.exit(1);
    }

    // Get token from environment variable
    const token = getTokenFromEnv(provider.token_env_key);

    // Get base URL - check for OPENAI_BASE_URL if provider is OpenAI
    let baseUrl = provider.base_url;
    if (provider.name.toLowerCase() === 'openai') {
        const openaiBaseUrl = process.env.OPENAI_BASE_URL;
        if (openaiBaseUrl) {
            baseUrl = openaiBaseUrl;
        }
    }

    // Print provider information
    console.log(`Provider: ${provider.name}`);
    console.log(`Base URL: ${baseUrl}`);
    console.log(`Token Environment Key: ${provider.token_env_key || 'None'}`);
    console.log(`Token: ${token}`);
}

// Run the main function if this script is executed directly
if (require.main === module) {
    main();
}

module.exports = {
    loadProviders,
    findProvider,
    getTokenFromEnv,
    main
};
