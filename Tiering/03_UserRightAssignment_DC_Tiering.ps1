Write-Host ""
Write-Host "[Task : 0] Gathering Domain Informations, default and Tiering Security Groups Ids, Default DC policy Id...   " -ForegroundColor Green -NoNewline; Write-Host "[OK]" -ForegroundColor Green 

$DC = (Get-ADDomainController)
$Hostname = $DC.Name
$Domain = $DC.Domain
$NetBIOSName = (Get-ADDomain).NetBIOSName
$FQDNDomainName = (Get-ADDomain).DnsRoot
$DomainSid = (Get-ADDomain).DomainSID.Value
$DomainName = (Get-ADRootDSE).defaultNamingContext
$ParentOu = "OU=$NetBIOSName,$DomainName"
$DistinguishedDomainName = (Get-ADDomain).DistinguishedName
$MachineAccountValue = "ms-DS-MachineAccountQuota"
$MachineAccountQuota = (Get-ADObject -Identity $DistinguishedDomainName -Properties ms-DS-MachineAccountQuota | Select-Object ms-DS-MachineAccountQuota ).$MachineAccountValue

$groupT0 = @(
                $(New-Object PSObject -Property @{Group = "Domain Tier0 Admins"; OUPrefix = "OU=Groups,OU=Tier0,$ParentOu" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier0 Service Accounts"; OUPrefix = "OU=Groups,OU=Tier0,$ParentOu" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier0 PAW Users"; OUPrefix = "OU=Groups,OU=Tier0,$ParentOu" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier0 PAW Maintenance"; OUPrefix = "OU=Groups,OU=Tier0,$ParentOu" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier0 Maintenance"; OUPrefix = "OU=Groups,OU=Tier0,$ParentOu" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier0 Remote Domain Controllers"; OUPrefix = "OU=Groups,OU=Tier0,$ParentOu" })
            )

$groupT1 = @(
                $(New-Object PSObject -Property @{Group = "Domain Tier1 Admins"; OUPrefix = "OU=Groups,OU=Tier1,$ParentOu" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier1 Service Accounts"; OUPrefix = "OU=Groups,OU=Tier1,$ParentOu" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier1 JumpServer Users"; OUPrefix = "OU=Groups,OU=Tier1,$ParentOu" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier1 Jumpserver Maintenance"; OUPrefix = "OU=Groups,OU=Tier1,$ParentOu" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier1 Maintenance"; OUPrefix = "OU=Groups,OU=Tier1,$ParentOu" })
                
            )

$groupT2 = @(
                $(New-Object PSObject -Property @{Group = "Domain Tier2 Admins"; OUPrefix = "OU=Groups,OU=Tier2,$ParentOu" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier2 HelpDesk Operators"; OUPrefix = "OU=Groups,OU=Tier2,$ParentOu" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier2 Remote Desktop Users"; OUPrefix = "OU=Groups,OU=Tier2,$ParentOu" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier2 Users"; OUPrefix = "OU=Groups,OU=Tier2,$ParentOu" })
)

# Default Service Groups
$ServiceSid = (Get-WMIObject -Class 'Win32_Account' -Filter 'name="SERVICE"').Sid                            # SERVICE
$EnterpriseDCSid = (Get-WMIObject -Class 'Win32_Account' -Filter 'name="ENTERPRISE DOMAIN CONTROLLERS"').Sid # ENTERPRISE DOMAIN CONTROLLERS
$AuthUserSid = (Get-WMIObject -Class 'Win32_Account' -Filter 'name="Authenticated Users"').Sid               # Authenticated Users
$LocalSrvSid = (Get-WMIObject -Class 'Win32_Account' -Filter 'name="LOCAL SERVICE"').Sid                     # LOCAL SERVICE
$NetworkSrvSid = (Get-WMIObject -Class 'Win32_Account' -Filter 'name="NETWORK SERVICE"').Sid                 # NETWORK SERVICE
$WindowsMgrGroupSid = "S-1-5-90-0"                                                                           # Windows Manager\Windows Manager Group
$WdiServiceHostSid = "S-1-5-80-3139157870-2983391045-3678747466-658725712-1809340420"                        # NT SERVICE\WdiServiceHost

# Default Security Groups
$DAName = (Get-ADGroup -Filter "SID -eq ""$DomainSid-512""").Name
$DASid = (Get-ADGroup -Filter "SID -eq ""$DomainSid-512""").SID.Value    # Domain Admins
$SchemaSid = (Get-ADGroup -Filter "SID -eq ""$DomainSid-518""").SID.Value # Schema Admins
$EASid = (Get-ADGroup -Filter "SID -eq ""$DomainSid-519""").SID.Value     # Enterprise Admins
$AdminsSid = (Get-ADGroup -Filter "SID -eq ""S-1-5-32-544""").SID.Value  # Administrators
$GuestsSid = (Get-ADGroup -Filter "SID -eq ""S-1-5-32-546""").SID.Value  # Guests
$AccountSid = (Get-ADGroup -Filter "SID -eq ""S-1-5-32-548""").SID.Value # Account Operators
$ServerSid = (Get-ADGroup -Filter "SID -eq ""S-1-5-32-549""").SID.Value  # Server Operators
$PrintSid = (Get-ADGroup -Filter "SID -eq ""S-1-5-32-550""").SID.Value   # Print Operators
$BackupSid = (Get-ADGroup -Filter "SID -eq ""S-1-5-32-551""").SID.Value  # Backoup Operators

$DefaultGPO = "Default Domain Policy",
              "Default Domain Controllers Policy"


foreach ( $GPO in $DefaultGPO ){
    
    if ($GPO -eq $DefaultGPO[1]){
        
       $001Id = (Get-GPO -Name $DefaultGPO[1]).Id.ToString()
       $PathDomainCtrlPolicy = Get-Item "\\$Hostname\Sysvol\$Domain\Policies\{$($001Id)}\Machine\Microsoft\Windows NT\SecEdit"
       $GptTmplPath = "$PathDomainCtrlPolicy\GptTmpl.inf"
       $GptIniPath = "\\$Hostname\Sysvol\$Domain\Policies\{$($001Id)}\GPT.INI"
       $CheckContent = Get-Content $GptTmplPath
    }
}

if (
    ($check0 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT0.Group[0]).DistinguishedName) -and
    ($check1 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT0.Group[1]).DistinguishedName) -and
    ($check2 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT0.Group[2]).DistinguishedName) -and
	($check3 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT0.Group[3]).DistinguishedName) -and
    ($check4 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT0.Group[4]).DistinguishedName) -and
    ($check5 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT0.Group[5]).DistinguishedName) -and
    ($check6 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT1.Group[0]).DistinguishedName) -and
    ($check7 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT1.Group[1]).DistinguishedName) -and
    ($check8 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT1.Group[2]).DistinguishedName) -and
    ($check9 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT1.Group[3]).DistinguishedName) -and
    ($check10 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT1.Group[4]).DistinguishedName) -and
    ($check11 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT2.Group[0]).DistinguishedName) -and
    ($check12 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT2.Group[1]).DistinguishedName) -and
    ($check13 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT2.Group[2]).DistinguishedName) -and
    ($check14 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT2.Group[3]).DistinguishedName)
   )
   {
        # Tiering Security Groups
        $AdminT0Sid = (Get-ADGroup -Filter * -Properties * | Where-Object Name -eq $groupT0.Group[0]).Sid.Value
        $SrvAccountT0Sid = (Get-ADGroup -Filter * -Properties * | Where-Object Name -eq $groupT0.Group[1]).Sid.Value
        $PAWUserT0Sid = (Get-ADGroup -Filter * -Properties * | Where-Object Name -eq $groupT0.Group[2]).Sid.Value
        $PAWMainT0Sid = (Get-ADGroup -Filter * -Properties * | Where-Object Name -eq $groupT0.Group[3]).Sid.Value
        $MainT0Sid = (Get-ADGroup -Filter * -Properties * | Where-Object Name -eq $groupT0.Group[4]).Sid.Value
        $RemoteDCT0Sid = (Get-ADGroup -Filter * -Properties * | Where-Object Name -eq $groupT0.Group[5]).Sid.Value
        $AdminT1Sid = (Get-ADGroup -Filter * -Properties * | Where-Object Name -eq $groupT1.Group[0]).Sid.Value
        $SrvAccountT1Sid = (Get-ADGroup -Filter * -Properties * | Where-Object Name -eq $groupT1.Group[1]).Sid.Value
        $JumpUserT1Sid = (Get-ADGroup -Filter * -Properties * | Where-Object Name -eq $groupT1.Group[2]).Sid.Value
        $JumpMainT1Sid = (Get-ADGroup -Filter * -Properties * | Where-Object Name -eq $groupT1.Group[3]).Sid.Value
        $MainT1Sid = (Get-ADGroup -Filter * -Properties * | Where-Object Name -eq $groupT1.Group[4]).Sid.Value
        $AdminT2Sid = (Get-ADGroup -Filter * -Properties * | Where-Object Name -eq $groupT2.Group[0]).Sid.Value
        $HelpdeskT2Sid = (Get-ADGroup -Filter * -Properties * | Where-Object Name -eq $groupT2.Group[1]).Sid.Value
        $UserRemoteT2Sid = (Get-ADGroup -Filter * -Properties * | Where-Object Name -eq $groupT2.Group[2]).Sid.Value
        $UsersT2Sid = (Get-ADGroup -Filter * -Properties * | Where-Object Name -eq $groupT2.Group[3]).Sid.Value
   }
