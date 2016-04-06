param(
   [string][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]$borlandVersion,
   [string][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]$borlandFilePath
)

function ExecuteBorland{
    Write-Verbose -Verbose "Starting Execute Borland step"
    Write-Verbose -Verbose "Borland path = $borlandFilePath"
    Write-Verbose -Verbose "Borland Version = $borlandVersion" 

    if ($borlandVersion -eq "Borland 5") {
        $fileName = [System.IO.Path]::GetFileNameWithoutExtension($borlandFilePath)
        $filepath = [System.IO.Path]::GetDirectoryName($borlandFilePath)

        $outputpath="-o$filepath\$fileName.Mak"
        $borland6Path = "C:\Program Files (x86)\Borland\CBuilder5\Bin"
        & $borland6Path\bpr2mak.exe $outputpath $borlandFilePath 
        $fileNameMak = $fileName + ".mak"
         Rename-Item $filepath\$fileNameMak $filepath\makefile;
       Set-Location -Path $filepath
       &  "$borland6Path\make.exe" 
        }
        
    elseif ($borlandVersion -eq "Borland 6") {
        $fileName = [System.IO.Path]::GetFileNameWithoutExtension($borlandFilePath)
        $filepath = [System.IO.Path]::GetDirectoryName($borlandFilePath)

        $outputpath="-o$filepath\$fileName.Mak"
        $borland6Path = "C:\Program Files (x86)\Borland\CBuilder6\Bin"
        & $borland6Path\bpr2mak.exe $outputpath $borlandFilePath 
        $fileNameMak = $fileName + ".mak"
         Rename-Item $filepath\$fileNameMak $filepath\makefile;
       Set-Location -Path $filepath
       &  "$borland6Path\make.exe" 
        }
    elseif ($borlandVersion -eq "Borland 7") {
        $env:BDS="C:\Program Files (x86)\CodeGear\RAD Studio\5.0"       
        Write-Verbose -Verbose "Setting environment for using CodeGear RAD Studio tools"
        & msbuild $borlandFilePath /p:Configuration=Release /p:BDS="C:\Program Files (x86)\CodeGear\RAD Studio\5.0" /p:BDSCOMMONDIR="C:\Users\Public\Documents\RAD Studio\5.0" /p:FrameworkDir="C:\Windows\Microsoft.NET\Framework\v2.0.50727"
    }

         if ($LASTEXITCODE){
        Write-Error "Borland task failed"
        exit $LASTEXITCODE
}
}

ExecuteBorland