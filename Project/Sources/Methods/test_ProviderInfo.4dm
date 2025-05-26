//%attributes = {}

// Test method for ProviderInfo class
// This demonstrates how to use the ProviderInfo class

var $providerInfo: cs.ProviderInfo
var $info: Object
var $infoText: Text

// Create an instance of the ProviderInfo class

LOG EVENT(Into system standard outputs;"Starting ProviderInfo tests...")
$providerInfo:=cs.ProviderInfo.new()

// Set custom JSON file path if needed (optional)
// $providerInfo.jsonFilePath:="custom_providers.json"

// Test 1: Get OpenAI provider info (default)
LOG EVENT(Into system standard outputs;"Test 1: Default OpenAI provider info")
$info:=$providerInfo.getProviderInfo(""; "")  // Empty strings use defaults
If ($info#Null)
	ALERT("Test 1 - Default OpenAI:\\n"+\
		"Provider: "+$info.provider+"\\n"+\
		"Base URL: "+$info.baseUrl+"\\n"+\
		"Token Env Key: "+$info.tokenEnvKey+"\\n"+\
		"Token: "+$info.token)
End if

// Test 2: Get Anthropic provider info
LOG EVENT(Into system standard outputs;"Test 2: Anthropic provider info")
$info:=$providerInfo.getProviderInfo("Anthropic"; "")
If ($info#Null)
	ALERT("Test 2 - Anthropic:\\n"+\
		"Provider: "+$info.provider+"\\n"+\
		"Base URL: "+$info.baseUrl+"\\n"+\
		"Token Env Key: "+$info.tokenEnvKey+"\\n"+\
		"Token: "+$info.token)
End if

// Test 3: Use the display method (shows alert directly)
LOG EVENT(Into system standard outputs;"Test 3: Display provider info for Ollama")
$providerInfo.displayProviderInfo("Ollama"; "")

// Test 4: Get formatted text instead of showing alert
LOG EVENT(Into system standard outputs;"Test 4: Get formatted text for OpenAI")
$infoText:=$providerInfo.getProviderInfoText("OpenAI"; "")
ALERT("Test 4 - Formatted Text:\\n"+$infoText)

// Test 5: Test with invalid provider name
LOG EVENT(Into system standard outputs;"Test 5: Invalid provider name")
$info:=$providerInfo.getProviderInfo("InvalidProvider"; "")
// This will show an error alert with available providers