else 
   {
        write-warning "This script depends on the script 2) Tiering security groups"
        Write-Host ""
        Get-Content .\info.md
        Write-Host ""
	    exit
   }

$PathPolicy = (Get-ADObject -Filter 'Name -eq "Policies"' -Properties * | Where-Object ObjectClass -eq container | Select-Object Name, distinguishedName).DistinguishedName    
$VersionNumber = (Get-ADObject "CN={$($001Id)},$PathPolicy" -Properties *)

$VersionNumber.versionNumber | ForEach {

       $InitialVNumber = $VersionNumber.versionNumber
       $NewVersionNumber = 34
       $ResultVNumber = [int]"$InitialVNumber" + [int]"$NewVersionNumber"

    if ( $VersionNumber.versionNumber -eq "1" )
        {
            
            Write-Host "[Task : 1] Checking if Version Number doesn't modified, if not configuring User Rights Assignment Tiering... " -ForegroundColor Green -NoNewline; Write-Host "[OK]" -ForegroundColor Green
            function Default_Domain_controllers_policy 
                {
     
                    $Backup = "^SeBackupPrivilege.*"
                    $BatchLogonRight = "^SeBatchLogonRight.*"
                    $InteractiveLogonRight = "^SeInteractiveLogonRight.*"
                    $LoadDriver = "^SeLoadDriverPrivilege.*"
                    $MachineAccount = "^SeMachineAccountPrivilege.*"
                    $NetworkLogonRight = "^SeNetworkLogonRight.*"
                    $RemoteShutdown = "^SeRemoteShutdownPrivilege.*"
                    $Restore = "^SeRestorePrivilege.*"
                    $Shutdown = "^SeShutdownPrivilege.*"
                    $SystemTime = "^SeSystemTimePrivilege.*"

                    # Change Compliance CIS Benchmark

                    $URABackup = "SeBackupPrivilege = *$AdminsSid"
                    $URABatchlogonRight = "SeBatchLogonRight = *$BackupSid,*$AdminsSid,*$AdminT0Sid"
                    $URAInteractiveLogonRight = "SeInteractiveLogonRight = *$BackupSid,*$AdminsSid,*$AdminT0Sid"
                    $URALoadDriver = "SeLoadDriverPrivilege = *$AdminsSid"
                    $URAMachineAccount = "SeMachineAccountPrivilege = *$DASid,*$HelpdeskT2Sid"
                    $URANetworkLogonRight = "SeNetworkLogonRight = *$EnterpriseDCSid,*$AuthUserSid,*$AdminsSid"
                    $URARemoteShutdown = "SeRemoteShutdownPrivilege = *$AdminsSid"
                    $URARestore = "SeRestorePrivilege = *$AdminsSid"
                    $URAShutdown = "SeShutdownPrivilege = *$AdminsSid"
                    $URASystemTime = "SeSystemTimePrivilege = *$AdminsSid,*$LocalSrvSid"
          
                    # Add those lines after this pattern SeEnableDelegationPrivilege
                    $URARemoteInteractiveLogonRight = "SeRemoteInteractiveLogonRight = *$AdminT0Sid"
                    $URATimeZone = "SeTimeZonePrivilege = *$LocalSrvSid,*$AdminsSid"
                    $URACreateGlobal = "SeCreateGlobalPrivilege = *$ServiceSid,*$NetworkSrvSid,*$LocalSrvSid,*$AdminsSid"
                    $URACreateSymbolic = "SeCreateSymbolicLinkPrivilege = *$AdminsSid"
                    $URADenyNetLogonRight = "SeDenyNetworkLogonRight = *$GuestsSid"
                    $URADenyBatchLogonRight = "SeDenyBatchLogonRight = *$GuestsSid,*$AccountSid,*$PrintSid,*$ServerSid,*$JumpMainT1Sid,*$JumpUserT1Sid,*$AdminT1Sid,*$MainT1Sid,*$SrvAccountT1Sid,*$AdminT2Sid,*$HelpdeskT2Sid,*$UsersT2Sid,*$UserRemoteT2Sid"
                    $URADenyServiceLogonRight = "SeDenyServiceLogonRight = *$GuestsSid,*$AccountSid,*$PrintSid,*$ServerSid,*$JumpMainT1Sid,*$JumpUserT1Sid,*$AdminT1Sid,*$MainT1Sid,*$SrvAccountT1Sid,*$AdminT2Sid,*$HelpdeskT2Sid,*$UsersT2Sid,*$UserRemoteT2Sid"
                    $URADenyInteractiveLogonRight = "SeDenyInteractiveLogonRight = *$GuestsSid,*$AccountSid,*$PrintSid,*$ServerSid,*$JumpMainT1Sid,*$JumpUserT1Sid,*$AdminT1Sid,*$MainT1Sid,*$SrvAccountT1Sid,*$AdminT2Sid,*$HelpdeskT2Sid,*$UsersT2Sid,*$UserRemoteT2Sid"
                    $URADenyRemoteInteractiveLogonRight = "SeDenyRemoteInteractiveLogonRight = *$GuestsSid,*$AccountSid,*$PrintSid,*$ServerSid,*$JumpMainT1Sid,*$JumpUserT1Sid,*$AdminT1Sid,*$MainT1Sid,*$SrvAccountT1Sid,*$AdminT2Sid,*$HelpdeskT2Sid,*$UsersT2Sid,*$UserRemoteT2Sid"
                    $URAImpersonate = "SeImpersonatePrivilege = *$ServiceSid,*$NetworkSrvSid,*$LocalSrvSid,*$AdminsSid"
                    $URAIncreaseWorking = "SeIncreaseWorkingSetPrivilege = *$AdminsSid"
                    $URAMangeVolume = "SeManageVolumePrivilege = *$AdminsSid"
          
                    function Backup (){
                        $DCContent = Get-Content $GptTmplPath
                        $URA1 = $DCContent -replace $Backup, $URABackup
                        Set-Content $GptTmplPath $URA1
                    }
                    Backup

                    function BatchLogon (){
                        $DCContent = Get-Content $GptTmplPath
                        $URA2 = $DCContent -replace $BatchLogonRight, $URABatchLogonRight
                        Set-Content $GptTmplPath $URA2
                    }
                    BatchLogon         

                    function InteractiveLogon (){
                        $DCContent = Get-Content $GptTmplPath
                        $URA3 = $DCContent -replace $InteractiveLogonRight, $URAInteractiveLogonRight
                        Set-Content $GptTmplPath $URA3
                    }
                    InteractiveLogon

                    function LoadDriver (){
                        $DCContent = Get-Content $GptTmplPath
                        $URA4 = $DCContent -replace $LoadDriver, $URALoadDriver
                        Set-Content $GptTmplPath $URA4
                    }
                    LoadDriver

                    function MachineAccount (){
                        $DCContent = Get-Content $GptTmplPath
                        $URA5 = $DCContent -replace $MachineAccount, $URAMachineAccount
                        Set-Content $GptTmplPath $URA5
                    }
                    MachineAccount

                    function NetworkLogon (){
                        $DCContent = Get-Content $GptTmplPath
                        $URA6 = $DCContent -replace $NetworkLogonRight, $URANetworkLogonRight
                        Set-Content $GptTmplPath $URA6
                    }
                    NetworkLogon

                    function RemoteShutdown (){
                        $DCContent = Get-Content $GptTmplPath
                        $URA7 = $DCContent -replace $RemoteShutdown, $URARemoteShutdown
                        Set-Content $GptTmplPath $URA7
                    }
                    RemoteShutdown

                    function Restore (){
                        $DCContent = Get-Content $GptTmplPath
                        $URA8 = $DCContent -replace $Restore, $URARestore
                        Set-Content $GptTmplPath $URA8
                    }
                    Restore

                    function Shutdown (){
                        $DCContent = Get-Content $GptTmplPath
                        $URA9 = $DCContent -replace $Shutdown, $URAShutdown
                        Set-Content $GptTmplPath $URA9
                    }
                    Shutdown

                    function SystemTime (){
                        $DCContent = Get-Content $GptTmplPath
                        $URA10 = $DCContent -replace $SystemTime, $URASystemTime
                        Set-Content $GptTmplPath $URA10
                    }
                    SystemTime

                    #Add New line after a Pattern LockoutBadCount and Registy Values
                    $GptTmplPathVars = Get-Content $GptTmplPath | ForEach-Object {
     
                        $_
                        if ($_ -match "SeEnableDelegationPrivilege")
                            {
                                $URARemoteInteractiveLogonRight
                                $URATimeZone
                                $URACreateGlobal
                                $URACreateSymbolic
                                $URADenyNetLogonRight
                                $URADenyBatchLogonRight
                                $URADenyServiceLogonRight
                                $URADenyInteractiveLogonRight
                                $URADenyRemoteInteractiveLogonRight
                                $URAImpersonate
                                $URAIncreaseWorking
                                $URAMangeVolume
                            }
                    } 

                    $GptTmplPathVars > $GptTmplPath

                    # Edit GPT.INI and update Sysvol versionNumber
                    Write-Host "[Task : 3] Updating VersionNumber of the Default Domain Controllers policy...                                " -ForegroundColor Green -NoNewline; Write-Host "[OK]" -ForegroundColor Green 
                
                    $DCGptContent = Get-Content $GptIniPath
                    $DCGptContent = $DCGptContent -replace "Version=1", "Version=35"
                    Set-Content $GptIniPath $DCGptContent

                    # Update AD versionNumber

                    $VersionNumber = (Get-ADObject "CN={$($001Id)},$PathPolicy" -Properties *)
                    Set-ADObject -Identity $VersionNumber -Replace @{versionNumber="35"}

                    # Change the attribute ms-DS-MachineAccountQuota
                    Write-Host "[Task : 4] Changing the value of the attribute ms-DS-MachineAccountQuota set to 0...                         " -ForegroundColor Green -NoNewline; Write-Host "[OK]" -ForegroundColor Green 
                
                    Set-ADDomain -Identity $FQDNDomainName -Replace @{"ms-DS-MachineAccountQuota"="0"}

                    # Create default T0 Admin for Domain Remote Access
                    Write-Host "[Task : 5] Creating default T0 Admin account...                                                              " -ForegroundColor Green -NoNewline; Write-Host "[OK]" -ForegroundColor Green 
                    
                    $csvFilePath = ".\users.csv"
                    $dnsroot = '@' + (Get-ADDomain).dnsroot
                    $users = Import-Csv $csvFilePath

                    foreach ($user in $users) {
                        $newUserParams = @{
                            Name                = $user.DisplayName
                            GivenName           = $user.FirstName
                            Surname             = $user.LastName
                            SamAccountName       = $user.SamAccountName
                            UserPrincipalName   = $user.SamAccountName + $dnsroot
                            Path                = "OU=Admins,OU=Tier0,$ParentOu"
                            AccountPassword     = ConvertTo-SecureString $user.Password -AsPlainText -Force
                            Enabled             = [bool]$user.Enabled  # Convert string to boolean
                        }

                        try {
                                New-ADUser @newUserParams
                                Write-Host "User $($user.SamAccountName):$($user.Password) created successfully!" -ForegroundColor Red
                            }
                        catch 
                            {
                               Write-Error "Error creating user $($user.SamAccountName): $($_.Exception.Message)"
                            }
                    }
                    # Add users to Groups
                    Add-ADGroupMember -Identity $groupT0.Group[0] -Members t0admin
                    Add-ADGroupMember -Identity $DAName -Members $groupT0.Group[0]
                    write-warning "Change the default password of the t0admin user account."
                    write-warning "Use t0admin User account to connect to the Domain Controller."
                }

                # Launch the functions
                Write-Host "[Task : 2] Applying User Rights Assignemnt Tiering..                                                         " -ForegroundColor Green -NoNewline; Write-Host "[OK]" -ForegroundColor Green
                Default_Domain_controllers_policy
                $command = gpupdate /force

                Write-Host "[Task : 5] Successful.                                                                                       " -ForegroundColor Green -NoNewline; Write-Host "[OK]" -ForegroundColor Green           
                Write-Host ""
                Get-Content .\info.md
                Write-Host ""
        }

    elseif ( $VersionNumber.versionNumber -eq "35" )
        
        {
              $Pattern = "SeNetworkLogonRight",
                         "SeInteractiveLogonRight",
                         "SeRemoteInteractiveLogonRight",
                         "SeBatchLogonRight",
                         "SeMachineAccountPrivilege",
                         "SeDenyNetworkLogonRight",
                         "SeDenyBatchLogonRight",
                         "SeDenyServiceLogonRight",
                         "SeDenyInteractiveLogonRight",
                         "SeDenyRemoteInteractiveLogonRight"
                         
              Write-Host "[Task : 1] User Rights Assignment Tiering already configured.                                                " -ForegroundColor Green -NoNewline; Write-Host "[Ok]" -ForegroundColor Green
              $CheckContent = Get-Content $GptTmplPath
              $Content = $CheckContent | Select-String $Pattern
              
              Write-Host "" 
              $AdminsName = (Get-ADGroup -Filter "SID -eq ""S-1-5-32-544""").Name  # Administrators
              $GuestsName = (Get-ADGroup -Filter "SID -eq ""S-1-5-32-546""").Name  # Guests
              $BackupName = (Get-ADGroup -Filter "SID -eq ""S-1-5-32-551""").Name  # Backoup Operators
              $DAName = (Get-ADGroup -Filter "SID -eq ""$DomainSid-512""").Name    # Domain Admins
              $accountName = (Get-ADGroup -Filter "SID -eq ""S-1-5-32-548""").Name # Account Operators
              $ServerName = (Get-ADGroup -Filter "SID -eq ""S-1-5-32-549""").Name  # Server Operators
              $PrintName = (Get-ADGroup -Filter "SID -eq ""S-1-5-32-550""").Name   # Print Operators
              $EnterpriseDCName = (Get-WMIObject -Class 'Win32_Account' -Filter 'name="ENTERPRISE DOMAIN CONTROLLERS"').Name
              $AuthUserName = (Get-WMIObject -Class 'Win32_Account' -Filter 'name="Authenticated Users"').Name

              Write-Host "Log on as a batch job                         : " -ForegroundColor DarkGray -NoNewline; Write-Host $BackupName, $AdminsName, $groupT0.Group[0] -ForegroundColor DarkGray
              Write-Host "Log on locally                                : " -ForegroundColor DarkGray -NoNewline; Write-Host $BackupName, $AdminsName, $groupT0.Group[0] -ForegroundColor DarkGray 
              Write-Host "Add workstations to domain                    : " -ForegroundColor DarkGray -NoNewline; Write-Host $groupT2.Group[1], $DAName -ForegroundColor DarkGray
              Write-Host "Access this computer from the network         : " -ForegroundColor DarkGray -NoNewline; Write-Host $EnterpriseDCName, $AdminsName, $groupT0.Group[0] -ForegroundColor DarkGray
              Write-Host "Log on through Remote Desktop Services        : " -ForegroundColor DarkGray -NoNewline; Write-Host $groupT0.Group[0] -ForegroundColor DarkGray
              Write-Host "Attribute ms-DS-MachineAccountQuota is set to : " -ForegroundColor DarkGray -NoNewline; Write-Host "0" -ForegroundColor DarkGray  
              Write-Host ""
              Get-Content .\info.md
              Write-Host ""
              
        }
        

    elseif ( $MachineAccountQuota -eq "0" )            
        {
              Write-Host "[Task : 1] User Rights Assignment Tiering already configured.                                                " -ForegroundColor Green -NoNewline; Write-Host "[Ok]" -ForegroundColor Green

              $Pattern = "SeNetworkLogonRight",
                         "SeInteractiveLogonRight",
                         "SeRemoteInteractiveLogonRight",
                         "SeBatchLogonRight",
                         "SeMachineAccountPrivilege",
                         "SeDenyNetworkLogonRight",
                         "SeDenyBatchLogonRight",
                         "SeDenyServiceLogonRight",
                         "SeDenyInteractiveLogonRight",
                         "SeDenyRemoteInteractiveLogonRight"
                         
              #Write-Host "User Right Assignment Compliance has deployied" -ForegroundColor Green
              $Content = $CheckContent | Select-String $Pattern

              Write-Host "" 
              $AdminsName = (Get-ADGroup -Filter "SID -eq ""S-1-5-32-544""").Name  # Administrators
              $GuestsName = (Get-ADGroup -Filter "SID -eq ""S-1-5-32-546""").Name  # Guests
              $BackupName = (Get-ADGroup -Filter "SID -eq ""S-1-5-32-551""").Name  # Backoup Operators
              $DAName = (Get-ADGroup -Filter "SID -eq ""$DomainSid-512""").Name    # Domain Admins
              $accountName = (Get-ADGroup -Filter "SID -eq ""S-1-5-32-548""").Name # Account Operators
              $ServerName = (Get-ADGroup -Filter "SID -eq ""S-1-5-32-549""").Name  # Server Operators
              $PrintName = (Get-ADGroup -Filter "SID -eq ""S-1-5-32-550""").Name   # Print Operators
              $EnterpriseDCName = (Get-WMIObject -Class 'Win32_Account' -Filter 'name="ENTERPRISE DOMAIN CONTROLLERS"').Name
              $AuthUserName = (Get-WMIObject -Class 'Win32_Account' -Filter 'name="Authenticated Users"').Name
              write-host ""
              Write-Host "Log on as a batch job                         : " -ForegroundColor DarkGray -NoNewline; Write-Host $BackupName, $AdminsName, $groupT0.Group[0] -ForegroundColor DarkGray
              Write-Host "Log on locally                                : " -ForegroundColor DarkGray -NoNewline; Write-Host $BackupName, $AdminsName, $groupT0.Group[0] -ForegroundColor DarkGray 
              Write-Host "Add workstations to domain                    : " -ForegroundColor DarkGray -NoNewline; Write-Host $groupT2.Group[1], $DAName -ForegroundColor DarkGray
              Write-Host "Access this computer from the network         : " -ForegroundColor DarkGray -NoNewline; Write-Host $EnterpriseDCName, $AdminsName, $AuthUserName -ForegroundColor DarkGray
              Write-Host "Log on through Remote Desktop Services        : " -ForegroundColor DarkGray -NoNewline; Write-Host $groupT0.Group[0] -ForegroundColor DarkGray
              Write-Host "Attribute ms-DS-MachineAccountQuota is set to : " -ForegroundColor DarkGray -NoNewline; Write-Host "0" -ForegroundColor DarkGray                         
              Write-Host ""
              Get-Content .\info.md
              Write-Host ""
              
        }
        
    else
        {
            Write-Host "[Task : 1] Checking if Version Number doesn't modified, if not configuring User Rights Assignment Tiering.. " -ForegroundColor Green -NoNewline; Write-Host "[OK]" -ForegroundColor Green 
            function Default_Domain_controllers_policy 
                {
     
                    $Backup = "^SeBackupPrivilege.*"
                    $BatchLogonRight = "^SeBatchLogonRight.*"
                    $InteractiveLogonRight = "^SeInteractiveLogonRight.*"
                    $LoadDriver = "^SeLoadDriverPrivilege.*"
                    $MachineAccount = "^SeMachineAccountPrivilege.*"
                    $NetworkLogonRight = "^SeNetworkLogonRight.*"
                    $RemoteShutdown = "^SeRemoteShutdownPrivilege.*"
                    $Restore = "^SeRestorePrivilege.*"
                    $Shutdown = "^SeShutdownPrivilege.*"
                    $SystemTime = "^SeSystemTimePrivilege.*"

                    # Change Compliance CIS Benchmark

                    $URABackup = "SeBackupPrivilege = *$AdminsSid"
                    $URABatchlogonRight = "SeBatchLogonRight = *$BackupSid,*$AdminsSid,*$AdminT0Sid"
                    $URAInteractiveLogonRight = "SeInteractiveLogonRight = *$BackupSid,*$AdminsSid,*$AdminT0Sid"
                    $URALoadDriver = "SeLoadDriverPrivilege = *$AdminsSid"
                    $URAMachineAccount = "SeMachineAccountPrivilege = *$DASid,*$HelpdeskT2Sid"
                    $URANetworkLogonRight = "SeNetworkLogonRight = *$EnterpriseDCSid,*$AuthUserSid,*$AdminsSid"
                    $URARemoteShutdown = "SeRemoteShutdownPrivilege = *$AdminsSid"
                    $URARestore = "SeRestorePrivilege = *$AdminsSid"
                    $URAShutdown = "SeShutdownPrivilege = *$AdminsSid"
                    $URASystemTime = "SeSystemTimePrivilege = *$AdminsSid,*$LocalSrvSid"
          
                    # Add those lines after this pattern SeEnableDelegationPrivilege
                    $URARemoteInteractiveLogonRight = "SeRemoteInteractiveLogonRight = *$AdminT0Sid"
                    $URATimeZone = "SeTimeZonePrivilege = *$LocalSrvSid,*$AdminsSid"
                    $URACreateGlobal = "SeCreateGlobalPrivilege = *$ServiceSid,*$NetworkSrvSid,*$LocalSrvSid,*$AdminsSid"
                    $URACreateSymbolic = "SeCreateSymbolicLinkPrivilege = *$AdminsSid"
                    $URADenyNetLogonRight = "SeDenyNetworkLogonRight = *$GuestsSid"
                    $URADenyBatchLogonRight = "SeDenyBatchLogonRight = *$GuestsSid,*$AccountSid,*$PrintSid,*$ServerSid,*$JumpMainT1Sid,*$JumpUserT1Sid,*$AdminT1Sid,*$MainT1Sid,*$SrvAccountT1Sid,*$AdminT2Sid,*$HelpdeskT2Sid,*$UsersT2Sid,*$UserRemoteT2Sid"
                    $URADenyServiceLogonRight = "SeDenyServiceLogonRight = *$GuestsSid,*$AccountSid,*$PrintSid,*$ServerSid,*$JumpMainT1Sid,*$JumpUserT1Sid,*$AdminT1Sid,*$MainT1Sid,*$SrvAccountT1Sid,*$AdminT2Sid,*$HelpdeskT2Sid,*$UsersT2Sid,*$UserRemoteT2Sid"
                    $URADenyInteractiveLogonRight = "SeDenyInteractiveLogonRight = *$GuestsSid,*$AccountSid,*$PrintSid,*$ServerSid,*$JumpMainT1Sid,*$JumpUserT1Sid,*$AdminT1Sid,*$MainT1Sid,*$SrvAccountT1Sid,*$AdminT2Sid,*$HelpdeskT2Sid,*$UsersT2Sid,*$UserRemoteT2Sid"
                    $URADenyRemoteInteractiveLogonRight = "SeDenyRemoteInteractiveLogonRight = *$GuestsSid,*$AccountSid,*$PrintSid,*$ServerSid,*$JumpMainT1Sid,*$JumpUserT1Sid,*$AdminT1Sid,*$MainT1Sid,*$SrvAccountT1Sid,*$AdminT2Sid,*$HelpdeskT2Sid,*$UsersT2Sid,*$UserRemoteT2Sid"
                    $URAImpersonate = "SeImpersonatePrivilege = *$ServiceSid,*$NetworkSrvSid,*$LocalSrvSid,*$AdminsSid"
                    $URAIncreaseWorking = "SeIncreaseWorkingSetPrivilege = *$AdminsSid"
                    $URAMangeVolume = "SeManageVolumePrivilege = *$AdminsSid"
          
                    function Backup (){
                        $DCContent = Get-Content $GptTmplPath
                        $URA1 = $DCContent -replace $Backup, $URABackup
                        Set-Content $GptTmplPath $URA1
                    }
                    Backup

                    function BatchLogon (){
                        $DCContent = Get-Content $GptTmplPath
                        $URA2 = $DCContent -replace $BatchLogonRight, $URABatchLogonRight
                        Set-Content $GptTmplPath $URA2
                    }
                    BatchLogon         

                    function InteractiveLogon (){
                        $DCContent = Get-Content $GptTmplPath
                        $URA3 = $DCContent -replace $InteractiveLogonRight, $URAInteractiveLogonRight
                        Set-Content $GptTmplPath $URA3
                    }
                    InteractiveLogon

                    function LoadDriver (){
                        $DCContent = Get-Content $GptTmplPath
                        $URA4 = $DCContent -replace $LoadDriver, $URALoadDriver
                        Set-Content $GptTmplPath $URA4
                    }
                    LoadDriver

                    function MachineAccount (){
                        $DCContent = Get-Content $GptTmplPath
                        $URA5 = $DCContent -replace $MachineAccount, $URAMachineAccount
                        Set-Content $GptTmplPath $URA5
                    }
                    MachineAccount

                    function NetworkLogon (){
                        $DCContent = Get-Content $GptTmplPath
                        $URA6 = $DCContent -replace $NetworkLogonRight, $URANetworkLogonRight
                        Set-Content $GptTmplPath $URA6
                    }
                    NetworkLogon

                    function RemoteShutdown (){
                        $DCContent = Get-Content $GptTmplPath
                        $URA7 = $DCContent -replace $RemoteShutdown, $URARemoteShutdown
                        Set-Content $GptTmplPath $URA7
                    }
                    RemoteShutdown

                    function Restore (){
                        $DCContent = Get-Content $GptTmplPath
                        $URA8 = $DCContent -replace $Restore, $URARestore
                        Set-Content $GptTmplPath $URA8
                    }
                    Restore

                    function Shutdown (){
                        $DCContent = Get-Content $GptTmplPath
                        $URA9 = $DCContent -replace $Shutdown, $URAShutdown
                        Set-Content $GptTmplPath $URA9
                    }
                    Shutdown

                    function SystemTime (){
                        $DCContent = Get-Content $GptTmplPath
                        $URA10 = $DCContent -replace $SystemTime, $URASystemTime
                        Set-Content $GptTmplPath $URA10
                    }
                    SystemTime

                    #Add New line after a Pattern LockoutBadCount and Registy Values
                    $GptTmplPathVars = Get-Content $GptTmplPath | ForEach-Object {
     
                        $_
                        if ($_ -match "SeEnableDelegationPrivilege")
                            {
                                $URARemoteInteractiveLogonRight
                                $URATimeZone
                                $URACreateGlobal
                                $URACreateSymbolic
                                $URADenyNetLogonRight
                                $URADenyBatchLogonRight
                                $URADenyServiceLogonRight
                                $URADenyInteractiveLogonRight
                                $URADenyRemoteInteractiveLogonRight
                                $URAImpersonate
                                $URAIncreaseWorking
                                $URAMangeVolume
                            }
                    } 

                    $GptTmplPathVars > $GptTmplPath

                    # Edit GPT.INI and update Sysvol versionNumber
                    Write-Host "[Task : 3] Updating VersionNumber of the Default Domain Controllers policy...                                " -ForegroundColor Green -NoNewline; Write-Host "[OK]" -ForegroundColor Green 
                
                    $DCGptContent = Get-Content $GptIniPath
                    $DCGptContent = $DCGptContent -replace "Version=$InitialVNumber", "Version=$ResultVNumber"
                    Set-Content $GptIniPath $DCGptContent

                    # Update AD versionNumber

                    $VersionNumber = (Get-ADObject "CN={$($001Id)},$PathPolicy" -Properties *)
                    Set-ADObject -Identity $VersionNumber -Replace @{versionNumber="$ResultVNumber"}

                    # Change the attribute ms-DS-MachineAccountQuota
                    Write-Host "[Task : 4] Changing the value of the attribute ms-DS-MachineAccountQuota set to 0...                         " -ForegroundColor Green -NoNewline; Write-Host "[OK]" -ForegroundColor Green 
                
                    Set-ADDomain -Identity $FQDNDomainName -Replace @{"ms-DS-MachineAccountQuota"="0"}


                    # Create default T0 Admin for Domain Remote Access
                    Write-Host "[Task : 5] Creating default T0 Admin account...                                                              " -ForegroundColor Green -NoNewline; Write-Host "[OK]" -ForegroundColor Green 
                    $csvFilePath = ".\users.csv"
                    $dnsroot = '@' + (Get-ADDomain).dnsroot
                    $users = Import-Csv $csvFilePath

                    foreach ($user in $users) {
                        $newUserParams = @{
                            Name                = $user.DisplayName
                            GivenName           = $user.FirstName
                            Surname             = $user.LastName
                            SamAccountName       = $user.SamAccountName
                            UserPrincipalName   = $user.SamAccountName + $dnsroot
                            Path                = "OU=Admins,OU=Tier0,$ParentOu"
                            AccountPassword     = ConvertTo-SecureString $user.Password -AsPlainText -Force
                            Enabled             = [bool]$user.Enabled  # Convert string to boolean
                        }

                        try {
                                New-ADUser @newUserParams
                                Write-Host "Default User $($user.SamAccountName):$($user.Password) created successfully!"  -ForegroundColor Red
                            }
                        catch 
                            {
                               Write-Error "Error creating user $($user.SamAccountName): $($_.Exception.Message)"
                            }
                    }
                    # Add users to Groups
                    Add-ADGroupMember -Identity $groupT0.Group[0] -Members t0admin
                    Add-ADGroupMember -Identity $DAName -Members $groupT0.Group[0]
                    write-warning "Change the default password of the t0admin user account."
                    write-warning "Use t0admin User account to connect to the Domain Controller."
                }

                # Launch the functions
                Write-Host "[Task : 2] Applying User Rights Assignemnt Tiering...                                                                          " -ForegroundColor Green -NoNewline; Write-Host "[OK]" -ForegroundColor Green
                Default_Domain_controllers_policy
                $command = gpupdate /force

                Write-Host "[Task : 6] Successful.                                                                                                         " -ForegroundColor Green -NoNewline; Write-Host "[OK]" -ForegroundColor Green
                Write-Host ""
                Get-Content .\info.md
                Write-Host "" 
        }
}