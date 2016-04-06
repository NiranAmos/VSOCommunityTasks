param(
    [string]$userName,
    [string]$password,
    [string]$groupUsers,
    [string]$manager,
    [string]$SMTPServer,
    [string]$SMTPPort
)



function buildReport
{

    If ($env:BUILD_QUEUEDBY.ToLower().Contains("tfs"))
    {
       break
    }


    if(Test-Path "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\CommonExtensions")
    {
        Add-Type -Path "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\Microsoft.TeamFoundation.WorkItemTracking.Client.dll"
        Add-Type -Path "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\Microsoft.TeamFoundation.VersionControl.Client.dll"
        #Add-Type -Path "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\Microsoft.TeamFoundation.Build.Client.dll"
        [Void][Reflection.Assembly]::Load("Microsoft.TeamFoundation.WorkItemTracking.Client, Version=14.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
    }
    else
    {
        Add-Type -Path "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\ReferenceAssemblies\v2.0\Microsoft.TeamFoundation.VersionControl.Client.dll"
        Add-Type -Path "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\ReferenceAssemblies\v2.0\Microsoft.TeamFoundation.WorkItemTracking.Client.dll"
        Add-Type -Path "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\ReferenceAssemblies\v2.0\Microsoft.TeamFoundation.Client.dll"
        #Add-Type -Path "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\ReferenceAssemblies\v2.0\Microsoft.TeamFoundation.Build.Client.dll"
    }    

    #$userName = "qognify\tfs2buildprd"
    #$password = "ramonM0ntoya"
    $secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
    $creden = New-Object System.Management.Automation.PSCredential ($userName, $secpasswd)
    $server = [Microsoft.TeamFoundation.Client.TeamFoundationServerFactory]::GetServer("http://tfs.qognify.com:8080/tfs/Surveillance_Collection")
    $vcServer = $server.GetService([Microsoft.TeamFoundation.VersionControl.Client.VersionControlServer])
               
               
    #$buildServer = $server.GetService([Microsoft.TeamFoundation.Build.Client.IBuildServer])
    #$URI = New-Object System.Uri("vstfs:///Build/Build/6151")
    #$buildDetail = $buildServer.GetBuild($URI)


    $build = Invoke-RestMethod -Uri http://tfs.qognify.com:8080/tfs/Surveillance_Collection/ALM/_apis/build/builds/6182/timeline?api-version=2.0 -Credential $creden

    $changesetStr = $env:BUILD_SOURCEVERSION
    $changeset = $vcServer.GetChangeset($changesetStr.Remove(0,1))
    $comment = $changeset.Comment
    $buildLink = "<a href=http://tfs.qognify.com:8080/tfs/Surveillance_Collection/$env:SYSTEM_TEAMPROJECT/_build#_a=summary&buildId=$env:BUILD_BUILDID>$env:BUILD_BUILDNUMBER</a>" 
   
    [System.Array]$failed = ($build.records | where {$_.result -match "failed" -and (-not [string]::IsNullOrEmpty($_.issues.message))})
    if($failed.count -gt 0)
    {
        $status = "Failed"
        $errors = New-Object System.Collections.ArrayList
        $failed | %{$errors.add("<p style='font-size:20px;color:red;margin-left: 1cm;font-family:Calibri;'><b>Task -</b> " + $_.name + ($_.issues | %{"<br>&nbsp;&nbsp;" + "*)" + $_.message}) + "</p>")}
    }
    else
    {
        $status = "Succeeded"
    }
    if($errors.Count -gt 0)
    {
        $errorLabel = "Errors:"
    }
    else
    {
        $errorLabel = ""
    }
    if(-not [system.string]::IsNullOrWhiteSpace($groupUsers))
    {
        $To = $groupUsers.Split(";")
    }
    if(-not [system.string]::IsNullOrWhiteSpace($manager))
    {
        $To += $manager.Split(";")
    }

    $From = "ReportBuilder@qognify.com"
    $Attachment = "C:\temp\buildDetails.txt"
    #$To = "henrh@codevalue.net"
    #$SMTPServer = "mail.qognify.com"
    #$SMTPPort = 25
    $Subject = "Build Report"
    $Body = 
    "
    <p style='font-size:30px;color:red;text-align:center;font-family:Calibri;'><b>$env:BUILD_DEFINITIONNAME Build $status!</b></p>
    <p style='font-size:20px;font-family:Calibri;'><b>Triggering Change-set:</b> $env:BUILD_SOURCEVERSION</p>
    <p style='font-size:20px;font-family:Calibri;'><b>CI By:</b> $env:BUILD_QUEUEDBY </p>
    <p style='font-family:Calibri;'><b>CI Comment:</b> $comment </p>
    <p style='font-family:Calibri;'><b>Build Report on TFS:</b> $buildLink </p>
    <p style='font-size:20px;font-family:Calibri;'><b>$errorLabel</b></p>
    $errors
    " 
    
    Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -BodyAsHtml -UseSsl -Credential $creden  #-Attachments $Attachment
}

buildReport