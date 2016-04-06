param (
   [string][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]$installShieldVersion,
   [string][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]$filePath
)

Write-Verbose 'Entering InstallShield.ps1'
Write-Verbose "installShieldVersion = $installShieldVersion"
Write-Verbose "filePath = $filePath"

# Import the Task.Common dll that has all the cmdlets we need for Build
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"


 if ($installShieldVersion -eq "InstallShield Dev 7+ (MSI)") {
        $installShieldPath = "C:\Program Files (x86)\InstallShield X\System\ISBuild.exe"
        }
    elseif ($installShieldVersion -eq "InstallShield 2013") {
    $installShieldPath = "C:\Program Files (x86)\InstallShield\2013\System\IsCmdBld.exe"
    }
    else {
        $installShieldPath = "C:\Program Files (x86)\InstallShield\2014\System\IsCmdBld.exe"
    }
  
        & $installShieldPath -p $filePath 
        if ($LASTEXITCODE){
        Write-Error "InstallShield task failed"
        exit $LASTEXITCODE
      }

