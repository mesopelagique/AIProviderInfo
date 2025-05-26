
property jsonFilePath : Text

Class constructor()
	
	This:C1470.jsonFilePath:=Folder:C1567(fk database folder:K87:14).file("providers.json").path
	
	// Load provider configurations from JSON file
Function loadProviders($jsonFilePath : Text) : Collection
	
	var $file : 4D:C1709.File
	var $providers : Collection
	var $fileContent : Text
	
	If ($jsonFilePath="")
		$jsonFilePath:=This:C1470.jsonFilePath
	End if 
	
	$file:=File:C1566($jsonFilePath)
	
	If (Not:C34($file.exists))
		ALERT:C41("Error: File '"+$jsonFilePath+"' not found.")
		return []
	End if 
	
	// Try
	$fileContent:=$file.getText()
	
	$providers:=JSON Parse:C1218($fileContent)
	
	If ($providers=Null:C1517)
		$providers:=[]
	End if 
	
	//Catch
	//	ALERT("Error: Invalid JSON in '"+$jsonFilePath+"': "+Last errors[0].message)
	//	return []
	//End try
	
	return $providers
	
	// Find a provider by name (case-insensitive)
Function findProvider($providers : Collection; $providerName : Text) : Object
	
	var $provider : Object
	var $index : Integer
	
	If ($providerName="")
		$providerName:="OpenAI"
	End if 
	
	For each ($provider; $providers)
		If ($provider.name#Null:C1517)
			If (Lowercase:C14($provider.name)=Lowercase:C14($providerName))
				return $provider
			End if 
		End if 
	End for each 
	
	return Null:C1517
	
	// Retrieve token from environment variable
Function getTokenFromEnv($tokenEnvKey : Text) : Text
	
	var $token : Text
	
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
Function getBaseUrl($provider : Object) : Text
	
	var $baseUrl : Text
	var $openaiBaseUrl : Text
	
	$baseUrl:=$provider.base_url
	
	If (Lowercase:C14($provider.name)="openai")
		$openaiBaseUrl:=Get environment variable("OPENAI_BASE_URL")
		If ($openaiBaseUrl#"")
			$baseUrl:=$openaiBaseUrl
		End if 
	End if 
	
	return $baseUrl
	
	// Get provider information (main function equivalent to Python script)
Function getProviderInfo($providerName : Text; $jsonFilePath : Text) : Object
	
	var $providers : Collection
	var $provider : Object
	var $result : Object
	var $token : Text
	var $baseUrl : Text
	var $availableProviders : Collection
	var $index : Integer
	
	// Set defaults
	If ($providerName="")
		$providerName:="OpenAI"
	End if 
	
	If ($jsonFilePath="")
		$jsonFilePath:=This:C1470.jsonFilePath
	End if 
	
	// Load providers from JSON file
	$providers:=This:C1470.loadProviders($jsonFilePath)
	
	If ($providers.length=0)
		return Null:C1517
	End if 
	
	// Find the specified provider
	$provider:=This:C1470.findProvider($providers; $providerName)
	
	If ($provider=Null:C1517)
		// Build list of available providers for error message
		$availableProviders:=$providers.extract("name")
		
		ALERT:C41("Error: Provider '"+$providerName+"' not found.\\nAvailable providers: "+$availableProviders.join(", "))
		return Null:C1517
	End if 
	
	// Get token from environment variable
	$token:=This:C1470.getTokenFromEnv($provider.token_env_key)
	
	// Get base URL with potential OpenAI override
	$baseUrl:=This:C1470.getBaseUrl($provider)
	
	// Build result object
	$result:=New object:C1471
	$result.provider:=$provider.name
	$result.baseUrl:=$baseUrl
	$result.tokenEnvKey:=$provider.token_env_key
	$result.token:=$token
	
	return $result
	
	// Display provider information
Function displayProviderInfo($providerName : Text; $jsonFilePath : Text)
	
	var $info : Object
	
	$info:=This:C1470.getProviderInfo($providerName; $jsonFilePath)
	
	If ($info#Null:C1517)
		ALERT:C41("Provider: "+$info.provider+Char:C90(Carriage return:K15:38)+\
			"Base URL: "+$info.baseUrl+Char:C90(Carriage return:K15:38)+\
			"Token Environment Key: "+($info.tokenEnvKey#"" ? $info.tokenEnvKey : "None")+Char:C90(Carriage return:K15:38)+\
			"Token: "+$info.token)
	End if 
	
	// Alternative method that returns formatted text instead of showing alert
Function getProviderInfoText($providerName : Text; $jsonFilePath : Text) : Text
	
	var $info : Object
	var $result : Text
	
	$info:=This:C1470.getProviderInfo($providerName; $jsonFilePath)
	
	If ($info#Null:C1517)
		$result:="Provider: "+$info.provider+Char:C90(Carriage return:K15:38)
		$result:=$result+"Base URL: "+$info.baseUrl+Char:C90(Carriage return:K15:38)
		$result:=$result+"Token Environment Key: "+($info.tokenEnvKey#"" ? $info.tokenEnvKey : "None")+Char:C90(Carriage return:K15:38)
		$result:=$result+"Token: "+$info.token
		
		return $result
	Else 
		return "Provider information not found"
	End if 
	