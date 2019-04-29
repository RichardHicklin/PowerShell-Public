Function TEST-USERS {
	[cmdletbinding()]
	param (
		 [parameter(Position=0,Mandatory=$false,ValueFromPipelineByPropertyName=$true)]$TESTNAME,
         [parameter(Position=1,Mandatory=$false,ValueFromPipelineByPropertyName=$true)][string]$USERNAME

	)
	
	Process {
        $error.clear()
		$Obj = New-Object -TypeName Object
		Add-Member -InputObject $obj -MemberType NoteProperty -Name TestName -Value $TESTNAME
		Add-Member -InputObject $obj -MemberType NoteProperty -Name Username -Value $USERNAME

        #Verbose messages
		Write-verbose "`$TESTNAME: $TESTNAME"
		Write-verbose "`$USERNAME: $USERNAME"

            $TestValue = Get-WmiObject -Class Win32_UserAccount -Filter  "LocalAccount='True'" | where {$_.Name -eq $USERNAME}
			If ($USERNAME -eq $Testvalue.Name) {
                                    $iResult="Passed"
                                            Add-Member -InputObject $obj -MemberType NoteProperty -Name SID -Value ($TestValue.SID) -Force
                                            Add-Member -InputObject $obj -MemberType NoteProperty -Name Account-Disabled -Value ($TestValue.Disabled) -Force
                                            Add-Member -InputObject $obj -MemberType NoteProperty -Name Account-Type -Value ($TestValue.AccountType) -Force
                                            Add-Member -InputObject $obj -MemberType NoteProperty -Name Status -Value ($TestValue.Status) -Force
                                            Add-Member -InputObject $obj -MemberType NoteProperty -Name Password-Required -Value ($TestValue.PasswordRequired) -Force
                                    }
			                    ELse {
                                     $iResult="Failed"
                                    Add-Member -InputObject $obj -MemberType NoteProperty -Name SID -Value "N\A" -Force
                                    Add-Member -InputObject $obj -MemberType NoteProperty -Name Account-Disabled -Value "N\A" -Force
                                    Add-Member -InputObject $obj -MemberType NoteProperty -Name Account-Type -Value "N\A" -Force
                                    Add-Member -InputObject $obj -MemberType NoteProperty -Name Status -Value "N\A" -Force
                                    Add-Member -InputObject $obj -MemberType NoteProperty -Name Password-Required -Value "N\A" -Force
                                     }

			                        Add-Member -InputObject $obj -MemberType NoteProperty -Name Result -Value $iResult
			                        Add-Member -InputObject $obj -MemberType NoteProperty -Name Result-ErrorDetail -Value $Error[0].Exception.Message
		                            $Obj
            }
}
