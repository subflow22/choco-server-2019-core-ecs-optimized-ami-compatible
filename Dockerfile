FROM mcr.microsoft.com/windows/servercore:10.0.17763.1518-amd64 
	#Supports latest AWS ECS Optimized 2019 Server Core AMI (10.0.17763) as of 10/28/20

MAINTAINER Mike Reilly

SHELL ["powershell", "-NoProfile -InputFormat None -ExecutionPolicy Bypass -Command"]

RUN Add-WindowsFeature Web-Server; \
    Invoke-WebRequest `\
		-UseBasicParsing `\
		-Uri "https://dotnetbinaries.blob.core.windows.net/servicemonitor/2.0.1.10/ServiceMonitor.exe" `\
		-OutFile "C:\ServiceMonitor.exe"; \
	Import-Module ServerManager -Force; \
	Add-WindowsFeature NET-Framework-45-ASPNET; \
    Add-WindowsFeature Web-Net-Ext45; \
    Add-WindowsFeature Web-Asp-Net45; \
    Add-WindowsFeature Web-ISAPI-Ext; \
    Add-WindowsFeature Web-ISAPI-Filter; \
	$env:chocolateyUseWindowsCompression='false'; \
    [System.Net.ServicePointManager]::SecurityProtocol = 3072; \
	Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')); \
	$env:Path += 'C:\ProgramData\chocolatey'; \
	$env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine'); \
	choco install chocolatey.server -y; \
	$env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine'); \
    Remove-Item -Path C:\tools\chocolatey.server\App_Data\Packages\Readme.txt; \	
	New-WebAppPool -Name chocolatey.server; \
    Set-ItemProperty "IIS:\AppPools\chocolatey.server" `\
		-Name "processModel.loadUserProfile" `\
		-Value "True"; \
    Import-Module IISAdministration; \
    Import-Module WebAdministration; \
    Remove-WebSite -Name 'Default Web Site'; \
	$print = (New-SelfSignedCertificate ` \
		-Subject "localhost" `\
		-DnsName "localhost","$env:ComputerName" `\
		-KeyAlgorithm RSA -KeyLength 2048 -KeyUsage DigitalSignature `\
		-CertStoreLocation Cert:\LocalMachine\My).Thumbprint; \
	New-IISSite `\
		-Name "Chocolatey" `\
		-PhysicalPath C:\tools\chocolatey.server `\
		-BindingInformation "*:8443:" `\
		-CertificateThumbPrint $print `\
		-CertStoreLocation "Cert:\LocalMachine\My" `\
		-Protocol https; \
    Set-ItemProperty "IIS:\Sites\Chocolatey" ApplicationPool chocolatey.server;
	
	#embedded script to set apiKey from CHOCOLATEY_API environmental variable, if available, otherwise 'default'
RUN	$script = 'c:\setApiKey.ps1'; \
	'$api = \"$env:CHOCOLATEY_API\"' | Out-File $script -Force; \
	'if ([string]::IsNullOrEmpty(\"$api\")) {$api = \"default\"}' | Out-File $script -Append; \
	'$config = \"C:\tools\chocolatey.server\web.config\"' | Out-File $script -Append; \
	'(Get-Content $config).replace(\"chocolateyrocks\", \"$api\") | Set-Content $config -Force' | Out-File $script -Append; \
	'C:\ServiceMonitor.exe w3svc' | Out-File $script -Append;


EXPOSE 8443

ENTRYPOINT ["powershell", "C:\\setApiKey.ps1"]

