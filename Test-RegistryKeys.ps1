Function Test-RegistryKeys {
	[cmdletbinding()]
	param (
		 [parameter(Position=0,Mandatory=$false,ValueFromPipelineByPropertyName=$true)]$TESTNAME,
         [parameter(Position=1,Mandatory=$false,ValueFromPipelineByPropertyName=$true)][string]$PATH,
         [parameter(Position=2,Mandatory=$false,ValueFromPipelineByPropertyName=$true)][string]$KEY,
         [parameter(Position=3,Mandatory=$false,ValueFromPipelineByPropertyName=$true)][string]$VALUE
	)
	
	Process {
		$Obj = New-Object -TypeName Object
		Add-Member -InputObject $obj -MemberType NoteProperty -Name TESTNAME -Value $TESTNAME
		Add-Member -InputObject $obj -MemberType NoteProperty -Name PATH -Value $PATH
		Add-Member -InputObject $obj -MemberType NoteProperty -Name KEY -Value $KEY
		Add-Member -InputObject $obj -MemberType NoteProperty -Name VALUE -Value $VALUE
		
		Write-verbose "`$TESTNAME: $TESTNAME"
		Write-verbose "`$PATH: $PATH"
		Write-verbose "`$KEY: $KEY"
		Write-verbose "`$VALUE: $VALUE"
		
		#Check Values in .CSV file to make logic of each type of test
		If($PATH) {$ParamTestPath=1} 
		Else {$ParamTestPath=0}
		
		If($KEY) {$ParamTestKey=1} 
		Else {$ParamTestKey=0}
		
		If($VALUE) {$ParamTestVALUE=1} 
		Else {$ParamTestVALUE=0}

		#Logic 
		#0 = Path + Key + Value
		#1 = Path + Key
		#2 = Path
		#999 = return error
		
		If ($ParamTestPath -eq 1 -AND $ParamTestKey -eq 1 -and $ParamTestVALUE -eq 1) {$TestLogicResult=0}
		ElseIf ($ParamTestPath -eq 1 -AND $ParamTestKey -eq 1 -and $ParamTestVALUE -eq 0) {$TestLogicResult=1}
		ElseIf ($ParamTestPath -eq 1 -AND $ParamTestKey -eq 0 -and $ParamTestVALUE -eq 0) {$TestLogicResult=2}
		Else {$TestLogicResult=999}
		
		$Error.Clear()
		If ($TestLogicResult -eq 0) {
			Write-verbose "Test logic 0"
			$TestValue = Get-ItemProperty -path $obj.PATH -Name $obj.KEY -ErrorAction SilentlyContinue
			$Result = $TestValue.($obj.KEY) -eq $obj.Value
			If ($Result -eq "True") {$iResult="Passed"} 
			ELse {$iResult="Failed"}
			Add-Member -InputObject $obj -MemberType NoteProperty -Name CurrentValue -Value $TestValue.($obj.KEY)
			Add-Member -InputObject $obj -MemberType NoteProperty -Name Result -Value $iResult
			Add-Member -InputObject $obj -MemberType NoteProperty -Name ResultErrorDetail -Value $Error[0].Exception.Message
		
		} ElseIF ($TestLogicResult -eq 1) {
			Write-verbose "Test logic 1"
			$TestPath = Get-ItemProperty -path $obj.PATH -ErrorAction SilentlyContinue
			$ResultSearch = $($TestPath.PSObject.Properties | Select-Object -expand Name) -match $obj.KEY
			
			If($ResultSearch) {$Result="Passed"}
			Else {$Result="Failed"}
			
			IF($Result -eq "Failed") {$iErrorMSG = "Key name not found $($Error[0].Exception.Message)"
			} Else {$iErrorMSG = $Error[0].Exception.Message}
			
			Add-Member -InputObject $obj -MemberType NoteProperty -Name CurrentValue -Value $TestValue.($obj.KEY)
			Add-Member -InputObject $obj -MemberType NoteProperty -Name Result -Value $Result
			Add-Member -InputObject $obj -MemberType NoteProperty -Name ResultErrorDetail -Value $iErrorMSG
			
		} ElseIF ($TestLogicResult -eq 2) {
			Write-verbose "Test logic 2"
			$Result = Test-path $obj.PATH -ErrorAction SilentlyContinue
			If ($Result -eq "True") {$iResult="Passed"} 
			Else {$iResult="Failed"}
			
			IF($iResult -eq "Failed") {$iErrorMSG = "Path  not found $($Error[0].Exception.Message)"
			} Else {$iErrorMSG = $Error[0].Exception.Message}
			
			Add-Member -InputObject $obj -MemberType NoteProperty -Name CurrentValue -Value "N/A"
			Add-Member -InputObject $obj -MemberType NoteProperty -Name Result -Value $iResult
			Add-Member -InputObject $obj -MemberType NoteProperty -Name ResultErrorDetail -Value $iErrorMSG
		
		} Else {
			Write-verbose "Test logic 999"
			Add-Member -InputObject $obj -MemberType NoteProperty -Name CurrentValue -Value "N/A"
			Add-Member -InputObject $obj -MemberType NoteProperty -Name Result -Value "Failed"
			Add-Member -InputObject $obj -MemberType NoteProperty -Name ResultErrorDetail -Value "N/A"
		}
		$Obj	
    }
}



#Create .CSV
#Set-Content -Path "c:\support\rich.csv" -Value "TESTNAME,PATH,KEY,VALUE"
#Add-Content -Path "c:\support\rich.csv" -Value "Test101,HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon,ForceUnlockLogon,0"
#Add-Content -Path "c:\support\rich.csv" -Value "Test102,HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon,ForceUnlockLogon,1"
#Add-Content -Path "c:\support\rich.csv" -Value "Test103,HKLM:\Software\Micr44osoft\Windows NT\CurrentVersion\Winlogon,Forc44eUnlockLogon,1"
#Add-Content -Path "c:\support\rich.csv" -Value "Test201,HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon,EnableSIHostIntegration,"
#Add-Content -Path "c:\support\rich.csv" -Value "Test202,HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon,EnableSIHostIntegrationEEE,"
#Add-Content -Path "c:\support\rich.csv" -Value "Test203,HKLM:\Software\Micr2osoft\Windows NT\CurrentVersion\Winlogon,EnableSIHostIntegrationEEE,"
#Add-Content -Path "c:\support\rich.csv" -Value "Test301,HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon,,"
#Add-Content -Path "c:\support\rich.csv" -Value "Test302,HKLM:\Software\Microsoft\Windows NT\CurrentVersion\WinlogonEEE,,"
#Add-Content -Path "c:\support\rich.csv" -Value "Test303,HKLM:\Sofdtware\Microsoft\Windows NT\CurrentVersion\WinlogonEEE,,"
#Add-Content -Path "c:\support\rich.csv" -Value "Test401,,,"


#Run Function
#ipcsv "c:\support\rich.csv" | . Test-RegistryKeys | FT -au
