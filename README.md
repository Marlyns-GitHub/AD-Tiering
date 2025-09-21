# AD-Tiering : Automating Active Directory Tiering
Overview

The purpose of this script is to simplify the implementation of the Tiering model. The tiering model is an approach to segment the authentication secret in Active Directory environments. The principle is to create a separation between administrators based on the resources they manage. This helps to protect authentication secrets and avoid a compromise from the low level of trust to spread to the high level of trust.

Tiering model standard consists of three tiers, tiers 0, 1, and 2. they are classified according to the level of trust.

Tier 0 : it has a high level of trust, it includes critical servers like (AD, Microsoft Entra Connect, ADFS, KPI and others Tier 0 dependencies).                 
Tier 1 : it has a medium level of trust, it includes business applications servers like (BDD, SAP, Web, Fileservers and others Tier 1 dependencies ).             
Tier 2 : it has a low level of trust, it includes End Users devices like (Workstations, Laptops, Printers, etc).                                                  

Tier 0 Admins : can only log on the Tier 0 resources and cannot log to the other tiers.                                                                           
Tier 1 Admins : can only log on the Tier 1 resources and cannot log to the other tiers.                                                                           
Tier 2 Admins : can only log on the Tier 2 resources and cannot log to the other tiers.                                                                           

1. Organizational Units

We know that simplicity is the key to design, Organizational Units (OU) allow us to design a tiering model inside of the active directory.
Many organizational units will be created, ParentOu : this is a main OU that will contain all Tiers of OU, the parent OU will be your NetBIOSName domain name.

- ParentOu                                                                                                                                                        
- ParentOu,Tier0                                                                                                                                                  
- ParentOu,Tier1                                                                                                                                                  
- ParentOu,Tier2                                                                                                                                                  
- ParentOu,Tier0,Admins                                                                                                                                           
- ParentOu,Tier0,Groups                                                                                                                                           
- ParentOu,Tier0,Service Accounts                                                                                                                                 
- ParentOu,Tier0,Servers                                                                                                                                          
- ParentOu,Tier0,PAW                                                                                                                                              
- ParentOu,Tier0,PAW Users                                                                                                                                        
- ParentOu,Tier1,Admins                                                                                                                                           
- ParentOu,Tier1,Groups                                                                                                                                           
- ParentOu,Tier1,Service Accounts                                                                                                                                 
- ParentOu,Tier1,Servers                                                                                                                                          
- ParentOu,Tier1,Jump Servers                                                                                                                                     
- ParentOu,Tier1,JumpServer Users                                                                                                                                 
- ParentOu,Tier2,Admins                                                                                                                                           
- ParentOu,Tier2,Groups                                                                                                                                           
- ParentOu,Tier2,WorkStation                                                                                                                                      
- ParentOu,Tier2,Laptops                                                                                                                                          
- ParentOu,Tier2,Users                                                                                                                                           

2. Tiering Security Groups

We know that there are many default security groups in Active Directory, these groups have excessive privileges. 
The default security groups are:

- Administrators                                                                                                                                                  
- Domain Admins                                                                                                                                                   
- Schema Admins                                                                                                                                                   
- Enterprise Admins                                                                                                                                               
- Account Operators                                                                                                                                               
- Server Operators                                                                                                                                                
- Print Operators                                                                                                                                                 
- Backoup Operators                                                                                                                                               
- Etc                                                                                                                                                             

We want to change or revoke some privileges on the default security groups and we will use the tiering security groups.
The tiering security groups are:

- Domain Tier0 Admins                    : Designated for Tier0 admins                                                                                            
- Domain Tier0 Service Accounts          : Designated for Tier0 Service Account                                                                                   
- Domain Tier0 PAW Users                 : Designated for Tier0 PAW Users                                                                                         
- Domain Tier0 PAW Maintenance           : Designated for Tier0 PAW Maintenance                                                                                   
- Domain Tier0 Maintenance               : Designated for Tier0 Maintenance                                                                                       
- Domain Tier0 Remote Domain Controllers : Designated for Tier0 Remote Domain Controllers                                                                         
- Domain Tier1 Admins                    : Designated for Tier1 admins                                                                                            
- Domain Tier1 Service Accounts          : Designated for Tier1 service Accounts                                                                                  
- Domain Tier1 JumpServer Users          : Designated for Tier1 JumpServer Users                                                                                  
- Domain Tier1 Jumpserver Maintenance    : Designated for Tier1 JumpServer Maintenance                                                                            
- Domain Tier1 Maintenance               : Designated for Tier1 Maintenance                                                                                       
- Domain Tier2 Admins                    : Designated for Tier2 Admins                                                                                            
- Domain Tier2 HelpDesk Operators        : Designated for Tier2 Hepldesk Operators                                                                                
- Domain Tier2 Remote Desktop Users      : Designated for Tier2 Remote Desktop Users                                                                              
- Domain Tier2 Users                     : Designated for Tier2 Users                                                                                             

3. Restricted Logon

The restricted Logon is the most important step when we deploy the tiering model. Here we configure the authentication policies. allow or deny the log on.
It's faisable with the group policies below:

- Access this computer from the network                                                                                                                           
- Allow log on locally                                                                                                                                            
- Allow log on through Remote Desktop service                                                                                                                     
- Allow log on a batch                                                                                                                                            
- Allow log on a service                                                                                                                                          
                                                                                                                                                                
- Deny Access this computer from the network                                                                                                                      
- Deny Allow log on locally                                                                                                                                       
- Deny Allow log on through Remote Desktop service                                                                                                                
- Deny Allow log on a batch                                                                                                                                       
- Deny Allow log on a service                                                                                                                                     

4. Use

AD-Tiering is a set of many powershell scripts centralized in one interface, taht makes it easy to use.
AD-Tiering contains:

- 00_OU_Tiering.ps1
- 01_Groups_Tiering.ps1
- 02_GPO_Tiering.ps1
- 03_UserRightAssignment_DC_Tiering.ps1
- 04_RestrictedLogon_Tiering.ps1
- MENU_Tiering.ps1

Note : During the implementation, a Tier 0 user account will be created for the first connection when the server restarts, you must change the default password for security reasons. username : t0admin and password : Ti3r1ng&%!147741

Conclusion

The idea is to make simpler Active Directory Tiering implementation, we know that the tiering has been removed form generales recommandations per Microsoft.
Because it's complex to implement, but there remain the best practices to reduce attack surface in Active Directory and prevent lateral movement between the tiers. Active Directory security is very important and it should not be limited with the tiering model.
