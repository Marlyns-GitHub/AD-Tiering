write-host ""
Write-Host "[Task 0] : Gathering Domain Informations, Tiering Security Groups Ids, Default DC policy Id... " -ForegroundColor Green -NoNewline; Write-Host "[OK]" -ForegroundColor Green 

$DC = (Get-ADDomainController)
$Hostname = $DC.Name
$Domain = $DC.Domain
$DomainName = (Get-ADDomain).NetBIOSName
$FQDNDomainName = (Get-ADDomain).DnsRoot
$DomainSid = (Get-ADDomain).DomainSid.Value

$Checks = ".\GPOLists.md"
$CheckGPO = (Get-GPO -all | Select-Object -ExpandProperty DisplayName) | Out-File $Checks

$groupT0 = @(
                $(New-Object PSObject -Property @{Group = "Domain Tier0 Admins"; OUprefix = "OU=Groups,OU=Tier0" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier0 Service Accounts"; OUprefix = "OU=Groups,OU=Tier0" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier0 PAW Users"; OUprefix = "OU=Groups,OU=Tier0" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier0 PAW Maintenance"; OUprefix = "OU=Groups,OU=Tier0" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier0 Maintenance"; OUprefix = "OU=Groups,OU=Tier0" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier0 Remote Domain Controllers"; OUprefix = "OU=Groups,OU=Tier0" })
            )

$groupT1 = @(
                $(New-Object PSObject -Property @{Group = "Domain Tier1 Admins"; OUprefix = "OU=Groups,OU=Tier1" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier1 Service Accounts"; OUprefix = "OU=Groups,OU=Tier1" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier1 JumpServer Users"; OUprefix = "OU=Groups,OU=Tier1" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier1 Jumpserver Maintenance"; OUprefix = "OU=Groups,OU=Tier1" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier1 Maintenance"; OUprefix = "OU=Groups,OU=Tier1" })
                
            )

$groupT2 = @(
                $(New-Object PSObject -Property @{Group = "Domain Tier2 Admins"; OUprefix = "OU=Groups,OU=Tier2" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier2 HelpDesk Operators"; OUprefix = "OU=Groups,OU=Tier2" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier2 Remote Desktop Users"; OUprefix = "OU=Groups,OU=Tier2" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier2 Users"; OUprefix = "OU=Groups,OU=Tier2" })
)

$OUs = @(

       $(New-Object PSObject -Property @{Name = "Servers" }),
       $(New-Object PSObject -Property @{Name = "PAW" }),
       $(New-Object PSObject -Property @{Name = "Servers" }),
       $(New-Object PSObject -Property @{Name = "Jump Servers" }),
       $(New-Object PSObject -Property @{Name = "Laptops" }),
       $(New-Object PSObject -Property @{Name = "WorkStations" })

)

# Default Security Groups

$DASid = (Get-ADGroup -Filter "SID -eq ""$DomainSid-512""").SID.Value     # Domain Admins
$SchemaSid = (Get-ADGroup -Filter "SID -eq ""$DomainSid-518""").SID.Value # Schema Admins
$EASid = (Get-ADGroup -Filter "SID -eq ""$DomainSid-519""").SID.Value     # Enterprise Admins
$AdminsSid = (Get-ADGroup -Filter "SID -eq ""S-1-5-32-544""").SID.Value   # Administrators
$GuestsSid = (Get-ADGroup -Filter "SID -eq ""S-1-5-32-546""").SID.Value   # Guests
$AccountSid = (Get-ADGroup -Filter "SID -eq ""S-1-5-32-548""").SID.Value  # Account Operators
$ServerSid = (Get-ADGroup -Filter "SID -eq ""S-1-5-32-549""").SID.Value   # Server Operators
$PrintSid = (Get-ADGroup -Filter "SID -eq ""S-1-5-32-550""").SID.Value    # Print Operators
$BackupSid = (Get-ADGroup -Filter "SID -eq ""S-1-5-32-551""").SID.Value   # Backoup Operators
$RDUserSId = (Get-ADGroup -Filter "SID -eq ""S-1-5-32-555""").SID.Value   # Remote Desktop Users
$AuthUserSid = (Get-WMIObject -Class 'Win32_Account' -Filter 'name="Authenticated Users"').Sid  # Authenticated Users

$DAName = (Get-ADGroup -Filter "SID -eq ""$DomainSid-512""").Name     # Domain Admins
$SchemaName = (Get-ADGroup -Filter "SID -eq ""$DomainSid-518""").Name # Schema Admins
$EAName = (Get-ADGroup -Filter "SID -eq ""$DomainSid-519""").Name     # Enterprise Admins
$AdminsName = (Get-ADGroup -Filter "SID -eq ""S-1-5-32-544""").Name   # Administrators
$GuestsName = (Get-ADGroup -Filter "SID -eq ""S-1-5-32-546""").Name   # Guests
$AccountName = (Get-ADGroup -Filter "SID -eq ""S-1-5-32-548""").Name  # Account Operators
$ServerName = (Get-ADGroup -Filter "SID -eq ""S-1-5-32-549""").Name   # Server Operators
$PrintName = (Get-ADGroup -Filter "SID -eq ""S-1-5-32-550""").Name    # Print Operators
$BackupName = (Get-ADGroup -Filter "SID -eq ""S-1-5-32-551""").Name   # Backoup Operators

# Create GPOs Tiered Model and Local Admins
$GPOLists = "000_T0_RestrictedLogon",
            "000_T1_RestrictedLogon",
            "000_T2_RestrictedLogon",
            "000_PAW_RestrictedLogon_T0",
            "000_JumpSrv_RestrictedLogon_T1",
            "001_T0_LocalAdmins",
            "001_T1_LocalAdmins",
            "001_T2_LocalAdmins",
            "001_PAW_LocalAdmins_T0",
            "001_JumpSrv_LocalAdmins_T1",
            "002_T2_RemoteDesktopUsers"
# Template
$Template="[Unicode]
Unicode=yes
[Version]
signature=`"`$CHICAGO$`"
Revision=1"

# Check if the compliance CIS hardening has been configured...

if ((Get-Content $Checks | Select-String -Pattern "000_T0") -and
    (Get-Content $Checks | Select-String -Pattern "000_T1") -and
    (Get-Content $Checks | Select-String -Pattern "000_T2") -and
    (Get-Content $Checks | Select-String -Pattern "000_PAW") -and
    (Get-Content $Checks | Select-String -Pattern "000_JumpSrv") -and
    (Get-Content $Checks | Select-String -Pattern "001_T0") -and
    (Get-Content $Checks | Select-String -Pattern "001_T1") -and
    (Get-Content $Checks | Select-String -Pattern "001_T2") -and
    (Get-Content $Checks | Select-String -Pattern "001_PAW") -and
    (Get-Content $Checks | Select-String -Pattern "001_JumpSrv") -and
    (Get-Content $Checks | Select-String -Pattern "002_T2")
   )  
    {
        
        $000Id = (Get-GPO -Name $GPOLists[0]).Id.ToString()
        $001Id = (Get-GPO -Name $GPOLists[1]).Id.ToString()
        $002Id = (Get-GPO -Name $GPOLists[2]).Id.ToString()
        $003Id = (Get-GPO -Name $GPOLists[3]).Id.ToString()
        $004Id = (Get-GPO -Name $GPOLists[4]).Id.ToString()
        $005Id = (Get-GPO -Name $GPOLists[5]).Id.ToString()
        $006Id = (Get-GPO -Name $GPOLists[6]).Id.ToString()
        $007Id = (Get-GPO -Name $GPOLists[7]).Id.ToString()
        $008Id = (Get-GPO -Name $GPOLists[8]).Id.ToString()
        $009Id = (Get-GPO -Name $GPOLists[9]).Id.ToString()
        $010Id = (Get-GPO -Name $GPOLists[10]).Id.ToString()
   
        # Create SecEdit directory and GptTmpl.inf file

        if (!(Get-Content -Path "\\$Hostname\Sysvol\$Domain\Policies\{$($000Id)}\GPT.INI" | Select-String -Pattern Version=0 ) -and
            !(Get-Content -Path "\\$Hostname\Sysvol\$Domain\Policies\{$($001Id)}\GPT.INI" | Select-string -Pattern Version=0 ) -and
            !(Get-Content -Path "\\$Hostname\Sysvol\$Domain\Policies\{$($002Id)}\GPT.INI" | Select-string -Pattern Version=0 ) -and
            !(Get-Content -Path "\\$Hostname\Sysvol\$Domain\Policies\{$($003Id)}\GPT.INI" | Select-string -Pattern Version=0 ) -and
            !(Get-Content -Path "\\$Hostname\Sysvol\$Domain\Policies\{$($004Id)}\GPT.INI" | Select-string -Pattern Version=0 ) -and
            !(Get-Content -Path "\\$Hostname\Sysvol\$Domain\Policies\{$($005Id)}\GPT.INI" | Select-string -Pattern Version=0 ) -and
            !(Get-Content -Path "\\$Hostname\Sysvol\$Domain\Policies\{$($006Id)}\GPT.INI" | Select-string -Pattern Version=0 ) -and
            !(Get-Content -Path "\\$Hostname\Sysvol\$Domain\Policies\{$($007Id)}\GPT.INI" | Select-string -Pattern Version=0 ) -and
            !(Get-Content -Path "\\$Hostname\Sysvol\$Domain\Policies\{$($008Id)}\GPT.INI" | Select-string -Pattern Version=0 ) -and
            !(Get-Content -Path "\\$Hostname\Sysvol\$Domain\Policies\{$($009Id)}\GPT.INI" | Select-string -Pattern Version=0 ) -and
            !(Get-Content -Path "\\$Hostname\Sysvol\$Domain\Policies\{$($010Id)}\GPT.INI" | Select-string -Pattern Version=0 )
           )
            {
                Write-Host "[Task 1] : Restricted Logon for T0, T1 and T2 already configured.                              " -ForegroundColor Green -NoNewline; Write-Host "[Ok]" -ForegroundColor Green
            }
        else
            {
                Write-Host "[Task 1] : Configuring GPOs, creating SecEdit directory and GptTmpl.inf files...               " -ForegroundColor Green -NoNewline; Write-Host "[Ok]" -ForegroundColor Green
                
                $SecEdit0 = New-Item "\\$Hostname\Sysvol\$Domain\Policies\{$($000Id)}\Machine\Microsoft\Windows NT\SecEdit" -ItemType Directory
                $SecEdit1 = New-Item "\\$Hostname\Sysvol\$Domain\Policies\{$($001Id)}\Machine\Microsoft\Windows NT\SecEdit" -ItemType Directory
                $SecEdit2 = New-Item "\\$Hostname\Sysvol\$Domain\Policies\{$($002Id)}\Machine\Microsoft\Windows NT\SecEdit" -ItemType Directory
                $SecEdit3 = New-Item "\\$Hostname\Sysvol\$Domain\Policies\{$($003Id)}\Machine\Microsoft\Windows NT\SecEdit" -ItemType Directory
                $SecEdit4 = New-Item "\\$Hostname\Sysvol\$Domain\Policies\{$($004Id)}\Machine\Microsoft\Windows NT\SecEdit" -ItemType Directory
                $SecEdit5 = New-Item "\\$Hostname\Sysvol\$Domain\Policies\{$($005Id)}\Machine\Microsoft\Windows NT\SecEdit" -ItemType Directory
                $SecEdit6 = New-Item "\\$Hostname\Sysvol\$Domain\Policies\{$($006Id)}\Machine\Microsoft\Windows NT\SecEdit" -ItemType Directory
                $SecEdit7 = New-Item "\\$Hostname\Sysvol\$Domain\Policies\{$($007Id)}\Machine\Microsoft\Windows NT\SecEdit" -ItemType Directory
                $SecEdit8 = New-Item "\\$Hostname\Sysvol\$Domain\Policies\{$($008Id)}\Machine\Microsoft\Windows NT\SecEdit" -ItemType Directory
                $SecEdit9 = New-Item "\\$Hostname\Sysvol\$Domain\Policies\{$($009Id)}\Machine\Microsoft\Windows NT\SecEdit" -ItemType Directory
                $SecEdit10 = New-Item "\\$Hostname\Sysvol\$Domain\Policies\{$($010Id)}\Machine\Microsoft\Windows NT\SecEdit" -ItemType Directory
        
                $Template | Out-File "$SecEdit0\GptTmpl.inf"; $gptFile0 = "$SecEdit0\GptTmpl.inf"
                $Template | Out-File "$SecEdit1\GptTmpl.inf"; $gptFile1 = "$SecEdit1\GptTmpl.inf"
                $Template | Out-File "$SecEdit2\GptTmpl.inf"; $gptFile2 = "$SecEdit2\GptTmpl.inf"
                $Template | Out-File "$SecEdit3\GptTmpl.inf"; $gptFile3 = "$SecEdit3\GptTmpl.inf"
                $Template | Out-File "$SecEdit4\GptTmpl.inf"; $gptFile4 = "$SecEdit4\GptTmpl.inf"
                $Template | Out-File "$SecEdit5\GptTmpl.inf"; $gptFile5 = "$SecEdit5\GptTmpl.inf"
                $Template | Out-File "$SecEdit6\GptTmpl.inf"; $gptFile6 = "$SecEdit6\GptTmpl.inf"
                $Template | Out-File "$SecEdit7\GptTmpl.inf"; $gptFile7 = "$SecEdit7\GptTmpl.inf"
                $Template | Out-File "$SecEdit8\GptTmpl.inf"; $gptFile8 = "$SecEdit8\GptTmpl.inf"
                $Template | Out-File "$SecEdit9\GptTmpl.inf"; $gptFile9 = "$SecEdit9\GptTmpl.inf"
                $Template | Out-File "$SecEdit10\GptTmpl.inf"; $gptFile10 = "$SecEdit10\GptTmpl.inf"

                # Sysvol versionNumber Gpt.INI file path

                $GptIni0 = "\\$Hostname\Sysvol\$Domain\Policies\{$($000Id)}\GPT.INI"
                $GptIni1 = "\\$Hostname\Sysvol\$Domain\Policies\{$($001Id)}\GPT.INI"
                $GptIni2 = "\\$Hostname\Sysvol\$Domain\Policies\{$($002Id)}\GPT.INI"
                $GptIni3 = "\\$Hostname\Sysvol\$Domain\Policies\{$($003Id)}\GPT.INI"
                $GptIni4 = "\\$Hostname\Sysvol\$Domain\Policies\{$($004Id)}\GPT.INI"
                $GptIni5 = "\\$Hostname\Sysvol\$Domain\Policies\{$($005Id)}\GPT.INI"
                $GptIni6 = "\\$Hostname\Sysvol\$Domain\Policies\{$($006Id)}\GPT.INI"
                $GptIni7 = "\\$Hostname\Sysvol\$Domain\Policies\{$($007Id)}\GPT.INI"
                $GptIni8 = "\\$Hostname\Sysvol\$Domain\Policies\{$($008Id)}\GPT.INI"
                $GptIni9 = "\\$Hostname\Sysvol\$Domain\Policies\{$($009Id)}\GPT.INI"
                $GptIni10 = "\\$Hostname\Sysvol\$Domain\Policies\{$($010Id)}\GPT.INI"
        }
    }
else 
    {
       Write-Warning "This script depends on the scripts 2) Create Tiering Security Groups and 3) Create Tiering GPOs."
       Write-Host ""            
       Get-Content .\info.md
       Write-Host"" 
       exit
    }

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

# GPO Default directory path and pPCMachineExtensionNames attribute

$PathPolicy = (Get-ADObject -Filter 'Name -eq "Policies"' -Properties * | Where-Object ObjectClass -eq container | Select-Object Name, distinguishedName).DistinguishedName    
$pPCMachineExtensionNames = "{827D319E-6EAC-11D2-A4EA-00C04F79F83A}{803E14A0-B4FB-11D0-A0D0-00A0C90F574B}"

# Function Update GptTmpl.inf file

function Logon_T0 () 
    {

        $VersionNumber = (Get-ADObject "CN={$($000Id)},$PathPolicy" -Properties *)
        $VersionNumber.versionNumber | ForEach {

            if ( $VersionNumber.versionNumber -eq "16" )
                {
                    write-host ""
                    write-host "Restricted Logon Tier 0 already configured : " -ForegroundColor Green
                    write-host ""
                    Write-Host "Access this computer from the network       : " -ForegroundColor DarkGray -NoNewline; Write-Host $BackupName, $AdminsName, $groupT0.Group[0] -ForegroundColor DarkGray
                    Write-Host "Log on locally                              : " -ForegroundColor DarkGray -NoNewline; Write-Host $BackupName, $AdminsName, $groupT0.Group[0], $groupT0.Group[1], $groupT0.Group[4] -ForegroundColor DarkGray 
                    Write-Host "Log on through Remote Desktop Services      : " -ForegroundColor DarkGray -NoNewline; Write-Host $groupT0.Group[0] -ForegroundColor DarkGray
                    Write-Host "Log on as a batch job                       : " -ForegroundColor DarkGray -NoNewline; Write-Host $BackupName, $AdminsName, $groupT0.Group[1], $groupT0.Group[4] -ForegroundColor DarkGray
                    Write-Host "Log on as a service                         : " -ForegroundColor DarkGray -NoNewline; Write-Host $BackupName, $AdminsName, $groupT0.Group[1], $groupT0.Group[4] -ForegroundColor DarkGray
                }
            else       
                {
                    # Allows Section
                    $addURABatch = "SeBatchLogonRight = *$($AdminsSid),*$($BackupSid),*$($MainT0Sid),*$($SrvAccountT0Sid)"
                    $addURAService = "SeServiceLogonRight = *$($AdminsSid),*$($BackupSid),*$($MainT0Sid),*$($SrvAccountT0Sid)"
                    $addURARemote = "SeRemoteInteractiveLogonRight = *$($AdminT0Sid)"
                    $addURALocally = "SeInteractiveLogonRight = *$($AdminsSid),*$($BackupSid),*$($AdminT0Sid),*$($MainT0Sid),*$($SrvAccountT0Sid)"

                    # Deny section
                    $addURADenyBatch = "SeDenyBatchLogonRight = *$($AdminT1Sid),*$($SrvAccountT1Sid),*$($MainT1Sid),*$($JumpMainT1Sid),*$($JumpUserT1Sid),*$($AdminT2Sid),*$($UsersT2Sid),*$($HelpdeskT2Sid),*$($UserRemoteT2Sid),*$($PAWUserT0Sid),*$($PAWMainT0Sid),*$($RemoteDCT0Sid),*$($AccountSid),*$($PrintSid),*$($ServerSid)"
                    $addURADenyService = "SeDenyServiceLogonRight = *$($AdminT1Sid),*$($SrvAccountT1Sid),*$($MainT1Sid),*$($JumpMainT1Sid),*$($JumpUserT1Sid),*$($AdminT2Sid),*$($UsersT2Sid),*$($HelpdeskT2Sid),*$($UserRemoteT2Sid),*$($PAWUserT0Sid),*$($PAWMainT0Sid),*$($RemoteDCT0Sid),*$($AccountSid),*$($PrintSid),*$($ServerSid)"
                    $addURADenyRemote = "SeDenyRemoteInteractiveLogonRight = *$($AdminT1Sid),*$($SrvAccountT1Sid),*$($MainT1Sid),*$($JumpMainT1Sid),*$($JumpUserT1Sid),*$($AdminT2Sid),*$($UsersT2Sid),*$($HelpdeskT2Sid),*$($UserRemoteT2Sid),*$($PAWUserT0Sid),*$($PAWMainT0Sid),*$($MainT0Sid),*$($RemoteDCT0Sid),*$($SrvAccountT0Sid),*$($AccountSid),*$($PrintSid),*$($ServerSid)"
                    $addURADenyLocally = "SeDenyInteractiveLogonRight = *$($AdminT1Sid),*$($SrvAccountT1Sid),*$($MainT1Sid),*$($JumpMainT1Sid),*$($JumpUserT1Sid),*$($AdminT2Sid),*$($UsersT2Sid),*$($HelpdeskT2Sid),*$($UserRemoteT2Sid),*$($PAWUserT0Sid),*$($PAWMainT0Sid),*$($RemoteDCT0Sid),*$($AccountSid),*$($PrintSid),*$($ServerSid)"

                    # Edit GptTmpl.inf
                    Add-Content -Path $gptFile0 -Value '[Privilege Rights]'
                    Add-Content -Path $gptFile0 -Value $addURABatch
                    Add-Content -Path $gptFile0 -Value $addURAService 
                    Add-Content -Path $gptFile0 -Value $addURARemote
                    Add-Content -Path $gptFile0 -Value $addURALocally
                    Add-Content -Path $gptFile0 -Value $addURADenyBatch
                    Add-Content -Path $gptFile0 -Value $addURADenyService
                    Add-Content -Path $gptFile0 -Value $addURADenyRemote
                    Add-Content -Path $gptFile0 -Value $addURADenyLocally

                    $getGPOT0 = (Get-ADObject "CN={$($000Id)},$PathPolicy").DistinguishedName  
                    Set-ADObject -Identity $getGPOT0 -Replace @{gPCMachineExtensionNames="[$pPCMachineExtensionNames]"} 
      
                    # Edit GPT.INI and update Sysvol versionNumber

                    $GptContent = Get-Content $GptIni0
                    $GptContent = $GptContent -replace "Version=0", "Version=16"
                    Set-Content $GptIni0 $GptContent

                    # Update AD versionNumber

                    $VersionNumberT0 = (Get-ADObject "CN={$($000Id)},$PathPolicy" -Properties *)
                    Set-ADObject -Identity $VersionNumberT0 -Replace @{versionNumber="16"}
            }    
       }
   }

function Logon_T1 ()
    {    
        $VersionNumber = (Get-ADObject "CN={$($001Id)},$PathPolicy" -Properties *)
        $VersionNumber.versionNumber | ForEach {

            if ( $VersionNumber.versionNumber -eq "16" )
                {
                    write-host ""
                    write-host "Restricted Logon Tier 1 already configured : " -ForegroundColor Green
                    write-host ""
                    Write-Host "Access this computer from the network       : " -ForegroundColor DarkGray -NoNewline; Write-Host $BackupName, $AdminsName, $GroupT1.Group[0] -ForegroundColor DarkGray
                    Write-Host "Log on locally                              : " -ForegroundColor DarkGray -NoNewline; Write-Host $BackupName, $AdminsName, $GroupT1.Group[0], $GroupT1.Group[1], $GroupT1.Group[4] -ForegroundColor DarkGray 
                    Write-Host "Log on through Remote Desktop Services      : " -ForegroundColor DarkGray -NoNewline; Write-Host $GroupT1.Group[0] -ForegroundColor DarkGray
                    Write-Host "Log on as a batch job                       : " -ForegroundColor DarkGray -NoNewline; Write-Host $BackupName, $AdminsName,$groupT1.Group[1], $groupT1.Group[4] -ForegroundColor DarkGray
                    Write-Host "Log on as a service                         : " -ForegroundColor DarkGray -NoNewline; Write-Host $BackupName, $AdminsName, $groupT1.Group[1], $GroupT1.Group[4] -ForegroundColor DarkGray
                }
            else  
                {
                    #Allows Section
                    $addURABatch = "SeBatchLogonRight = *$($AdminsSid),*$($BackupSid),*$($MainT1Sid),*$($SrvAccountT1Sid)"
                    $addURAService = "SeServiceLogonRight = *$($AdminsSid),*$($BackupSid),*$($MainT1Sid),*$($SrvAccountT1Sid)"
                    $addURARemote = "SeRemoteInteractiveLogonRight = *$($AdminT1Sid),*$($UserRemoteT2Sid)"
                    $addURALocally = "SeInteractiveLogonRight = *$($AdminsSid),*$($BackupSid),*$($AdminT1Sid),*$($MainT1Sid),*$($SrvAccountT1Sid)"

                    # Deny section
                    $addURADenyBatch = "SeDenyBatchLogonRight = *$($AdminT0Sid),*$($SrvAccountT0Sid),*$($MainT0Sid),*$($PAWUserT0Sid),*$($PAWMainT0Sid),*$($RemoteDCT0Sid),*$($JumpMainT1Sid),*$($JumpUserT1Sid),*$($AdminT2Sid),*$($UsersT2Sid),*$($HelpdeskT2Sid),*$($UserRemoteT2Sid),*$($DASid),*$($EASid),*$($SchemaSid),*$($AccountSid),*$($PrintSid),*$($ServerSid)"
                    $addURADenyService = "SeDenyServiceLogonRight = *$($AdminT0Sid),*$($SrvAccountT0Sid),*$($MainT0Sid),*$($PAWUserT0Sid),*$($PAWMainT0Sid),*$($RemoteDCT0Sid),*$($JumpMainT1Sid),*$($JumpUserT1Sid),*$($AdminT2Sid),*$($UsersT2Sid),*$($HelpdeskT2Sid),*$($UserRemoteT2Sid),*$($DASid),*$($EASid),*$($SchemaSid),*$($AccountSid),*$($PrintSid),*$($ServerSid)"
                    $addURADenyRemote = "SeDenyRemoteInteractiveLogonRight = *$($AdminsSid),*$($AdminT0Sid),*$($SrvAccountT0Sid),*$($MainT0Sid),*$($PAWUserT0Sid),*$($PAWMainT0Sid),*$($RemoteDCT0Sid),*$($JumpMainT1Sid),*$($JumpUserT1Sid),*$($MainT1Sid),*$($SrvAccountT1Sid),*$($AdminT2Sid),*$($UsersT2Sid),*$($HelpdeskT2Sid),*$($UserRemoteT2Sid),*$($DASid),*$($EASid),*$($SchemaSid),*$($AccountSid),*$($PrintSid),*$($ServerSid)"
                    $addURADenyLocally = "SeDenyInteractiveLogonRight = *$($AdminT0Sid),*$($SrvAccountT0Sid),*$($MainT0Sid),*$($PAWUserT0Sid),*$($PAWMainT0Sid),*$($RemoteDCT0Sid),*$($JumpMainT1Sid),*$($JumpUserT1Sid),*$($AdminT2Sid),*$($UsersT2Sid),*$($HelpdeskT2Sid),*$($UserRemoteT2Sid),*$($DASid),*$($EASid),*$($SchemaSid),*$($AccountSid),*$($PrintSid),*$($ServerSid)"

                    # Edit GptTmpl.inf
                    Add-Content -Path $gptFile1 -Value '[Privilege Rights]'
                    Add-Content -Path $gptFile1 -Value $addURABatch
                    Add-Content -Path $gptFile1 -Value $addURAService 
                    Add-Content -Path $gptFile1 -Value $addURARemote
                    Add-Content -Path $gptFile1 -Value $addURALocally
                    Add-Content -Path $gptFile1 -Value $addURADenyBatch
                    Add-Content -Path $gptFile1 -Value $addURADenyService
                    Add-Content -Path $gptFile1 -Value $addURADenyRemote
                    Add-Content -Path $gptFile1 -Value $addURADenyLocally

                    $getGPOT1 = (Get-ADObject "CN={$($001Id)},$PathPolicy").DistinguishedName
                    Set-ADObject -Identity $getGPOT1 -Replace @{gPCMachineExtensionNames="[$pPCMachineExtensionNames]"}

                    # Edit GPT.INI and update Sysvol versionNumber

                    $GptContent = Get-Content $GptIni1
                    $GptContent = $GptContent -replace "Version=0", "Version=16"
                    Set-Content $GptIni1 $GptContent

                    # Update AD versionNumber

                    $VersionNumberT1 = (Get-ADObject "CN={$($001Id)},$PathPolicy" -Properties *)
                    Set-ADObject -Identity $VersionNumberT1 -Replace @{versionNumber="16"}
                }
        }
    }

function Logon_T2 () 
    {

        $VersionNumber = (Get-ADObject "CN={$($002Id)},$PathPolicy" -Properties *)
        $VersionNumber.versionNumber | ForEach {

            if ( $VersionNumber.versionNumber -eq "10" )
                {      
                    write-host ""
                    write-host "Restricted Logon Tier 2 already configured : " -ForegroundColor Green
                    write-host ""
                }
            else
                {
                    # Deny section
                    $addURADenyBatch = "SeDenyBatchLogonRight = *$($AdminsSid),*$($AdminT0Sid),*$($SrvAccountT0Sid),*$($MainT0Sid),*$($PAWUserT0Sid),*$($PAWMainT0Sid),*$($RemoteDCT0Sid),*$($AdminT1Sid),*$($SrvAccountT1Sid),*$($MainT1Sid),*$($JumpMainT1Sid),*$($JumpUserT1Sid),*$($HelpdeskT2Sid),*$($DASid),*$($EASid),*$($SchemaSid),*$($AccountSid),*$($PrintSid),*$($ServerSid),*$($BackupSid)"
                    $addURADenyService = "SeDenyServiceLogonRight = *$($AdminsSid),*$($AdminT0Sid),*$($SrvAccountT0Sid),*$($MainT0Sid),*$($PAWUserT0Sid),*$($PAWMainT0Sid),*$($RemoteDCT0Sid),*$($AdminT1Sid),*$($SrvAccountT1Sid),*$($MainT1Sid),*$($JumpMainT1Sid),*$($JumpUserT1Sid),*$($HelpdeskT2Sid),*$($DASid),*$($EASid),*$($SchemaSid),*$($AccountSid),*$($PrintSid),*$($ServerSid),*$($BackupSid)"
                    $addURADenyRemote = "SeDenyRemoteInteractiveLogonRight = *$($AdminsSid),*$($AdminT0Sid),*$($SrvAccountT0Sid),*$($MainT0Sid),*$($PAWUserT0Sid),*$($PAWMainT0Sid),*$($RemoteDCT0Sid),*$($AdminT1Sid),*$($SrvAccountT1Sid),*$($MainT1Sid),*$($JumpMainT1Sid),*$($JumpUserT1Sid),*$($HelpdeskT2Sid),*$($DASid),*$($EASid),*$($SchemaSid),*$($AccountSid),*$($PrintSid),*$($ServerSid),*$($BackupSid)"
                    $addURADenyLocally = "SeDenyInteractiveLogonRight = *$($AdminT0Sid),*$($SrvAccountT0Sid),*$($MainT0Sid),*$($PAWUserT0Sid),*$($PAWMainT0Sid),*$($RemoteDCT0Sid),*$($AdminT1Sid),*$($SrvAccountT1Sid),*$($MainT1Sid),*$($JumpMainT1Sid),*$($JumpUserT1Sid),*$($HelpdeskT2Sid),*$($DASid),*$($EASid),*$($SchemaSid),*$($AccountSid),*$($PrintSid),*$($ServerSid),*$($BackupSid)"
                    $addURADenyNetwork = "SeDenyNetworkLogonRight = *$($AdminsSid),*$($AdminT0Sid),*$($SrvAccountT0Sid),*$($MainT0Sid),*$($PAWUserT0Sid),*$($PAWMainT0Sid),*$($RemoteDCT0Sid),*$($AdminT1Sid),*$($SrvAccountT1Sid),*$($MainT1Sid),*$($JumpMainT1Sid),*$($JumpUserT1Sid),*$($HelpdeskT2Sid),*$($DASid),*$($EASid),*$($SchemaSid),*$($AccountSid),*$($PrintSid),*$($ServerSid),*$($BackupSid)"

                    # Edit GptTmpl.inf
                    Add-Content -Path $gptFile2 -Value '[Privilege Rights]'
                    Add-Content -Path $gptFile2 -Value $addURADenyBatch
                    Add-Content -Path $gptFile2 -Value $addURADenyService
                    Add-Content -Path $gptFile2 -Value $addURADenyRemote
                    Add-Content -Path $gptFile2 -Value $addURADenyLocally
                    Add-Content -Path $gptFile2 -Value $addURADenyNetwork

                    $getGPOT2 = (Get-ADObject "CN={$($002Id)},$PathPolicy").DistinguishedName
                    Set-ADObject -Identity $getGPOT2 -Replace @{gPCMachineExtensionNames="[$pPCMachineExtensionNames]"}

                    # Edit GPT.INI and update Sysvol versionNumber

                    $GptContent = Get-Content $GptIni2
                    $GptContent = $GptContent -replace "Version=0", "Version=10"
                    Set-Content $GptIni2 $GptContent

                    # Update AD versionNumber

                    $VersionNumberT2 = (Get-ADObject "CN={$($002Id)},$PathPolicy" -Properties *)
                    Set-ADObject -Identity $VersionNumberT2 -Replace @{versionNumber="10"}
                }  
       }
    }

### PAW
function Logon_PAW_T0 () 
     {
        $VersionNumber = (Get-ADObject "CN={$($003Id)},$PathPolicy" -Properties *)
        $VersionNumber.versionNumber | ForEach {

            if ( $VersionNumber.versionNumber -eq "16" )
                {
                    write-host ""
                    write-host "Restricted Logon PAW Tier 0 alread Configured : " -ForegroundColor Green
                    write-host ""
                    Write-Host "Log on locally                              : " -ForegroundColor DarkGray -NoNewline; Write-Host $AdminsName, $groupT0.Group[1], $groupT0.Group[2], $groupT0.Group[3] -ForegroundColor DarkGray 
                    Write-Host "Log on through Remote Desktop Services      : " -ForegroundColor DarkGray -NoNewline; Write-Host $groupT0.Group[2] -ForegroundColor DarkGray
                    Write-Host "Log on as a batch job                       : " -ForegroundColor DarkGray -NoNewline; Write-Host $AdminsName, $groupT0.Group[1], $groupT0.Group[3] -ForegroundColor DarkGray
                    Write-Host "Log on as a service                         : " -ForegroundColor DarkGray -NoNewline; Write-Host $AdminsName, $groupT0.Group[1], $groupT0.Group[3] -ForegroundColor DarkGray 
                }
            else 
                {
                    # Allows Section
                    $addURABatch = "SeBatchLogonRight = *$($AdminsSid),*$($PAWMainT0Sid),*$($SrvAccountT0Sid)"
                    $addURAService = "SeServiceLogonRight = *$($AdminsSid),*$($PAWMainT0Sid),*$($SrvAccountT0Sid)"
                    $addURARemote = "SeRemoteInteractiveLogonRight = *$($PAWUserT0Sid)"
                    $addURALocally = "SeInteractiveLogonRight = *$($AdminsSid),*$($PAWMainT0Sid),*$($PAWUserT0Sid),*$($SrvAccountT0Sid)"
      
                    # Deny section
                    $addURADenyBatch = "SeDenyBatchLogonRight = *$($AdminT0Sid),*$($MainT0Sid),*$($RemoteDCT0Sid),*$($AdminT1Sid),*$($SrvAccountT1Sid),*$($MainT1Sid),*$($JumpMainT1Sid),*$($JumpUserT1Sid),*$($AdminT2Sid),*$($UsersT2Sid),*$($HelpdeskT2Sid),*$($UserRemoteT2Sid),*$($DASid),*$($EASid),*$($SchemaSid),*$($AccountSid),*$($PrintSid),*$($ServerSid),*$($BackupSid)"
                    $addURADenyService = "SeDenyServiceLogonRight = *$($AdminT0Sid),*$($MainT0Sid),*$($RemoteDCT0Sid),*$($AdminT1Sid),*$($SrvAccountT1Sid),*$($MainT1Sid),*$($JumpMainT1Sid),*$($JumpUserT1Sid),*$($AdminT2Sid),*$($UsersT2Sid),*$($HelpdeskT2Sid),*$($UserRemoteT2Sid),*$($DASid),*$($EASid),*$($SchemaSid),*$($AccountSid),*$($PrintSid),*$($ServerSid),*$($BackupSid)"
                    $addURADenyRemote = "SeDenyRemoteInteractiveLogonRight = *$($AdminsSid),*$($AdminT0Sid),*$($RemoteDCT0Sid),*$($SrvAccountT0Sid),*$($PAWMainT0Sid),*$($MainT0Sid),*$($AdminT1Sid),*$($SrvAccountT1Sid),*$($MainT1Sid),*$($JumpMainT1Sid),*$($JumpUserT1Sid),*$($AdminT2Sid),*$($UsersT2Sid),*$($HelpdeskT2Sid),*$($UserRemoteT2Sid),*$($DASid),*$($EASid),*$($SchemaSid),*$($AccountSid),*$($PrintSid),*$($ServerSid),*$($BackupSid)"
                    $addURADenyLocally = "SeDenyInteractiveLogonRight = *$($AdminT0Sid),*$($RemoteDCT0Sid),*$($MainT0Sid),*$($AdminT1Sid),*$($SrvAccountT1Sid),*$($MainT1Sid),*$($JumpMainT1Sid),*$($JumpUserT1Sid),*$($AdminT2Sid),*$($UsersT2Sid),*$($HelpdeskT2Sid),*$($UserRemoteT2Sid),*$($DASid),*$($EASid),*$($SchemaSid),*$($AccountSid),*$($PrintSid),*$($ServerSid),*$($BackupSid)"

                    # Edit GptTmpl.inf
                    Add-Content -Path $gptFile3 -Value '[Privilege Rights]'
                    Add-Content -Path $gptFile3 -Value $addURABatch
                    Add-Content -Path $gptFile3 -Value $addURAService 
                    Add-Content -Path $gptFile3 -Value $addURARemote
                    Add-Content -Path $gptFile3 -Value $addURALocally
                    Add-Content -Path $gptFile3 -Value $addURADenyBatch
                    Add-Content -Path $gptFile3 -Value $addURADenyService
                    Add-Content -Path $gptFile3 -Value $addURADenyRemote
                    Add-Content -Path $gptFile3 -Value $addURADenyLocally

                    $getGPOT3 = (Get-ADObject "CN={$($003Id)},$PathPolicy").DistinguishedName
                    Set-ADObject -Identity $getGPOT3 -Replace @{gPCMachineExtensionNames="[$pPCMachineExtensionNames]"}

                    # Edit GPT.INI and update Sysvol versionNumber

                    $GptContent = Get-Content $GptIni3
                    $GptContent = $GptContent -replace "Version=0", "Version=16"
                    Set-Content $GptIni3 $GptContent

                    # Update AD versionNumber

                    $VersionNumberT2 = (Get-ADObject "CN={$($003Id)},$PathPolicy" -Properties *)
                    Set-ADObject -Identity $VersionNumberT2 -Replace @{versionNumber="16"}
                }
        }
    }


### JumpServer
function Logon_JumpServer_T2 () 
    {
        $VersionNumber = (Get-ADObject "CN={$($004Id)},$PathPolicy" -Properties *)
        $VersionNumber.versionNumber | ForEach {

            if ( $VersionNumber.versionNumber -eq "16" )
                {
                    write-host ""
                    write-host "Restricted Logon Jump Server Tier 1 already Configured : " -ForegroundColor Green
                    write-host ""
                    Write-Host "Log on locally                              : " -ForegroundColor DarkGray -NoNewline; Write-Host $AdminsName, $groupT1.Group[1], $groupT1.Group[2], $groupT1.Group[3] -ForegroundColor DarkGray 
                    Write-Host "Log on through Remote Desktop Services      : " -ForegroundColor DarkGray -NoNewline; Write-Host $groupT1.Group[2] -ForegroundColor DarkGray
                    Write-Host "Log on as a batch job                       : " -ForegroundColor DarkGray -NoNewline; Write-Host $AdminsName, $groupT1.Group[1], $groupT1.Group[3] -ForegroundColor DarkGray
                    Write-Host "Log on as a service                         : " -ForegroundColor DarkGray -NoNewline; Write-Host $AdminsName, $groupT1.Group[1], $groupT1.Group[3] -ForegroundColor DarkGray
                }
            else 
                {
                    # Allows Section
                    $addURABatch = "SeBatchLogonRight = *$($AdminsSid),*$($JumpMainT1Sid),*$($SrvAccountT1Sid)"
                    $addURAService = "SeServiceLogonRight = *$($AdminsSid),*$($JumpMainT1Sid),*$($SrvAccountT1Sid)"
                    $addURARemote = "SeRemoteInteractiveLogonRight = *$($JumpUserT1Sid)"
                    $addURALocally = "SeInteractiveLogonRight = *$($AdminsSid),*$($JumpUserT1Sid),*$($JumpMainT1Sid),*$($SrvAccountT1Sid)"

                    # Deny section
                    $addURADenyBatch = "SeDenyBatchLogonRight = *$($AdminT0Sid),*$($SrvAccountT0Sid),*$($MainT0Sid),*$($PAWUserT0Sid),*$($PAWMainT0Sid),*$($RemoteDCT0Sid),*$($AdminT1Sid),*$($MainT1Sid),*$($AdminT2Sid),*$($UsersT2Sid),*$($HelpdeskT2Sid),*$($UserRemoteT2Sid),*$($DASid),*$($EASid),*$($SchemaSid),*$($AccountSid),*$($PrintSid),*$($ServerSid),*$($BackupSid)"
                    $addURADenyService = "SeDenyServiceLogonRight = *$($AdminT0Sid),*$($SrvAccountT0Sid),*$($MainT0Sid),*$($PAWUserT0Sid),*$($PAWMainT0Sid),*$($RemoteDCT0Sid),*$($AdminT1Sid),*$($MainT1Sid),*$($AdminT2Sid),*$($UsersT2Sid),*$($HelpdeskT2Sid),*$($UserRemoteT2Sid),*$($DASid),*$($EASid),*$($SchemaSid),*$($AccountSid),*$($PrintSid),*$($ServerSid),*$($BackupSid)"
                    $addURADenyRemote = "SeDenyRemoteInteractiveLogonRight = *$($AdminsSid),*$($AdminT0Sid),*$($SrvAccountT0Sid),*$($MainT0Sid),*$($PAWUserT0Sid),*$($PAWMainT0Sid),*$($RemoteDCT0Sid),*$($AdminT1Sid),*$($SrvAccountT1Sid),*$($MainT1Sid),*$($JumpMainT1Sid),*$($AdminT2Sid),*$($UsersT2Sid),*$($HelpdeskT2Sid),*$($UserRemoteT2Sid),*$($DASid),*$($EASid),*$($SchemaSid),*$($AccountSid),*$($PrintSid),*$($ServerSid),*$($BackupSid)"
                    $addURADenyLocally = "SeDenyInteractiveLogonRight = *$($AdminT0Sid),*$($SrvAccountT0Sid),*$($MainT0Sid),*$($PAWUserT0Sid),*$($PAWMainT0Sid),*$($RemoteDCT0Sid),*$($AdminT1Sid),*$($MainT1Sid),*$($AdminT2Sid),*$($UsersT2Sid),*$($HelpdeskT2Sid),*$($UserRemoteT2Sid),*$($DASid),*$($EASid),*$($SchemaSid),*$($AccountSid),*$($PrintSid),*$($ServerSid),*$($BackupSid)"

                    # Edit GptTmpl.inf
                    Add-Content -Path $gptFile4 -Value '[Privilege Rights]'
                    Add-Content -Path $gptFile4 -Value $addURABatch
                    Add-Content -Path $gptFile4 -Value $addURAService 
                    Add-Content -Path $gptFile4 -Value $addURARemote
                    Add-Content -Path $gptFile4 -Value $addURALocally
                    Add-Content -Path $gptFile4 -Value $addURADenyBatch
                    Add-Content -Path $gptFile4 -Value $addURADenyService
                    Add-Content -Path $gptFile4 -Value $addURADenyRemote
                    Add-Content -Path $gptFile4 -Value $addURADenyLocally

                    $getGPOT4 = (Get-ADObject "CN={$($004Id)},$PathPolicy").DistinguishedName
                    Set-ADObject -Identity $getGPOT4 -Replace @{gPCMachineExtensionNames="[$pPCMachineExtensionNames]"}

                    # Edit GPT.INI and update Sysvol versionNumber

                    $GptContent = Get-Content $GptIni4
                    $GptContent = $GptContent -replace "Version=0", "Version=16"
                    Set-Content $GptIni4 $GptContent

                    # Update AD versionNumber

                    $VersionNumberT2 = (Get-ADObject "CN={$($004Id)},$PathPolicy" -Properties *)
                    Set-ADObject -Identity $VersionNumberT2 -Replace @{versionNumber="16"}
                }
        }        
    }

function LocalAdmin_T0 ()
    {
        $VersionNumber = (Get-ADObject "CN={$($005Id)},$PathPolicy" -Properties *)
        $VersionNumber.versionNumber | ForEach {

            if ( $VersionNumber.versionNumber -eq "2" )
                {
                    write-host ""
                    Write-Host "Restricted group for Tier0                    : " -ForegroundColor DarkGray -NoNewline; Write-Host $groupT0.Group[4] -ForegroundColor DarkGray
                }
            else 
                {
                    $Memberof = "*$($MainT0Sid)__Memberof = *$AdminsSid"
                    $Members = "*$($MainT0Sid)__Members ="

                    Add-Content -Path $gptFile5 -Value '[Group Membership]'
                    Add-Content -Path $gptFile5 -Value $Memberof
                    Add-Content -Path $gptFile5 -Value $Members

                    $getGPOPath = (Get-ADObject "CN={$($005Id)},$PathPolicy").DistinguishedName  
                    Set-ADObject -Identity $getGPOPath -Replace @{gPCMachineExtensionNames="[$pPCMachineExtensionNames]"}

                    # Edit GPT.INI and update Sysvol versionNumber

                    $GptContent = Get-Content $GptIni5
                    $GptContent = $GptContent -replace "Version=0", "Version=2"
                    Set-Content $GptIni5 $GptContent

                    # Update AD versionNumber

                    $VersionNumberLadminT0 = (Get-ADObject "CN={$($005Id)},$PathPolicy" -Properties *)
                    Set-ADObject -Identity $VersionNumberLadminT0 -Replace @{versionNumber="2"}
                }
        }        
    }

function LocalAdmin_T1 () 
    {
        $VersionNumber = (Get-ADObject "CN={$($006Id)},$PathPolicy" -Properties *)
        $VersionNumber.versionNumber | ForEach {

            if ( $VersionNumber.versionNumber -eq "2" )
                {
              
                    Write-Host "Restricted group for Tier1                    : " -ForegroundColor DarkGray -NoNewline; Write-Host $groupT1.Group[4] -ForegroundColor DarkGray
                }
            else 
                {
                    $Memberof = "*$($MainT1Sid)__Memberof = *$AdminsSid"
                    $Members = "*$($MainT1Sid)__Members ="

                    Add-Content -Path $gptFile6 -Value '[Group Membership]'
                    Add-Content -Path $gptFile6 -Value $Memberof
                    Add-Content -Path $gptFile6 -Value $Members

                    $getGPOPath = (Get-ADObject "CN={$($006Id)},$PathPolicy").DistinguishedName  
                    Set-ADObject -Identity $getGPOPath -Replace @{gPCMachineExtensionNames="[$pPCMachineExtensionNames]"}

                    # Edit GPT.INI and update Sysvol versionNumber

                    $GptContent = Get-Content $GptIni6
                    $GptContent = $GptContent -replace "Version=0", "Version=2"
                    Set-Content $GptIni6 $GptContent

                    # Update AD versionNumber

                    $VersionNumberLadminT1 = (Get-ADObject "CN={$($006Id)},$PathPolicy" -Properties *)
                    Set-ADObject -Identity $VersionNumberLadminT1 -Replace @{versionNumber="2"}
                }
        }        
    }

function LocalAdmin_T2 () 
    {
        $VersionNumber = (Get-ADObject "CN={$($007Id)},$PathPolicy" -Properties *)
        $VersionNumber.versionNumber | ForEach {

            if ( $VersionNumber.versionNumber -eq "2" )
                {
              
                    Write-Host "Restricted group for Tier2                    : " -ForegroundColor DarkGray -NoNewline; Write-Host $groupT2.Group[0] -ForegroundColor DarkGray
                }
            else 
                {
                    $Memberof = "*$($AdminT2Sid)__Memberof = *$AdminsSid"
                    $Members = "*$($AdminT2Sid)__Members ="

                    Add-Content -Path $gptFile7 -Value '[Group Membership]'
                    Add-Content -Path $gptFile7 -Value $Memberof
                    Add-Content -Path $gptFile7 -Value $Members

                    $getGPOPath = (Get-ADObject "CN={$($007Id)},$PathPolicy").DistinguishedName  
                    Set-ADObject -Identity $getGPOPath -Replace @{gPCMachineExtensionNames="[$pPCMachineExtensionNames]"}

                    # Edit GPT.INI and update Sysvol versionNumber

                    $GptContent = Get-Content $GptIni7
                    $GptContent = $GptContent -replace "Version=0", "Version=2"
                    Set-Content $GptIni7 $GptContent

                    # Update AD versionNumber

                    $VersionNumberLadminT2 = (Get-ADObject "CN={$($007Id)},$PathPolicy" -Properties *)
                    Set-ADObject -Identity $VersionNumberLadminT2 -Replace @{versionNumber="2"}   
                }
        } 

    }

### PAW Local Admin
function LocalAdmin_PAW_T0 () 
    {
        $VersionNumber = (Get-ADObject "CN={$($008Id)},$PathPolicy" -Properties *)
        $VersionNumber.versionNumber | ForEach {

            if ( $VersionNumber.versionNumber -eq "2" )
                {
              
                    Write-Host "Restricted group for PAW Tier0                : " -ForegroundColor DarkGray -NoNewline; Write-Host $groupT0.Group[3] -ForegroundColor DarkGray
                }
            else 
               {
                    $Memberof = "*$($PAWMainT0Sid)__Memberof = *$AdminsSid"
                    $Members = "*$($PAWMainT0Sid)__Members ="

                    Add-Content -Path $gptFile8 -Value '[Group Membership]'
                    Add-Content -Path $gptFile8 -Value $Memberof
                    Add-Content -Path $gptFile8 -Value $Members

                    $getGPOPath = (Get-ADObject "CN={$($008Id)},$PathPolicy").DistinguishedName  
                    Set-ADObject -Identity $getGPOPath -Replace @{gPCMachineExtensionNames="[$pPCMachineExtensionNames]"}

                    # Edit GPT.INI and update Sysvol versionNumber

                    $GptContent = Get-Content $GptIni8
                    $GptContent = $GptContent -replace "Version=0", "Version=2"
                    Set-Content $GptIni8 $GptContent

                    # Update AD versionNumber

                    $VersionNumberLadminPAW = (Get-ADObject "CN={$($008Id)},$PathPolicy" -Properties *)
                    Set-ADObject -Identity $VersionNumberLadminPAW -Replace @{versionNumber="2"}   
               } 
        }

    }

function LocalAdmin_JumpSrv_T0 () 
    {
        $VersionNumber = (Get-ADObject "CN={$($009Id)},$PathPolicy" -Properties *)
        $VersionNumber.versionNumber | ForEach {

            if ( $VersionNumber.versionNumber -eq "2" )
                {
              
                    Write-Host "Restricted group for Jump Server Tier1        : " -ForegroundColor DarkGray -NoNewline; Write-Host $groupT1.Group[3] -ForegroundColor DarkGray
                }
            else 
                {
                    $Memberof = "*$($JumpMainT1Sid)__Memberof = *$AdminsSid"
                    $Members = "*$($JumpMainT1Sid)__Members ="

                    Add-Content -Path $gptFile9 -Value '[Group Membership]'
                    Add-Content -Path $gptFile9 -Value $Memberof
                    Add-Content -Path $gptFile9 -Value $Members

                    $getGPOPath = (Get-ADObject "CN={$($009Id)},$PathPolicy").DistinguishedName  
                    Set-ADObject -Identity $getGPOPath -Replace @{gPCMachineExtensionNames="[$pPCMachineExtensionNames]"}

                    # Edit GPT.INI and update Sysvol versionNumber

                    $GptContent = Get-Content $GptIni9
                    $GptContent = $GptContent -replace "Version=0", "Version=2"
                    Set-Content $GptIni9 $GptContent

                    # Update AD versionNumber

                    $VersionNumberLadminJumpSrv = (Get-ADObject "CN={$($009Id)},$PathPolicy" -Properties *)
                    Set-ADObject -Identity $VersionNumberLadminJumpSrv -Replace @{versionNumber="2"} 
                }   
        }
    }

function Logon_RemoteDesktopUsers_T1 () 
     {
        $VersionNumber = (Get-ADObject "CN={$($010Id)},$PathPolicy" -Properties *)
        $VersionNumber.versionNumber | ForEach {

            if ( $VersionNumber.versionNumber -eq "2" )
                {
              
                    Write-Host "Log on through Remote Desktop for Users Tier2 : " -ForegroundColor DarkGray -NoNewline; Write-Host $groupT2.Group[2] -ForegroundColor DarkGray
                    write-host ""
                }
            else 
                {
                    # Allows Section
                    $addURARemote = "SeRemoteInteractiveLogonRight = *$($UserRemoteT2Sid)"
      
                    # Edit GptTmpl.inf
                    Add-Content -Path $gptFile10 -Value '[Privilege Rights]'
                    Add-Content -Path $gptFile10 -Value $addURARemote

                    $getGPOT10 = (Get-ADObject "CN={$($010Id)},$PathPolicy").DistinguishedName
                    Set-ADObject -Identity $getGPOT10 -Replace @{gPCMachineExtensionNames="[$pPCMachineExtensionNames]"}

                    # Edit GPT.INI and update Sysvol versionNumber

                    $GptContent = Get-Content $GptIni10
                    $GptContent = $GptContent -replace "Version=0", "Version=2"
                    Set-Content $GptIni10 $GptContent

                    # Update AD versionNumber

                    $VersionNumberT2 = (Get-ADObject "CN={$($010Id)},$PathPolicy" -Properties *)
                    Set-ADObject -Identity $VersionNumberT2 -Replace @{versionNumber="2"}
                }
        }
    }

# Run functions

Write-Host "[Task 2] : Configuring Restricted Logon for T0, T1 and T2...                                   " -ForegroundColor Green -NoNewline; Write-Host [Ok] -ForegroundColor Green
Logon_T0
Logon_T1
Logon_T2
Logon_PAW_T0
Logon_JumpServer_T2
Logon_RemoteDesktopUsers_T1

Write-Host "[Task 3] : Configuring Restricted Groups for T0, T1 and T2...                                  " -ForegroundColor Green -NoNewline; Write-Host [Ok] -ForegroundColor Green
LocalAdmin_T0
LocalAdmin_T1
LocalAdmin_T2
LocalAdmin_PAW_T0
LocalAdmin_JumpSrv_T0

# Apply the GPOs
Write-Host "[Task 4] : Successful.                                                                         " -ForegroundColor Green -NoNewline; Write-Host [OK] -ForegroundColor Green
Shutdown -r
Write-Host ""
Get-Content .\info.md
Write-Host"" 
