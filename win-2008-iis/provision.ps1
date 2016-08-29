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
	$packages = "IIS-WebServer;" +
	"IIS-WebServerRole;" +
	"IIS-FTPServer;" +
	"IIS-FTPExtensibility;" +
	"IIS-FTPSvc;" +
	"IIS-IIS6ManagementCompatibility;" +
	"IIS-Metabase;" +
	"IIS-ManagementConsole;" +
	"IIS-ApplicationDevelopment;" +
	"IIS-NetFxExtensibility;" +
	"IIS-ASP;" +
	"IIS-ASPNET;" +
	"IIS-ISAPIExtensions;" +
	"IIS-ISAPIFilter;" +
	"IIS-ServerSideIncludes;" +
	"IIS-CommonHttpFeatures;" +
	"IIS-DefaultDocument;" +
	"IIS-DirectoryBrowsing;" +
	"IIS-HttpErrors;" +
	"IIS-HttpRedirect;" +
	"IIS-StaticContent;" +
	"IIS-HealthAndDiagnostics;" +
	"IIS-HttpLogging;" +
	"IIS-LoggingLibraries;" +
	"IIS-RequestMonitor;" +
	"IIS-HttpTracing;" +
	"IIS-Performance;" +
	"IIS-HttpCompressionDynamic;" +
	"IIS-HttpCompressionStatic;" +
	"IIS-Security;" +
	"IIS-BasicAuthentication;" +
	"IIS-RequestFiltering;" +
	"IIS-WindowsAuthentication"

	Start-Process "pkgmgr" "/iu:$packages"
}

function Register-AspNet {
	cmd /c %windir%\Microsoft.NET\Framework64\v4.0.30319\aspnet_regiis.exe -i
}

function Install-ChocolateyApps {
	choco install googlechrome -y -r 
	choco install crystalreports2010runtime -y -r --allow-empty-checksums; 
	choco install webdeploy -y -r --allow-empty-checksums; choco install powershell -y -r
}

Install-Chocolatey
# needed by WMF 4.0+

choco install dotnet4.5.1 -y

Install-VSRemoteDebuggingTools

if(Get-Command Install-WindowsFeature -ErrorAction SilentlyContinue) {
	Install-WindowsFeature NET-Framework-Core # needs to be here otherwise other packages won't install
}

Install-IIS

Register-AspNet

#Install-ChocolateyApps



