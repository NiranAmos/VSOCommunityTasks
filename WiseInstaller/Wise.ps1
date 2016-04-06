param (
   [string][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]$wiseFilePath,
   [string]$variablesListPath
)

Write-Verbose 'Entering Wise.ps1'
Write-Verbose -Verbose "filePath = $filePath"

# Import the Task.Common dll that has all the cmdlets we need for Build
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"


 if ($filePath -eq "") {
        Write-Error "File path is empty!"
        exit $LASTEXITCODE
        }
    elseif($variablesListPath -eq "") {
       & "C:\Program Files (x86)\Wise Installation System\Wise32.exe"  /c "$wiseFilePath"
    }
    else{
        & "C:\Program Files (x86)\Wise Installation System\Wise32.exe"  /c /d="$variablesListPath" "$wiseFilePath"
    }
  
        if ($LASTEXITCODE){
        Write-Error "Wise task failed"
        exit $LASTEXITCODE
      }
