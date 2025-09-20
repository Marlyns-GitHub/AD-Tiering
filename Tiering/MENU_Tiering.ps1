# CIS Benchmark Compliance Automate
@'
  Purpose is to Automate Active Directory Tiered Model
  Written by Marlyns Nkunga, Sept 2025

'@
Clear-Host

function Print_Menu
{
   Write-Host ""
   Get-Content .\banner.md
   Write-Host ""

   Write-Host "1) Create Tiering OUs"
   Write-Host "2) Create Tiering Security Groups"
   Write-Host "3) Create Tiering GPOs"
   Write-Host "4) Configure Tiering Domain Controllers User Right Assigment"
   Write-Host "5) Configure Tiering Restricted Logon"
   Write-Host "0) Exit"
}

do {

      Print_Menu

      Write-Host ""
      Write-Host "Make choise : " -NoNewline

      switch ($choise = Read-Host)
      {  
	
       "1" { 
           
               .\00_OU_Tiering.ps1
        }
        
        "2"{

               .\01_Groups_Tiering.ps1
        }

        "3"{

               .\02_GPO_Tiering.ps1
        }

        "4"{

               .\03_UserRightAssignment_DC_Tiering.ps1
        }

        "5"{

               .\04_RestrictedLogon_Tiering.ps1
        }

        "0"{
               Exit
        }

       default {

            Write-Warning " This choise is not valid"
       }
    }
      pause
      Clear-Host
}while($true)