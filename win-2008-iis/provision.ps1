function Disable-AutoLogon {
	'Disabling auto admin logon' | Write-Host
	reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /d 0 /f
}

function Install-Chocolatey {
	iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')) 
	choco install WindowsAzurePowershell
}

function Install-7zip {
	'Installing 7zip' | Write-Host
	choco install 7zip -y
	choco install 7zip.commandline -y
}

function Install-VSRemoteDebuggingTools {
	'Installing vs remote debug tools' | Write-Host
	choco install vs2015remotetools -y
}

function Disable-SslPowershellError {
	add-type @"
	    using System.Net;
	    using System.Security.Cryptography.X509Certificates;
	    public class TrustAllCertsPolicy : ICertificatePolicy {
	        public bool CheckValidationResult(
	            ServicePoint srvPoint, X509Certificate certificate,
	            WebRequest request, int certificateProblem) {
	            return true;
	        }
	    }
"@

	[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
}

function Install-IIS {
    import-module servermanager
    add-windowsfeature -Name Web-Server,Web-WebServer,Web-Common-Http,Web-Static-Content,Web-Default-Doc,Web-Dir-Browsing,
        Web-Http-Errors,Web-Http-Redirect,Web-App-Dev,Web-Asp-Net,Web-Net-Ext,Web-ASP,Web-ISAPI-Ext,Web-ISAPI-Filter,
        Web-Includes,Web-Health,Web-Http-Logging,Web-Log-Libraries,Web-Request-Monitor,Web-Http-Tracing,Web-ODBC-Logging,
        Web-Security,Web-Basic-Auth,Web-Windows-Auth,Web-Filtering,Web-Performance,Web-Stat-Compression,Web-Dyn-Compression,
        Web-Mgmt-Tools,Web-Mgmt-Console,Web-Mgmt-Compat,Web-Metabase,Web-Lgcy-Mgmt-Console,Web-Ftp-Server,Web-Ftp-Service
}

function Register-AspNet {
	cmd /c %windir%\Microsoft.NET\Framework64\v4.0.30319\aspnet_regiis.exe -i
}

function Install-ChocolateyApps {
	choco install googlechrome -y -r;
	choco install crystalreports2010runtime -y -r --allow-empty-checksums; 
	choco install webdeploy -y -r --allow-empty-checksums; choco install powershell -y -r
}

function Set-ComputerTime {
    tzutil.exe /s 'Central Standard Time'

    Stop-Service W32Time -Force
    W32tm /config /syncfromflags:manual
    W32tm /config /manualpeerlist:"0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org"
    W32tm /config /reliable:no

    Set-Service -Name W32Time -StartupType Automatic
    Start-Service W32Time
    W32tm /resync /force
}

function Install-MSMQ {
    Import-Module -Name ServerManager

    Add-WindowsFeature MSMQ,MSMQ-Services,MSMQ-Server,MSMQ-HTTP-Support,MSMQ-Multicasting
}

function Install-Smtp {
    Import-Module -Name ServerManager

    Add-WindowsFeature SMTP-Server
}


Install-Chocolatey
# needed by WMF 4.0+

choco install dotnet4.5.1 -y

Install-VSRemoteDebuggingTools

if(Get-Command Install-WindowsFeature -ErrorAction SilentlyContinue) {
	Install-WindowsFeature NET-Framework-Core # needs to be here otherwise other packages won't install
}

#Install-IIS

Register-AspNet

Install-ChocolateyApps

Set-ComputerTime

Install-MSMQ

Install-Smtp



