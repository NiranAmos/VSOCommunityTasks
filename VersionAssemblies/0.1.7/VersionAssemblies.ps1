[CmdletBinding(DefaultParameterSetName = 'None')]
param(
	[string][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] $sourcePath,
    [string][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] $filePattern,
    [string][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()] $buildRegex,
    [string]$replaceRegex,
    [string]$buildNumber = $env:BUILD_BUILDNUMBER,
    [string]$excludedProjects
)

Write-Verbose -Verbose "Starting Version Assemblies step"

Write-Verbose -Verbose "sourcePath = $sourcePath"
Write-Verbose -Verbose "filePattern = $filePattern"
Write-Verbose -Verbose "buildRegex = $buildRegex"
Write-Verbose -Verbose "replaceRegex = $replaceRegex"
Write-Verbose -Verbose "buildNumber = $buildNumber"


if ($replaceRegex -eq ""){
    $replaceRegex = $replaceRegex = 'AssemblyFileVersion\("' + $buildRegex + '"\)'
}
Write-Verbose -Verbose "Using $replaceRegex as the replacement regex"
    $excludFiles = @()
    if(-not [system.string]::IsNullOrWhiteSpace($excludedProjects))
    {
        $excludFiles = $excludedProjects.Split(";")
    }
 Write-Verbose -Verbose "excludedProjects = $excludFiles"

if ($buildNumber -match $buildRegex -ne $true) {
    Write-Warning "Could not extract a version from [$buildNumber] using pattern [$buildRegex]"
} else {
    try {
        $extractedBuildNumber = $Matches[0]
        $fileVersion = 'AssemblyFileVersion("' + $extractedBuildNumber + '")'
        Write-Host "Using version $extractedBuildNumber in folder $sourcePath"
  
        $files = gci -Path $sourcePath -Filter $filePattern -Recurse
 
        if ($files){
            $files | % {
                $fileToChange = $_
                if(($excludFiles | %{$fileToChange.Directory.FullName.contains($_)}) -contains $true)
                {
                    Write-Host "  -> Skipping $($fileToChange.FullName)"
                }
                else
                {
                    Write-Host "  -> Changing version in $($fileToChange.FullName)"
                 
                    # remove the read-only bit on the file
                    sp $fileToChange.FullName IsReadOnly $false
  
                    # run the regex replace
                    (gc $fileToChange.FullName) | % { $_ -replace $replaceRegex, $fileVersion } | sc $fileToChange.FullName 
                }
            }
        } else {
            Write-Warning "No files found"
        }
  
        Write-Host "Replaced version in $($files.count) files"
    } catch {
        Write-Warning $_
    }
}

Write-Verbose -Verbose "Leaving Version Assemblies step"