Write-Host ""
Write-Host "[Task 0] : Gethering Domain Informations, creating Objects...      " -ForegroundColor Green -NoNewline; Write-Host "[Ok]" -ForegroundColor Green
$NetBIOSName = (Get-ADDomain).NetBIOSName
$DomainName = (Get-ADRootDSE).defaultNamingContext
$ParentOu = "OU=$NetBIOSName,$DomainName"

$OUs = @(

       $(New-Object PSObject -Property @{Name = "Tier0"; ParentOu = "$ParentOu" }),
       $(New-Object PSObject -Property @{Name = "Tier1"; ParentOu = "$ParentOu" }),
       $(New-Object PSObject -Property @{Name = "Tier2"; ParentOu = "$ParentOu" })
)

$OU_T0 = @(

       $(New-Object PSObject -Property @{Name = "Admins"; ParentOu = "OU=Tier0,$ParentOu" }),
       $(New-Object PSObject -Property @{Name = "Groups"; ParentOu = "OU=Tier0,$ParentOu" }),
       $(New-Object PSObject -Property @{Name = "Servers"; ParentOu = "OU=Tier0,$ParentOu" }),
       $(New-Object PSObject -Property @{Name = "Service Accounts"; ParentOu = "OU=Tier0,$ParentOu" }),
       $(New-Object PSObject -Property @{Name = "PAW"; ParentOu = "OU=Tier0,$ParentOu" }),
       $(New-Object PSObject -Property @{Name = "PAW Users"; ParentOu = "OU=Tier0,$ParentOu" })
)

$OU_T1 = @(

       $(New-Object PSObject -Property @{Name = "Admins"; ParentOu = "OU=Tier1,$ParentOu" }),
       $(New-Object PSObject -Property @{Name = "Groups"; ParentOu = "OU=Tier1,$ParentOu" }),
       $(New-Object PSObject -Property @{Name = "Servers"; ParentOu = "OU=Tier1,$ParentOu" }),
       $(New-Object PSObject -Property @{Name = "Service Accounts"; ParentOu = "OU=Tier1,$ParentOu" }),
       $(New-Object PSObject -Property @{Name = "Jump Servers"; ParentOu = "OU=Tier1,$ParentOu" }),
       $(New-Object PSObject -Property @{Name = "JumpServer Users"; ParentOu = "OU=Tier1,$ParentOu" })
)

$OU_T2 = @(

       $(New-Object PSObject -Property @{Name = "Admins"; ParentOu = "OU=Tier2,$ParentOu" }),
       $(New-Object PSObject -Property @{Name = "Groups"; ParentOu = "OU=Tier2,$ParentOu" }),
       $(New-Object PSObject -Property @{Name = "Laptops"; ParentOu = "OU=Tier2,$ParentOu" }),
       $(New-Object PSObject -Property @{Name = "WorkStations"; ParentOu = "OU=Tier2,$ParentOu" }),
       $(New-Object PSObject -Property @{Name = "Users"; ParentOu = "OU=Tier2,$ParentOu" })
)

