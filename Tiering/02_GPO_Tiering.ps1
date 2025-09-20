Write-Host ""
Write-Host "[Task 0] : Gathering Domain Informations, Checking Tiering OUs and GPOs... " -ForegroundColor Green -NoNewline; Write-Host "[OK]" -ForegroundColor Green 

#$RootOU = (Get-ADDomain).NetBIOSName
$DomainName = (Get-ADRootDSE).defaultNamingContext
$NetBIOSName = (Get-ADDomain).NetBIOSName
$ParentOu = "OU=$NetBIOSName,$DomainName"
$Checks = "C:\GPOList.txt"
$CheckGPO = (Get-GPO -all | Select-Object -ExpandProperty DisplayName) | Out-File $Checks

$OU = @(

       $(New-Object PSObject -Property @{Name = "Tier0"; ParentOu = "$ParentOu" }),
       $(New-Object PSObject -Property @{Name = "Tier1"; ParentOu = "$ParentOu" }),
       $(New-Object PSObject -Property @{Name = "Tier2"; ParentOu = "$ParentOu" })
)

$OUs = @(

       $(New-Object PSObject -Property @{Name = "Servers" }),
       $(New-Object PSObject -Property @{Name = "PAW" }),
       $(New-Object PSObject -Property @{Name = "Servers" }),
       $(New-Object PSObject -Property @{Name = "Jump Servers" }),
       $(New-Object PSObject -Property @{Name = "Laptops" }),
       $(New-Object PSObject -Property @{Name = "WorkStations" })

)

$GPOTiering = @(
 
 "000_T0_RestrictedLogon",
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

)

# First condition
if (
       ($check1 = (Get-ADObject -Filter 'ObjectClass -eq "OrganizationalUnit"' | Where-Object Name -eq $NetBIOSName).DistinguishedName) -and
       ($check2 = (Get-ADObject -Filter 'ObjectClass -eq "OrganizationalUnit"' | Where-Object Name -eq $OU.Name[0]).DistinguishedName) -and
       ($check3 = (Get-ADObject -Filter 'ObjectClass -eq "OrganizationalUnit"' | Where-Object Name -eq $OU.Name[1]).DistinguishedName) -and
       ($check4 = (Get-ADObject -Filter 'ObjectClass -eq "OrganizationalUnit"' | Where-Object Name -eq $OU.Name[2]).DistinguishedName)
   )
   {
        if ((Get-Content $Checks | Select-String -Pattern "000_T0") -and
            (Get-Content $Checks | Select-String -Pattern "000_T2") -and
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
               Write-Host "[Task 1] : Checking if Tiering GPOs already exists...                      " -ForegroundColor Green -NoNewline; Write-Host "[Ok]" -ForegroundColor Green
               Write-Host ""
               Write-Host $GPOTiering[0] -ForegroundColor DarkGray
               Write-Host $GPOTiering[1] -ForegroundColor DarkGray
               Write-Host $GPOTiering[2] -ForegroundColor DarkGray
               Write-Host $GPOTiering[3] -ForegroundColor DarkGray
               Write-Host $GPOTiering[4] -ForegroundColor DarkGray
               Write-Host $GPOTiering[5] -ForegroundColor DarkGray
               Write-Host $GPOTiering[6] -ForegroundColor DarkGray
               Write-Host $GPOTiering[7] -ForegroundColor DarkGray
               Write-Host $GPOTiering[8] -ForegroundColor DarkGray
               Write-Host $GPOTiering[9] -ForegroundColor DarkGray
               Write-Host $GPOTiering[10] -ForegroundColor DarkGray
               Write-Host ""
               Get-Content .\info.md
               Write-Host ""
           }   
		else 
		    {
                Write-Host "[Task 1] : Creating Tiering GPOs and Linking it to the OUs Tiering...      " -ForegroundColor Green -NoNewline; Write-Host "[OK]" -ForegroundColor Green
                foreach ($gpo in $GPOTiering)
                    {
                         $CreateGPO = New-GPO -Name $gpo
                    }
     
                $Tiers = (Get-ADOrganizationalUnit -Filter 'Name -like "*Tier*"' -Properties * | Select-Object Name, DistinguishedName)
                $T0Distinguished = ($Tiers | Where-Object Name -eq $OU.Name[0]).DistinguishedName
                $T1Distinguished = ($Tiers | Where-Object Name -eq $OU.Name[1]).DistinguishedName
                $T2Distinguished = ($Tiers | Where-Object Name -eq $OU.Name[2]).DistinguishedName
     
                $T0OUSrv = (Get-ADOrganizationalUnit -Filter * -SearchBase $T0Distinguished -Properties * | Where-Object Name -eq $OUs.Name[0] | Select-Object Name, DistinguishedName).DistinguishedName
                $T0OUPAW = (Get-ADOrganizationalUnit -Filter * -SearchBase $T0Distinguished -Properties * | Where-Object Name -eq $OUs.Name[1] | Select-Object Name, DistinguishedName).DistinguishedName
                $T1OUSrv = (Get-ADOrganizationalUnit -Filter * -SearchBase $T1Distinguished -Properties * | Where-Object Name -eq $OUs.Name[2] | Select-Object Name, DistinguishedName).DistinguishedName
                $T1OUJump = (Get-ADOrganizationalUnit -Filter * -SearchBase $T1Distinguished -Properties * | Where-Object Name -eq $OUs.Name[3] | Select-Object Name, DistinguishedName).DistinguishedName
                $T2OULaptop = (Get-ADOrganizationalUnit -Filter * -SearchBase $T2Distinguished -Properties * | Where-Object Name -eq $OUs.Name[4] | Select-Object Name, DistinguishedName).DistinguishedName
                $T2OUWorkstation = (Get-ADOrganizationalUnit -Filter * -SearchBase $T2Distinguished -Properties * | Where-Object Name -eq $OUs.Name[5] | Select-Object Name, DistinguishedName).DistinguishedName

                # Linked GPO on the OUs

                $linkT0Srv = New-GPLink -Name $GPOTiering[0] -Target $T0OUSrv; $linkT0PAW = New-GPLink -Name $GPOTiering[3] -Target $T0OUPAW 
                $linkT1Srv = New-GPLink -Name $GPOTiering[1] -Target $T1OUSrv; $linkT1Jump = New-GPLink -Name $GPOTiering[4] -Target $T1OUJump; $linkT1RDU = New-GPLink -Name $GPOTiering[10] -Target $T1OUSrv
                $linkT2OU = New-GPLink -Name $GPOTiering[2] -Target $T2Distinguished

                $LAdminT0 = New-GPLink -Name $GPOTiering[5] -Target $T0OUSrv; $LAdminT0PAW = New-GPLink -Name $GPOTiering[8] -Target $T0OUPAW
                $LAdminT1 = New-GPLink -Name $GPOTiering[6] -Target $T1OUSrv; $LAdminT1Jump = New-GPLink -Name $GPOTiering[9] -Target $T1OUJump
                $LAdminT2 = New-GPLink -Name $GPOTiering[7] -Target $T2Distinguished

                Write-Host "[Task 2] : Successful...                                                   " -ForegroundColor Green -NoNewline ; Write-Host "[Ok]" -ForegroundColor Green
                Write-Host ""
                Get-Content .\info.md
                Write-Host ""
			
			}
   }
else 
   {
        Write-Warning "This script depends on the script 1) Create Tiering OUs."
        Write-Host ""
        Get-Content .\info.md
        Write-Host ""  
		exit
   }