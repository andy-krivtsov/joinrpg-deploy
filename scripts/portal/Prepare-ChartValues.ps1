param(
    [Parameter(Mandatory=$true)]
    [string] $VaultName,

    [Parameter(Mandatory=$false)]
    [string] $Prefix = "",

    [Parameter(Mandatory=$true)]
    [string] $Path,

    [Parameter(Mandatory=$false)]
    [string] $ImageRegistry = "joinrpg.azurecr.io",

    [Parameter(Mandatory=$false)]
    [string] $ImageName = "joinrpg.portal",

    [Parameter(Mandatory=$false)]
    [string] $ImageTag = "latest",

    [Parameter(Mandatory=$true)]
    [string] $IngressHost,

    [Parameter(Mandatory=$false)]
    [string] $IngressPath = "/",

    [Parameter(Mandatory=$false)]
    [string] $ConnectionStringSecretName = "ConnectionStrings--DefaultConnection"
)

Install-Module -Name "powershell-yaml" -AcceptLicense -Force -Verbose -Scope CurrentUser

##=================================================================================
## Script for preparing values.yaml for deployment chart
## Source: Azure Key Vault (secrets) and parameters (host & path)
##=================================================================================

$data = @{
    secrets = @{}

    ingress = @{
        host = $IngressHost
        path = $IngressPath
    }

    image = @{
        registry = $ImageRegistry
        name = $ImageName
        tag = $ImageTag
    }
}

Write-Host "Parameters: ingress hostname/path: ${IngressHost}${IngressPath}"
Write-Host "Parameters: full image name: ${imageRegistry}/${imageName}:${imageTag}"

$secrets = Get-AzKeyVaultSecret -VaultName $VaultName  -Name "$Prefix*" -WarningAction SilentlyContinue

Write-Host "Read secrets from KeyVault: $VaultName, prefix: $Prefix"

$secrets | %{
    $name = $_.Name
    $value = Get-AzKeyVaultSecret -VaultName $VaultName -Name $name -AsPlainText -WarningAction SilentlyContinue

    #Save DB Connection String as variable for next pipeline steps
    if( $name -eq ($Prefix + $ConnectionStringSecretName) )
    {
        Write-Host "Found the database connections string secret with name $name, save to pipeline variable 'DefaultConnection'"   
        Write-Host "##vso[task.setvariable variable=DefaultConnection;issecret=true]$value"        
    }
    
    #Save to the secrets array
    $name = $name.Substring($Prefix.Length).Replace("--","__");

    $data.secrets.Add($name, $value);
    Write-Host "  Found Secret: $name"
}


#Write found secrets to the values file
$data | ConvertTo-Yaml | Out-File -FilePath $Path -Encoding utf8 -Force