if (
       ($check1 = (Get-ADObject -Filter 'ObjectClass -eq "OrganizationalUnit"' | Where-Object Name -eq $NetBIOSName).DistinguishedName) -and
       ($check2 = (Get-ADObject -Filter 'ObjectClass -eq "OrganizationalUnit"' | Where-Object Name -eq $OUs.Name[0]).DistinguishedName) -and
       ($check3 = (Get-ADObject -Filter 'ObjectClass -eq "OrganizationalUnit"' | Where-Object Name -eq $OUs.Name[1]).DistinguishedName) -and
       ($check4 = (Get-ADObject -Filter 'ObjectClass -eq "OrganizationalUnit"' | Where-Object Name -eq $OUs.Name[2]).DistinguishedName) -and
       ($check5 = (Get-ADObject -Filter 'ObjectClass -eq "OrganizationalUnit"' -SearchBase "OU=Tier0,$ParentOu" | Where-Object Name -eq $OU_T0.Name[0]).DistinguishedName) -and
       ($check6 = (Get-ADObject -Filter 'ObjectClass -eq "OrganizationalUnit"' -SearchBase "OU=Tier0,$ParentOu" | Where-Object Name -eq $OU_T0.Name[1]).DistinguishedName) -and
       ($check7 = (Get-ADObject -Filter 'ObjectClass -eq "OrganizationalUnit"' -SearchBase "OU=Tier0,$ParentOu" | Where-Object Name -eq $OU_T0.Name[2]).DistinguishedName) -and
       ($check8 = (Get-ADObject -Filter 'ObjectClass -eq "OrganizationalUnit"' -SearchBase "OU=Tier0,$ParentOu" | Where-Object Name -eq $OU_T0.Name[3]).DistinguishedName) -and
       ($check9 = (Get-ADObject -Filter 'ObjectClass -eq "OrganizationalUnit"' | Where-Object Name -eq $OU_T0.Name[4]).DistinguishedName) -and
       ($check10 = (Get-ADObject -Filter 'ObjectClass -eq "OrganizationalUnit"' | Where-Object Name -eq $OU_T0.Name[5]).DistinguishedName) -and
       ($check11 = (Get-ADObject -Filter 'ObjectClass -eq "OrganizationalUnit"' -SearchBase "OU=Tier1,$ParentOu" | Where-Object Name -eq $OU_T1.Name[0]).DistinguishedName) -and
       ($check12 = (Get-ADObject -Filter 'ObjectClass -eq "OrganizationalUnit"' -SearchBase "OU=Tier1,$ParentOu" | Where-Object Name -eq $OU_T1.Name[1]).DistinguishedName) -and
       ($check13 = (Get-ADObject -Filter 'ObjectClass -eq "OrganizationalUnit"' -SearchBase "OU=Tier1,$ParentOu" | Where-Object Name -eq $OU_T1.Name[2]).DistinguishedName) -and
       ($check14 = (Get-ADObject -Filter 'ObjectClass -eq "OrganizationalUnit"' -SearchBase "OU=Tier1,$ParentOu" | Where-Object Name -eq $OU_T1.Name[3]).DistinguishedName) -and
       ($check15 = (Get-ADObject -Filter 'ObjectClass -eq "OrganizationalUnit"' | Where-Object Name -eq $OU_T1.Name[4]).DistinguishedName) -and
       ($check16 = (Get-ADObject -Filter 'ObjectClass -eq "OrganizationalUnit"' | Where-Object Name -eq $OU_T1.Name[5]).DistinguishedName) -and
       ($check17 = (Get-ADObject -Filter 'ObjectClass -eq "OrganizationalUnit"' -SearchBase "OU=Tier2,$ParentOu" | Where-Object Name -eq $OU_T2.Name[0]).DistinguishedName) -and
       ($check18 = (Get-ADObject -Filter 'ObjectClass -eq "OrganizationalUnit"' -SearchBase "OU=Tier2,$ParentOu" | Where-Object Name -eq $OU_T2.Name[1]).DistinguishedName) -and
       ($check19 = (Get-ADObject -Filter 'ObjectClass -eq "OrganizationalUnit"' | Where-Object Name -eq $OU_T2.Name[2]).DistinguishedName) -and
       ($check20 = (Get-ADObject -Filter 'ObjectClass -eq "OrganizationalUnit"' | Where-Object Name -eq $OU_T2.Name[3]).DistinguishedName) -and
       ($check21 = (Get-ADObject -Filter 'ObjectClass -eq "OrganizationalUnit"' | Where-Object Name -eq $OU_T2.Name[4]).DistinguishedName)
   )
    {
       Write-Host "[Task 1] : Tiering Organizational Units already exist...           " -ForegroundColor Green -NoNewline; Write-Host "[Ok]" -ForegroundColor Green
       Write-Host ""
       Write-Host $check1 -ForegroundColor DarkGray
       Write-Host $check2 -ForegroundColor DarkGray
       Write-Host $check3 -ForegroundColor DarkGray
       Write-Host $check4 -ForegroundColor DarkGray
       Write-Host $check5 -ForegroundColor DarkGray
       Write-Host $check6 -ForegroundColor DarkGray
       Write-Host $check7 -ForegroundColor DarkGray
       Write-Host $check8 -ForegroundColor DarkGray
       Write-Host $check9 -ForegroundColor DarkGray
       Write-Host $check10 -ForegroundColor DarkGray
       Write-Host $check11 -ForegroundColor DarkGray
       Write-Host $check12 -ForegroundColor DarkGray
       Write-Host $check13 -ForegroundColor DarkGray
       Write-Host $check14 -ForegroundColor DarkGray
       Write-Host $check15 -ForegroundColor DarkGray
       Write-Host $check16 -ForegroundColor DarkGray
       Write-Host $check17 -ForegroundColor DarkGray
       Write-Host $check18 -ForegroundColor DarkGray
       Write-Host $check19 -ForegroundColor DarkGray
       Write-Host $check20 -ForegroundColor DarkGray
       Write-Host $check21 -ForegroundColor DarkGray
       Write-Host ""
       Get-Content .\info.md
       Write-Host ""
    } 

else

    {
       Write-Host "[Task 1] : Creating Parent Organizational Unit...                  " -ForegroundColor Green -NoNewline; Write-Host "[Ok]" -ForegroundColor Green
       New-ADOrganizationalUnit -Name $NetBIOSName -Path $DomainName

       Write-Host "[Task 2] : Creating Tier0, Tier1 and Tier2 Organizational Units... " -ForegroundColor Green -NoNewline; Write-Host "[Ok]" -ForegroundColor Green
       $OUs | New-ADOrganizationalUnit -Path $ParentOu
        
       Write-Host "[Task 3] : Creating Tier0 subOrganizational Unit...                " -ForegroundColor Green -NoNewline; Write-Host "[Ok]" -ForegroundColor Green
       $OU_T0 | New-ADOrganizationalUnit -Path "OU=Tier0,$ParentOu"

       Write-Host "[Task 4] : Creating Tier1 subOrganizational Unit...                " -ForegroundColor Green -NoNewline; Write-Host "[Ok]" -ForegroundColor Green
       $OU_T1 | New-ADOrganizationalUnit -Path "OU=Tier1,$ParentOu"

       Write-Host "[Task 5] : Creating Tier2 subOrganizational Unit...                " -ForegroundColor Green -NoNewline; Write-Host "[Ok]" -ForegroundColor Green
       $OU_T2 | New-ADOrganizationalUnit -Path "OU=Tier2,$ParentOu"

       Write-Host "[Task 6] : Successful...                                           " -ForegroundColor Green -NoNewline ; Write-Host "[Ok]" -ForegroundColor Green
       Write-Host ""
       Get-Content .\info.md
       Write-Host ""

    }
