$USERPROFILE = $env:USERPROFILE
$ServerFile = New-Object System.Net.WebClient; $ServerFile.DownloadFile('https://raw.githubusercontent.com/miners4charity/xmrig_setup/Version.txt', '$USERPROFILE\Miners4Charity\moneroocean\ServerVersion.txt')
$ServerVersion = (Get-Content -Path $USERPROFILE\Miners4Charity\moneroocean\ServerVersion.txt)
$LocalVersion = (Get-Content -Path $USERPROFILE\Miners4Charity\moneroocean\LocalVersion.txt)
if ($LocalVersion -ne $ServerVersion) {
    Invoke-Command -FilePath $USERPROFILE\Miners4Charity\moneroocean\Updater.bat
    Remove-Item -Path $USERPROFILE\Miners4Charity\moneroocean\LocalVersion.txt 
    Rename-Item -NewName LocalVersion.txt -Path $USERPROFILE\Miners4Charity\moneroocean\ServerVersion.txt
    Remove-Item -Path $USERPROFILE\Miners4Charity\moneroocean\ServerVersion.txt 
    Exit-PSSession
}
else {
    Remove-Item -Path $USERPROFILE\Miners4Charity\moneroocean\ServerVersion.txt 
    Exit-PSSession
    }
