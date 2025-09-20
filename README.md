# AD-Tiering : Automating Active Directory Tiering
Overview

The purpose of this script is to simplify Tiering model implementation.

Tiering model standard consists of three tiers, tiers 0, 1, and 2.

1. Organizational Units
2. Tiering Security Groups

We know that it exists most default security groups into Active Directory, these groups have excess privilege. 
The default security groups are :

- Administrators
- Domain Admins
- Schema Admins
- Enterprise Admins
- Account Operators
- Server Operators
- Print Operators
- Backoup Operators
- Etc

We wish to change and revoke some privileges on the default security groups and we'll use tiering security groups.
The tiering security groups :

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

Restricted Logon is the most important step when we deploy the tiering model, Here we configure how can to log on interactive and remote mode.
It's possible with those group policies below :

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


Conclusion

The idea is to make simpler Active Directory Tiering deployment, we know that the tiering is not recommanded per Microsoft.
But it still the best practices to reduce surface attack into Active Directory and prevent lateral movement between the tiers.
Active Directory security is complex and don't limit with tiering model.