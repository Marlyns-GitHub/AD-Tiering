Write-Host ""
Write-Host "[Task 0] : Gethering Domain Informations, Creating Objects...    " -ForegroundColor Green -NoNewline; Write-Host "[Ok]" -ForegroundColor Green
$NetBIOSName = (Get-ADDomain).NetBIOSName
$DomainName = (Get-ADRootDSE).defaultNamingContext
$ParentOu = "OU=$NetBIOSName,$DomainName"
#$ParentOu = (Get-ADOrganizationalUnit -Filter "Name -like '$NetBIOSName'").DistinguishedName


$OUs = @(

       $(New-Object PSObject -Property @{Name = "Tier0"; ParentOu = "$ParentOu" }),
       $(New-Object PSObject -Property @{Name = "Tier1"; ParentOu = "$ParentOu" }),
       $(New-Object PSObject -Property @{Name = "Tier2"; ParentOu = "$ParentOu" })
)

$GroupT0 = @(
                $(New-Object PSObject -Property @{Group = "Domain Tier0 Admins"; OUprefix = "OU=Groups,OU=Tier0" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier0 Servers"; OUprefix = "OU=Groups,OU=Tier0" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier0 Service Accounts"; OUprefix = "OU=Groups,OU=Tier0" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier0 PAW Users"; OUprefix = "OU=Groups,OU=Tier0" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier0 PAW Maintenance"; OUprefix = "OU=Groups,OU=Tier0" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier0 PAW Computers"; OUprefix = "OU=Groups,OU=Tier0" }),                
                $(New-Object PSObject -Property @{Group = "Domain Tier0 Maintenance"; OUprefix = "OU=Groups,OU=Tier0" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier0 Remote Domain Controllers"; OUprefix = "OU=Groups,OU=Tier0" })
            )

$GroupT1 = @(
                $(New-Object PSObject -Property @{Group = "Domain Tier1 Admins"; OUprefix = "OU=Groups,OU=Tier1" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier1 Servers"; OUprefix = "OU=Groups,OU=Tier1" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier1 Service Accounts"; OUprefix = "OU=Groups,OU=Tier1" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier1 JumpServer Users"; OUprefix = "OU=Groups,OU=Tier1" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier1 Jumpserver Maintenance"; OUprefix = "OU=Groups,OU=Tier1" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier1 JumpServer Computers"; OUprefix = "OU=Groups,OU=Tier1" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier1 Maintenance"; OUprefix = "OU=Groups,OU=Tier1" })

            )

$GroupT2 = @(
                $(New-Object PSObject -Property @{Group = "Domain Tier2 Admins"; OUprefix = "OU=Groups,OU=Tier2" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier2 HelpDesk Operators"; OUprefix = "OU=Groups,OU=Tier2" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier2 Remote Desktop Users"; OUprefix = "OU=Groups,OU=Tier2" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier2 Users"; OUprefix = "OU=Groups,OU=Tier2" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier2 Laptops"; OUprefix = "OU=Groups,OU=Tier2" }),
                $(New-Object PSObject -Property @{Group = "Domain Tier2 WorkStations"; OUprefix = "OU=Groups,OU=Tier2" })
            )

# First condition
if (
        ($check1 = (Get-ADObject -Filter 'ObjectClass -eq "OrganizationalUnit"' | Where-Object Name -eq $NetBIOSName).DistinguishedName) -and
        ($check2 = (Get-ADObject -Filter 'ObjectClass -eq "OrganizationalUnit"' | Where-Object Name -eq $OUs.Name[0]).DistinguishedName) -and
        ($check3 = (Get-ADObject -Filter 'ObjectClass -eq "OrganizationalUnit"' | Where-Object Name -eq $OUs.Name[1]).DistinguishedName) -and
        ($check4 = (Get-ADObject -Filter 'ObjectClass -eq "OrganizationalUnit"' | Where-Object Name -eq $OUs.Name[2]).DistinguishedName)
   )
   {
        if  ( 
                ($check0 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT0.Group[0]).DistinguishedName) -and
                ($check1 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT0.Group[1]).DistinguishedName) -and
                ($check2 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT0.Group[2]).DistinguishedName) -and
				($check3 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT0.Group[3]).DistinguishedName) -and
                ($check4 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT0.Group[4]).DistinguishedName) -and
                ($check5 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT0.Group[5]).DistinguishedName) -and
                ($check6 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT0.Group[6]).DistinguishedName) -and
                ($check7 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT0.Group[7]).DistinguishedName) -and
                ($check8 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT1.Group[0]).DistinguishedName) -and
                ($check9 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT1.Group[1]).DistinguishedName) -and
                ($check10 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT1.Group[2]).DistinguishedName) -and
                ($check11 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT1.Group[3]).DistinguishedName) -and
                ($check12 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT1.Group[4]).DistinguishedName) -and
                ($check13 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT1.Group[5]).DistinguishedName) -and
                ($check14 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT1.Group[6]).DistinguishedName) -and
                ($check15 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT2.Group[0]).DistinguishedName) -and
                ($check16 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT2.Group[1]).DistinguishedName) -and
                ($check17 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT2.Group[2]).DistinguishedName) -and
                ($check18 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT2.Group[3]).DistinguishedName) -and
                ($check19 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT2.Group[4]).DistinguishedName) -and
                ($check20 = (Get-ADObject -Filter "ObjectClass -eq 'group'" | Where-Object Name -eq $groupT2.Group[5]).DistinguishedName)
		    )
            {
                Write-Host "[Task 1] : Checking if Tiering Security Groups already exists... " -ForegroundColor Green -NoNewline; Write-Host "[Ok]" -ForegroundColor Green
                Write-Host ""
                Write-Host $check0 -ForegroundColor DarkGray
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
                Write-Host ""
                Get-Content .\info.md
                Write-Host ""

            }
		else 
		    {
                foreach ($tier in $OUs.Name){
        
                    $path = (Get-ADOrganizationalUnit -Filter "Name -eq '$tier'").DistinguishedName

                    if ($path -match $OUs.Name[0])
					    {
            
                            Write-Host "[Task 1] : Creating Security Tier0 groups...                     " -ForegroundColor Green -NoNewline; Write-Host [Ok] -ForegroundColor Green
                            $PathT0gp = (Get-ADOrganizationalUnit  -SearchBase $path -Filter "Name -eq 'Groups'").Distinguishedname
            
                            foreach ($group in $GroupT0.Group)
                                {

                                    if ($group -match $GroupT0.group[0])
                                        {
                                            New-ADGroup -Name $group -Description "Designated admins of the Tier0" -GroupCategory Security -GroupScope Global -Path $PathT0gp
                                        }

                                    if ($group -match $GroupT0.group[1])
                                        {
                                            New-ADGroup -Name $group -Description "Designated service accounts of the Tier0" -GroupCategory Security -GroupScope Global -Path $PathT0gp
                                        }

                                    if ($group -match $GroupT0.group[2])
                                        {
                                            New-ADGroup -Name $group -Description "Designated PAW Users of the Tier0" -GroupCategory Security -GroupScope Global -Path $PathT0gp
                                        }

                                    if ($group -match $GroupT0.group[3])
                                        {
                                            New-ADGroup -Name $group -Description "Designated PAW Computers of the Tier0" -GroupCategory Security -GroupScope Global -Path $PathT0gp
                                        }
               
                                    if ($group -match $GroupT0.group[4])
                                        {
                                            New-ADGroup -Name $group -Description "Designated PAW Maintenance of the Tier0" -GroupCategory Security -GroupScope Global -Path $PathT0gp
                                        }

                                    if ($group -match $GroupT0.group[5])
                                        {
                                            New-ADGroup -Name $group -Description "Designated Servers of the Tier0" -GroupCategory Security -GroupScope Global -Path $PathT0gp
                                        }

                                    if ($group -match $GroupT0.group[6])
                                        {
                                            New-ADGroup -Name $group -Description "Designated Maintenance of the Tier0" -GroupCategory Security -GroupScope Global -Path $PathT0gp
                                        }

                                    if ($group -match $GroupT0.group[7])
                                        {
                                            New-ADGroup -Name $group -Description "Designated Remote Domain Controllers of the Tier0" -GroupCategory Security -GroupScope Global -Path $PathT0gp
                                        }
						       }  
                        }

                    if ($path -match $OUs.Name[1])
					    {
            
                            Write-Host "[Task 2] : Creating security Tier1 groups...                     " -ForegroundColor Green -NoNewline; Write-Host [Ok] -ForegroundColor Green
                            $PathT1gp = (Get-ADOrganizationalUnit  -SearchBase $path -Filter "Name -eq 'Groups'").Distinguishedname
            
                            foreach ($group in $GroupT1.Group)
                                {

                                    if ($group -match $GroupT1.group[0])
                                        {
                                            New-ADGroup -Name $group -Description "Designated admins of the Tier1" -GroupCategory Security -GroupScope Global -Path $PathT1gp
                                        }

                                    if ($group -match $GroupT1.group[1])
                                        {
                                            New-ADGroup -Name $group -Description "Designated service accounts of the Tier1" -GroupCategory Security -GroupScope Global -Path $PathT1gp
                                        }

                                    if ($group -match $GroupT1.group[2])
                                        {
                                            New-ADGroup -Name $group -Description "Designated JumpServer Users of the Tier1" -GroupCategory Security -GroupScope Global -Path $PathT1gp
                                        }

                                    if ($group -match $GroupT1.group[3])
                                        {
                                            New-ADGroup -Name $group -Description "Designated JumpServer Computers of the Tier1" -GroupCategory Security -GroupScope Global -Path $PathT1gp
                                        }
               
                                    if ($group -match $GroupT1.group[4])
                                        {
                                            New-ADGroup -Name $group -Description "Designated JumpServer Maintenance of the Tier1" -GroupCategory Security -GroupScope Global -Path $PathT1gp
                                        }

                                    if ($group -match $GroupT1.group[5])
                                        {
                                            New-ADGroup -Name $group -Description "Designated Servers of the Tier1" -GroupCategory Security -GroupScope Global -Path $PathT1gp
                                        }

                                    if ($group -match $GroupT1.group[6])
                                        {
                                            New-ADGroup -Name $group -Description "Designated Maintenance of the Tier1" -GroupCategory Security -GroupScope Global -Path $PathT1gp
                                        }
								}
                        }

                    if ($path -match $OUs.Name[2])
						{
            
                            Write-Host "[Task 3] : Creating security Tier2 groups...                     " -ForegroundColor Green -NoNewline; Write-Host [Ok] -ForegroundColor Green
                            $PathT2gp = (Get-ADOrganizationalUnit  -SearchBase $path -Filter "Name -eq 'Groups'").Distinguishedname
            
                            foreach ($group in $GroupT2.Group)
                                {

                                    if ($group -match $GroupT2.group[0])
                                        {
                                            New-ADGroup -Name $group -Description "Designated admins of the Tier2" -GroupCategory Security -GroupScope Global -Path $PathT2gp
                                        }

                                    if ($group -match $GroupT2.group[1])
                                        {
                                            New-ADGroup -Name $group -Description "Designated service accounts of the Tier2" -GroupCategory Security -GroupScope Global -Path $PathT2gp
                                    }

                                    if ($group -match $GroupT2.group[2])
                                        {
                                            New-ADGroup -Name $group -Description "Designated Users Authenticated of the Tier2" -GroupCategory Security -GroupScope Global -Path $PathT2gp
                                        }

                                    if ($group -match $GroupT2.group[3])
                                        {
                                            New-ADGroup -Name $group -Description "Designated Laptop Computers of the Tier2" -GroupCategory Security -GroupScope Global -Path $PathT2gp
                                        }
               
                                    if ($group -match $GroupT2.group[4])
                                        {
                                            New-ADGroup -Name $group -Description "Designated Workstation Compteurs of the Tier2" -GroupCategory Security -GroupScope Global -Path $PathT2gp
                                        }

                                    if ($group -match $GroupT2.group[5])
                                        {
                                            New-ADGroup -Name $group -Description "Designated Remote Desktop Users of the Tier2" -GroupCategory Security -GroupScope Global -Path $PathT2gp
                                        }
                                }
                        }

                }

                Write-Host "[Task 4] : Successful...                                         " -ForegroundColor Green -NoNewline; Write-Host "[Ok]" -ForegroundColor Green
                Write-Host ""
                Get-Content .\info.md
                Write-Host "" 
			}
    }   
else 
   {

        write-warning "This script depends on the script 1) Create Tiering OUs."
        Write-Host ""
        Get-Content .\info.md
        Write-Host ""  
	    exit
   }
