param(
    [string]$buildName,
    [string]$userName,
    [string]$password
)


function ChainingBuild{

    #if ([Environment]::UserName -ne 'Qc Merge'){
    #$username = "qognify\tfs2buildprd"
    #$password = "ramonM0ntoya" | convertto-securestring
    #$cred = new-object -typename System.Management.Automation.PSCredential
    #         -argumentlist $username, $password
    #
    ##$cred = Get-Credential #TODO make sure the credentials are not needed when running with the build service user (tfs2prd or whatever)
    #}
    #
    #else {
    #    $cred = Get-Credential
    #    Write-Host "not tfs2buildprd"
    #}

    #$userName = "qognify\tfs2buildprd"
    #$password = "ramonM0ntoya"
    $secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
    $creden = New-Object System.Management.Automation.PSCredential ($userName, $secpasswd)

    $collection =  "http://tfs.qognify.com:8080/tfs/Surveillance_Collection"
    $buildDefinitionURI = "http://tfs.qognify.com:8080/tfs/Surveillance_Collection/$env:SYSTEM_TEAMPROJECT/_apis/build/builds?api-version=2.0"
    $responseDefinition = Invoke-RestMethod -Uri $collection/$env:SYSTEM_TEAMPROJECT/_apis/build/definitions -Credential $creden

    $buildDefinition = $responseDefinition.value | Where-Object name -eq $buildName

    $BuildReqBodyJson= @{"definition"=@{"id"=$buildDefinition.id};Priority="Normal";reason="Manual"} | ConvertTo-Json -Compress

    $buildOutput = Invoke-RestMethod -Method Post -Uri $buildDefinitionURI -Credential $creden -ContentType 'application/json' -Body $BuildReqBodyJson

}

ChainingBuild