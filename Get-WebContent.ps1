Function Get-WebContent {

<#
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


.NOTES

License

MIT License

Copyright (c) 2019 Richard Hicklin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Version: 1.0
Author: Richard.Hicklin
#>

[cmdletbinding()]
param (
        [Parameter( Position=0,Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)][string]$DownloadPathParam,

        [Parameter( Position=1,Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$true)][string]$URLParam,

        [Parameter( Position=2,Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)][string]$FileExtensionParam
	   )
Begin 
    {
    # Start StopWatch for timing
    $Stopwatch = [system.diagnostics.stopwatch]::startNew()
    # Out Put start of script
    write-host -ForegroundColor Green "======================="
    write-host -ForegroundColor Green "Start of Function"
    write-host -ForegroundColor Green "======================="
    }
    Process  
            {
            # Verbose output for testing
		    write-verbose "Params passed in"
		    Write-Verbose "Down Load root folder: $DownloadPathParam"
		    Write-Verbose "Root URL: $URLParam"
		    Write-Verbose "File Type: $FileExtensionParam"

            # Setup Folder Structure
            IF(!(Test-Path -Path "$DownloadPathParam" ))
	            {
			    New-Item -ItemType directory -Path $DownloadPathParam.Trimstart("*\")
			    Write-Host "New folder created"
                }
                ELSE
			        {
                    Write-Host "Folder already exists"
			        }

			# Roll code
			$WebResponseVar = Invoke-WebRequest $URLParam
			$LinksVar = $WebResponseVar.Links | Select -expand href
			$LinksVar | foreach-Object {
			$LinkVar = $_
			New-Item -ItemType directory -Path "$DownloadPathParam\$_"
			cd "$DownloadPathParam\$_"

			# Pull files
			$DownloadURLVar = "$URLParam/$linkVar"
			$WebResponseSubFilesVar = Invoke-WebRequest $DownloadURLVar
			$FilesVar = $WebResponseSubFilesVar.Links | Select -expand href | Where-Object {$_ -match ".+\.$FileExtensionParam"}

            # Do download for each item found with the FileExtension
		    FOREACH ($ItemVar in $FilesVar)
			    {
			    Write-Host "Item is named: $ItemVar"
			    Write-Host "Puling $ItemVar from: $DownloadURLVar$ItemVar"
			    Start-BitsTransfer -Source "$DownloadURLVar$ItemVar"
			    }
		    }  

        }
END 
    {
	# Stop Stopwatch and report duration and completed status to screen and logfile.
	$Stopwatch.stop()

	# Out Put end of Function
	write-host -ForegroundColor Green "===================="
	write-host -ForegroundColor Green "End of Function"
	write-host -ForegroundColor Green "===================="

	$tmpstring = "Duration: $(($Stopwatch.Elapsed).ToString())"
	Write-Host -ForegroundColor Green $tmpstring

	# Clear Params
    Write-Verbose "Nulling Params"
	$DownloadPathParam = ""
    $URLParam = ""
    $FileExtensionParam = ""

    # Clear Vars
    Write-Verbose "Nulling Vars"
    $WebResponseVar = ""
    $WebResponseSubFilesVar = ""
    $LinksVar = ""
    $LinkVar = ""
    $DownloadURLVar = ""
    $FilesVar = ""
    $ItemVar = ""
    }
}
