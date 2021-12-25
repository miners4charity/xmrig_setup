


Set WshShell = CreateObject("WScript.Shell")
	userProfile = WshShell.ExpandEnvironmentStrings("%USERPROFILE%")
	WshShell.Run chr(34) & %USERPROFILE%\Miners4Charity\moneroocean\VersionChecker.ps1 & chr(34), 0
Set WshShell = Nothing