//%attributes = {}

property jsonFilePath: Text

Class constructor()
	
	This.jsonFilePath:=Folder(fk database folder).file("providers.json").path
	
// Load provider configurations from JSON file
Function loadProviders($jsonFilePath: Text): Collection
	
	var $file: 4D.File
	var $providers: Collection
	var $fileContent: Text
	
	If ($jsonFilePath="")
		$jsonFilePath:=This.jsonFilePath
	End if
	
	$file:=File($jsonFilePath)
	
	If (Not($file.exists))
		ALERT("Error: File '"+$jsonFilePath+"' not found.")
		return []
	End if
	
    // Try
		$fileContent:=$file.getText()
        
		$providers:=JSON Parse($fileContent)
		
		If ($providers=Null)
			$providers:=[]
		End if
		
	//Catch
	//	ALERT("Error: Invalid JSON in '"+$jsonFilePath+"': "+Last errors[0].message)
	//	return []
	//End try
	
	return $providers

// Find a provider by name (case-insensitive)
function findProvider($providers: Collection; $providerName: Text): Object
	
	var $provider: Object
	var $index: Integer
	
	If ($providerName="")
		$providerName:="OpenAI"
	End if
	
	For each ($provider; $providers)
		If ($provider.name#Null)
			If (Lowercase($provider.name)=Lowercase($providerName))
				return $provider
			End if
		End if
	End for each
	
	return Null

// Retrieve token from environment variable
function getTokenFromEnv($tokenEnvKey: Text): Text
	
	var $token: Text
	
	If ($tokenEnvKey="")
		return "No token required"
	End if
	
	$token:=Get environment variable($tokenEnvKey)
	
	If ($token#"")
		return $token
	Else 
		return "Environment variable '"+$tokenEnvKey+"' not found"
	End if

// Get base URL with OpenAI override support
function getBaseUrl($provider: Object): Text
	
	var $baseUrl: Text
	var $openaiBaseUrl: Text
	
	$baseUrl:=$provider.base_url
	
	If (Lowercase($provider.name)="openai")
		$openaiBaseUrl:=Get environment variable("OPENAI_BASE_URL")
		If ($openaiBaseUrl#"")
			$baseUrl:=$openaiBaseUrl
		End if
	End if
	
	return $baseUrl

// Get provider information (main function equivalent to Python script)
function getProviderInfo($providerName: Text; $jsonFilePath: Text): Object
	
	var $providers: Collection
	var $provider: Object
	var $result: Object
	var $token: Text
	var $baseUrl: Text
	var $availableProviders: Collection
	var $index: Integer
	
	// Set defaults
	If ($providerName="")
		$providerName:="OpenAI"
	End if
	
	If ($jsonFilePath="")
		$jsonFilePath:=This.jsonFilePath
	End if
	
	// Load providers from JSON file
	$providers:=This.loadProviders($jsonFilePath)
	
	If ($providers.length=0)
		return Null
	End if
	
	// Find the specified provider
	$provider:=This.findProvider($providers; $providerName)
	
	If ($provider=Null)
		// Build list of available providers for error message
		$availableProviders:=$providers.extract("name")
		
		ALERT("Error: Provider '"+$providerName+"' not found.\\nAvailable providers: "+$availableProviders.join(", "))
		return Null
	End if
	
	// Get token from environment variable
	$token:=This.getTokenFromEnv($provider.token_env_key)
	
	// Get base URL with potential OpenAI override
	$baseUrl:=This.getBaseUrl($provider)
	
	// Build result object
	$result:=New object
	$result.provider:=$provider.name
	$result.baseUrl:=$baseUrl
	$result.tokenEnvKey:=$provider.token_env_key
	$result.token:=$token
	
	return $result

// Display provider information
function displayProviderInfo($providerName: Text; $jsonFilePath: Text)
	
	var $info: Object
	
	$info:=This.getProviderInfo($providerName; $jsonFilePath)
	
	If ($info#Null)
		ALERT("Provider: "+$info.provider+Char(Carriage return)+\
			"Base URL: "+$info.baseUrl+Char(Carriage return)+\
			"Token Environment Key: "+($info.tokenEnvKey#"" ? $info.tokenEnvKey : "None")+Char(Carriage return)+\
			"Token: "+$info.token)
	End if

// Alternative method that returns formatted text instead of showing alert
function getProviderInfoText($providerName: Text; $jsonFilePath: Text): Text
	
	var $info: Object
	var $result: Text
	
	$info:=This.getProviderInfo($providerName; $jsonFilePath)
	
	If ($info#Null)
		$result:="Provider: "+$info.provider+Char(Carriage return)
		$result:=$result+"Base URL: "+$info.baseUrl+Char(Carriage return)
		$result:=$result+"Token Environment Key: "+($info.tokenEnvKey#"" ? $info.tokenEnvKey : "None")+Char(Carriage return)
		$result:=$result+"Token: "+$info.token
		
		return $result
	Else 
		return "Provider information not found"
	End if
