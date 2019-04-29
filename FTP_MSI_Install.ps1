#==========================================================================================================================================================================
# LANGUAGE:      PowerShell
# SCRIPT NAME:   Puppet.ps1
# AUTHOR:        Richard Hicklin
# COMPONENT:     N/A
# VERSIONS:      Alpha
# DOCUMENTS:     
# NOTES:         This Powershell script uses the FTP to tranfers a MSI and then install it localy.
# DEVELOPMENT:   N\A
#
#
#==========================================================================================================================================================================

  	
# Create Support Directory

Write-Verbose "Creating and Setting Support Folder"
$strSupportPath = "C:\FTP"
If(!(Test-Path $strSupportPath))
    {New-Item -Type Directory $strSupportPath | Out-Null}

# FTP File

#variables to change to your needs:
$ftpPath = 'ftp://ftp.site.com/folder/'
$ftpUser = 'user'
$ftpPass = 'pass'
$localPath = 'C:\FTP'


# FTP Function
function Get-FtpDir ($url, $credentials)
{
  $request = [Net.FtpWebRequest]::Create($url)
  if ($credentials) { $request.Credentials = $credentials }
  $request.Method = [System.Net.WebRequestMethods+FTP]::ListDirectory
  (New-Object IO.StreamReader $request.GetResponse().GetResponseStream()).ReadToEnd() -split "`r`n"
}

# FTP Download
$webclient = New-Object System.Net.WebClient 
$webclient.Credentials = New-Object System.Net.NetworkCredential($ftpUser,$ftpPass)  
$webclient.BaseAddress = $ftpPath

Get-FTPDir $ftpPath $webclient.Credentials |
  ? { $_ -like '*.msi' } |
  % {
	  $webClient.DownloadFile($_, $localPath+$_)
    # DownloadFile does not provide a success state, so we have to check for the file name
    if (Test-Path ($localPath+$_)) { Remove-FtpFile ($ftpPath+$_) $webclient.Credentials }
  }
  
#Execute the puppet agent

Write-Verbose "Create processstartinfo for Puppet command"
    $ObjProcess = new-object System.Diagnostics.ProcessStartInfo
    $ObjProcess.filename = "$strSupportPath\<File>.msi"

#Build command line

{$ObjProcess.arguments ="/qn /norestart /i puppet-agent-<VERSION>-x64.msi PUPPET_MASTER_SERVER=puppet.example.com"}
    $ObjProcess.UseShellExecute = $false
    $ObjProcess.RedirectStandardError = $True
    $ObjProcess.RedirectStandardOutput = $True
    $Erroractionpreference="Continue"
    $Error.Clear()

    Write-Verbose "Execute msi command"
    $VarCMD = [System.Diagnostics.Process]::Start($ObjProcess)
    Write-Verbose "Do (Nothing) MSI"
    do{} until ($VarCMD.HasExited -eq $True)

# Error catching

    $VarErrCount = $Error.count
	$VarErrMess = $Error[0].Exception.message
    Write-Verbose "`$VarErrCount = $VarErrCount"
    "`$VarCMD.ExitCodet = "+$VarCMD.ExitCode | Write-Verbose
        
    If($VarErrCount -gt 0)
    {
    Write-Verbose "Issue running Puppet install command"}
	Else
	{
    Write-Verbose "Cmd completed"}
