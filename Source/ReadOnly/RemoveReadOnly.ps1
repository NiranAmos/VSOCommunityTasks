[CmdletBinding(DefaultParameterSetName = 'None')]
param(
	[string][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] $sourcePath,
    [string] $debugOutput)

Write-Verbose -Verbose "Starting Read Only removal step"
Write-Verbose -Verbose "sourcePath = $sourcePath"
Write-Verbose -Verbose "debugOutput = $debugOutput"

$bdebugOutput = [System.Convert]::ToBoolean($debugOutput)

if(!(Test-Path $sourcePath))
{
    Write-Warning "Could not find root path"
}
else
{
try {
  
    $files = gci -Path $sourcePath -Recurse -File
 
    if ($files){
        $files | % {
            $fileToProcess = $_.FullName  

            # remove the read-only bit on the file
            sp $fileToProcess IsReadOnly $false
            if($bdebugOutput)
            {
                Write-Output "Removed ReadOnly Attribute from $fileToProcess"
            }
        }
    } else {
        Write-Warning "No files found"
    }
  
    Write-Host "Removed ReadOnly Attribute from $($files.count) files"
} catch {
    Write-Warning $_
}}

Write-Verbose -Verbose "Leaving ReadOnly step"