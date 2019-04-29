###################################################################################################
#
# LANGUAGE:      PowerShell V1.0
# SCRIPT NAME:   Set-ScheduleTask
# AUTHOR:        Richard Hicklin
# COMPONENT:     N/A
# VERSIONS:      1.0
# DOCUMENTS:     
# ACMS MEDIA ID: 
# NOTES:         This Powershell Function uses the schtask command to automate task creation
#
# DEVELOPMENT:   Ongoing
#
# Nateive comand   schtasks  /create /RU username /RP password /SC DAILY /D "*" /TN Taskname /TR c:\the program to run here /ST 22:00
#	schtasks
#	/create 
#	/RU username
#	/RP password
#	/SC DAILY
#	/D "*"
#	/TN Taskname
#	/TR c:\the program to run here
#	/ST 22:00
###################################################################################################

Function Create-ScheduleTaks
{
<#
.SYNOPSIS
This is a PowerShell Function is for Automated Scheduled Tasks

.DESCRIPTION
The script Function is designed to create scheduled tasks, the function is using Try and Catch for error handling.

.EXAMPLE
Set-ScheduledTask C:\support\create-scheduletasks.csv

To execute a the function and create the scheduled tasks on server.


.NOTES
The command line for the function requires the FilePath Name.

Log files are written to c:\support\logs\Set-SceduledTask_<DATE>.txt

.LINK
http://awebpage.com

#>

	Param	([parameter(Position=0,Mandatory=$true)] $Inputfile)

	Begin
	{
		"--Start of Begin Block--"
		$StartValue = Get-date
		Write-verbose (("{0:HH:mm:ss.fff}" -f  (date)) +" - Setting log file location")

		#Test Logfile location - Create if missing
		$strLogFileLocationPath = "C:\Support\Logfiles"
		If(!(Test-Path $strLogFileLocationPath))
		{New-Item -Type Directory $strLogFileLocationPath | Out-Null}

		#Set logfile Name
		$strLogFileNameLocation = "\Set-ScheduledTask_"+"{0:ddMMyyyy_HHmm}" -f (date)+".txt"
		$StrLogFile = $strLogFileLocationPath+$strLogFileNameLocation 
		If (!(Test-Path $StrLogFile))
		{
			"Log file for Powershell Function: Set-ScheduledTask" | Out-File -FilePath $StrLogFile -Encoding ASCII
			#Version Title infomation
			$Version | Out-File -FilePath $StrLogFile -Encoding ASCII
		}

		Write-Debug "`$StrLogFile is $StrLogFile"	
		#Write to log file
		$StrLogMessage = (("{0:HH:mm:ss.fff}" -f  (date)) +" - Starting")
		Write-verbose $StrLogMessage
		Write-Host $StrLogMessage -ForegroundColor Green
		out-file -filepath $StrLogFile -inputobject $StrLogMessage  -encoding ASCII -Append

		#Testing for schtasks.exe!       
		Write-Verbose "Checking for schtasks.exe "
		If(!(Test-Path "C:\WINDOWS\system32\schtasks.exe"))
		{
			Write-Verbose "Schtasks.exe not detected"
			Write-warning "This function requires Schtasks.exe, exiting script"
			$StrLogMessage = (("{0:HH:mm:ss.fff}" -f  (date)) +" - Schtasks.exe can not be found - FAIL")
			out-file -filepath $StrLogFile -inputobject $StrLogMessage  -encoding ASCII -Append
			Break
		}

		$INFile = Import-csv $Inputfile

		#locate domain name
		$DomainName = $env:DOMAIN
		write-verbose "--End of Begin Block--"
	}
	process
	{
		Write-Verbose "--Start of Process Block--"
		$INFile | Group-Object Samaccountname | ForEach-Object `
		{
			$PWD = read-host ('Enter Password for account name: '+$_.name) -AsSecureString
			$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($PWD)
			$PlainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
			write-verbose "Password used $PlainPassword"

		$_.Group | Foreach-Object `
		{

			#Get variables
			$Samaccountname =$_.Samaccountname
			$SCSchedule = $_.SCSchedule
			$DAY = $_.DAY
			$TaskName = $_.TaskName
			$TaskRun = $_.TaskRun
			$StartTime = $_.StartTime
			$FullAccount = ($DomainName+"\"+$samaccountname)
			#'Creating schedule task ...'
			#'Using passowrd: '+$PWD
			$_
			Write-Verbose "Create process start info for schtask command"
			$ObjProcessChange = new-object System.Diagnostics.ProcessStartInfo
			$ObjProcessChange.filename = "schtasks"

			#Build command line
			$ObjProcessChange.arguments = "/create /RU `"$FullAccount`" /RP `"$PlainPassword`" /SC `"$SCSchedule`" /D `"$DAY`" /TN `"$TaskName`" /TR `"$TaskRun`" /ST `"$StartTime`""

			$ObjProcessChange.UseShellExecute = $false
			$ObjProcessChange.RedirectStandardError = $True
			$ObjProcessChange.RedirectStandardOutput = $True
			$Erroractionpreference="Continue"
			$Error.Clear()


			if(C:\WINDOWS\system32\Schtasks.exe /query /FO list | Where-Object {$_ -match $Taskname})
			{
				write-warning "The task is already present!"
				(date).ToString()+"`t Command: Task $TaskName already exists - Skipping! " | Out-File -filePath $StrLogFile -Encoding ASCII -append 
			}
			else
			{
				Write-Verbose "Execute schtask command"
				$VarCMD = [System.Diagnostics.Process]::Start($ObjProcessChange)
				Write-Verbose "Do (Nothing) until schtask command has completed"
				do{} until ($VarCMD.HasExited -eq $True)

				$VarErrCount = $Error.count
				$VarErrMess = $Error[0].Exception.message
				Write-Verbose "`$VarErrCount = $VarErrCount"
				"`$VarCMD.ExitCodet = "+$VarCMD.ExitCode | Write-Verbose

				If($VarErrCount -gt 0)
				{
					Write-Verbose "Issue running the Schtasks.exe command"
				}
				Else
				{
                        
					"Running command: Schtasks "+[string]$ObjProcessChange.arguments | Write-verbose
					(date).ToString()+"`t Command: C:\WINDOWS\system32\Schtasks.exe /create /RU `"$FullAccount`" /RP ********* /SC `"$SCSchedule`" /D `"$DAY`" /TN `"$TaskName`" /TR `"$TaskRun`" /ST `"$StartTime`"" | Out-File -filePath $StrLogFile -Encoding ASCII -append
				}
				$ErrorID = $VarCMD.ExitCode
				write-host "Exit code: $ErrorID"

				If($VarCMD.Exitcode -eq "0")
				{
					"Exit Code 0 = Schtask completed and created TASK:  = /create /RU `"$FullAccount`" /RP ********* /SC `"$SCSchedule`" /D `"$DAY`" /TN `"$TaskName`" /TR `"$TaskRun`" /ST `"$StartTime`" The Task was created! " | Out-File -FilePath $StrLogFile -Encoding ASCII -append
				}
				ElseIf($VarCMD.Exitcode -eq "1")
				{
					"Exit Code 1 = Issue with Password, Failed to create TASK:  = /create /RU `"$FullAccount`" /RP ********* /SC `"$SCSchedule`" /D `"$DAY`" /TN `"$TaskName`" /TR `"$TaskRun`" /ST `"$StartTime`" The Task was NOT created! " | Out-File -FilePath $StrLogFile -Encoding ASCII -append
				}
				Else
				{
				"Unable to determine error code when trying to create TASK:  = /create /RU `"$FullAccount`" /RP ********* /SC `"$SCSchedule`" /D `"$DAY`" /TN `"$TaskName`" /TR `"$TaskRun`" /ST `"$StartTime`" The Task was NOT created! " | Out-File -FilePath $StrLogFile -Encoding ASCII -append
				}

			}
				
		}
	}
	Write-Verbose "--End of Process Block--"
	}
end
{
	Write-verbose "--Start of End Block--"

		$StrLogMessage = (("{0:HH:mm:ss.fff}" -f  (date)) +" - Finished")
		$EndValue = Get-date
		$TimeTaken = $EndValue-$StartValue
		Write-Host "Time Taken: $TimeTaken" 
		Out-File -filepath $StrLogFile -inputobject "Time Taken: $TimeTaken" -Encoding ASCII -Append
		Write-verbose $StrLogMessage
		Write-Host $StrLogMessage -ForegroundColor Green
		out-file -filepath $StrLogFile -inputobject $StrLogMessage  -encoding ASCII -Append
		Write-verbose "--End of End Block--"
}

}
