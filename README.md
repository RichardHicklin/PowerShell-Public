# PowerShell-Public
Open share for public powershell

Get-WebContent

.SYNOPSIS
File download manager for PowerShell

.DESCRIPTION
This function is designed to pull files by extension type from a URL. it will create a folder tree based on the
links of the URL and then change directory in to each folder an pulls all files of the specified type into it before moving up and on to the next folder.

PARAMETERS

-DownloadPathParam the location on the local device to save all the files to.

-URLParam Location of the website to pull the files from.

-FileExtensionParam Type of file to pull, ie RPM, ZIP
      
.EXAMPLE

Single use

Get-WebContent -DownloadPathParam D:\TestFolder -URLParam https://repo.powerdns.com/centos/x86_64/7Server/ -FileExtensionParam RPM

.EXAMPLE

Multi use

this allows for a custom set of sites to be managed via a csv file. works by pulling values and running the function at the list

Import-Csv c:\example.csv | Get-WebContent

the SCV will have to be contructed as a CSV file and have the Colum header values as 

"DownloadPathParam","URLParam","FileExtensionParam"

and content seperated with "," example

"DownloadPathParam","URLParam","FileExtensionParam"
"D:\DemoA","https://repo.powerdns.com/centos/x86_64/7Server/auth-40","RPM",
"D:\DemoB","https://repo.powerdns.com/centos/x86_64/7Server/auth-41","RPM",
