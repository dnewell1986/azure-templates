Set-ExecutionPolicy RemoteSigned

iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')) 
choco install WindowsAzurePowershell -y