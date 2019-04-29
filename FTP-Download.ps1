#============================================================================================
#LANGUAGE:      PowerShell V4.0
#SCRIPT NAME:   FTP-Download
#AUTHOR:        Richard Hicklin
#COMPONENT:     N\A
#VERSIONS:      1.0
#DOCUMENTS:     N\A
#ACMS MEDIA ID: N\A
#NOTES:         This Powershell Script will uploads and take a date backup
#               all files in a given ftp directory 
#DEVELOPMENT:   DEV
#============================================================================================
#Setup Default Dolders
#Setup FTP Folders
if(!(Test-Path -Path "C:\FTP" )){
    New-Item -ItemType directory -Path "C:\FTP"
}
if(!(Test-Path -Path "C:\FTP\Download" )){
    New-Item -ItemType directory -Path "C:\FTP\Download"
}
if(!(Test-Path -Path "C:\FTP\Uploads" )){
    New-Item -ItemType directory -Path "C:\FTP\Uploads"
}
if(!(Test-Path -Path "C:\FTP\Backup_Uploads" )){
    New-Item -ItemType directory -Path "C:\FTP\Backup_Uploads"
}
if(!(Test-Path -Path "C:\FTP\Backup_Download" )){
    New-Item -ItemType directory -Path "C:\FTP\Backup_Download"
}
# Grab the date in a Year/Month/Day format for backups
$Date=Get-Date -UFormat "%Y_%m_%d@%H-%M-Backup\"

# we specify the directory where all files that we want to upload  
$Dir="C:\ftp\uploads" 
$BackupUploadsRoot="C:\FTP\Backup_Uploads\"

# Create the backup folder
New-item $BackupUploadsRoot\$Date -ItemType directory -Force

# ftp server make sure that i only remove the defualt dir from the path
$ftp = "ftp://192.168.0.100/Inbound/" 
$user = "ftpuser" 
$pass = "password"  

# Create the ftp session 
$webclient = New-Object System.Net.WebClient 
$webclient.Credentials = New-Object System.Net.NetworkCredential($user,$pass)  
 
#list every file 
foreach($item in (dir $Dir "*.*")){ 
"Uploading $item..." 
    try
    {
    $uri = New-Object System.Uri($ftp+$item.Name) 
    write-verbose $uri
    $webclient.UploadFile($uri,$item.FullName)
    }
    catch
    {
    "Error!"
    }
        try
        {
        #Move the file to a backup folder
        "FTP sent Moving $item... to $BackupUploadsRoot\$Date"
        copy-item $Dir\$item $BackupUploadsRoot\$Date -Force
        }
        catch
        {
        "Error!"
        }
    try
    {
    "Remove the file $item...."
    Remove-Item $Dir\$item -Force
    }
    catch
    {
    "Error!"
    }
 }
