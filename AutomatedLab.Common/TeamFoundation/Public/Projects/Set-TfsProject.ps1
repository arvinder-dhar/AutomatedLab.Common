function Set-TfsProject
{
    
    param
    (
        [Parameter(Mandatory)]
        [string]
        $InstanceName,

        [Parameter()]
        [string]
        $CollectionName = 'DefaultCollection',

        [ValidateRange(1, 65535)]
        [uint32]
        $Port,

        [string]
        $ApiVersion = '2.0',

        [Parameter(Mandatory)]
        [string]
        $ProjectGuid,

        [string]
        $NewName,

        [string]
        $NewDescription,

        [switch]
        $UseSsl,

        [Parameter(ParameterSetName = 'Tfs')]
        [pscredential]
        $Credential,
        
        [Parameter(ParameterSetName = 'Vsts')]
        [string]
        $PersonalAccessToken
    )

    $requestUrl = if ($UseSsl) {'https://' } else {'http://'}
    $requestUrl += if ( $Port -gt 0)
    {
        '{0}{1}/{2}/_apis/projects/{3}' -f $InstanceName, ":$Port", $CollectionName, $ProjectGuid
    }
    else
    {
        '{0}/{1}/_apis/projects/{2}' -f $InstanceName, $CollectionName, $ProjectGuid
    }
    
    if ($ApiVersion)
    {
        $requestUrl += '?api-version={0}' -f $ApiVersion
    }

    $payload = @{
        name        = $NewName
        description = $NewDescription
    }

    $requestParameters = @{
        Uri         = $requestUrl
        Method      = 'Patch'
        ContentType = 'application/json'
        Body        = ($payload | ConvertTo-Json)
        ErrorAction = 'Stop'
    }

    if ($Credential)
    {
        $requestParameters.Credential = $Credential
    }
    else
    {
        $requestParameters.Headers = @{ Authorization = Get-TfsAccessTokenString -PersonalAccessToken $PersonalAccessToken }
    }

    try
    {
        $result = Invoke-RestMethod @requestParameters
        Write-Verbose ('Project {0} renamed to {1}' -f $ProjectGuid, $NewName)
    }
    catch
    {
        Write-Error -ErrorRecord $_
    }
}
