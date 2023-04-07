#-------------------------------------------------------------------------------------------------------------------------------------------------#
#          _             _                _            _            _   _         _                 _          _          _             _         #
#         / /\          /\_\             /\ \         /\ \         /\_\/\_\ _    / /\              /\ \       /\ \       /\ \     _    /\ \       #
#        / /  \        / / /         _   \_\ \       /  \ \       / / / / //\_\ / /  \             \_\ \      \ \ \     /  \ \   /\_\ /  \ \      #
#       / / /\ \       \ \ \__      /\_\ /\__ \     / /\ \ \     /\ \/ \ \/ / // / /\ \            /\__ \     /\ \_\   / /\ \ \_/ / // /\ \_\     #
#      / / /\ \ \       \ \___\    / / // /_ \ \   / / /\ \ \   /  \____\__/ // / /\ \ \          / /_ \ \   / /\/_/  / / /\ \___/ // / /\/_/     #
#     / / /  \ \ \       \__  /   / / // / /\ \ \ / / /  \ \_\ / /\/________// / /  \ \ \        / / /\ \ \ / / /    / / /  \/____// / / ______   #
#    / / /___/ /\ \      / / /   / / // / /  \/_// / /   / / // / /\/_// / // / /___/ /\ \      / / /  \/_// / /    / / /    / / // / / /\_____\  #
#   / / /_____/ /\ \    / / /   / / // / /      / / /   / / // / /    / / // / /_____/ /\ \    / / /      / / /    / / /    / / // / /  \/____ /  #
#  / /_________/\ \ \  / / /___/ / // / /      / / /___/ / // / /    / / // /_________/\ \ \  / / /   ___/ / /__  / / /    / / // / /_____/ / /   #
# / / /_       __\ \_\/ / /____\/ //_/ /      / / /____\/ / \/_/    / / // / /_       __\ \_\/_/ /   /\__\/_/___\/ / /    / / // / /______\/ /    #
# \_\___\     /____/_/\/_________/ \_\/       \/_________/          \/_/ \_\___\     /____/_/\_\/    \/_________/\/_/     \/_/ \/___________/     #
#                            _              _        _            _       _                _        _    _        _                               #
#                           / /\      _    /\ \     /\ \         / /\    / /\             /\ \     /\ \ /\ \     /\_\                             #
#                          / / /    / /\   \ \ \    \_\ \       / / /   / / /             \ \ \   /  \ \\ \ \   / / /                             #
#                         / / /    / / /   /\ \_\   /\__ \     / /_/   / / /              /\ \_\ / /\ \ \\ \ \_/ / /                              #
#                        / / /_   / / /   / /\/_/  / /_ \ \   / /\ \__/ / /              / /\/_// / /\ \ \\ \___/ /                               #
#                       / /_//_/\/ / /   / / /    / / /\ \ \ / /\ \___\/ /      _       / / /  / / /  \ \_\\ \ \_/                                #
#                      / _______/\/ /   / / /    / / /  \/_// / /\/___/ /      /\ \    / / /  / / /   / / / \ \ \                                 #
#                     / /  \____\  /   / / /    / / /      / / /   / / /       \ \_\  / / /  / / /   / / /   \ \ \                                #
#                    /_/ /\ \ /\ \/___/ / /__  / / /      / / /   / / /        / / /_/ / /  / / /___/ / /     \ \ \                               #
#                    \_\//_/ /_/ //\__\/_/___\/_/ /      / / /   / / /        / / /__\/ /  / / /____\/ /       \ \_\                              #
#                        \_\/\_\/ \/_________/\_\/       \/_/    \/_/         \/_______/   \/_________/         \/_/                              #
#                                                                                                                                                 #
#-------------------------------------------------------------------------------------------------------------------------------------------------#
# Disclaimer:                                                                                                                                     #
#                                                                                                                                                 #
# This script comes with no guarantees. The cmdlets in this script functioned as is on the moment of creating the script.                         #
# It is possible that during the lifecycle of the product this script is intended for, updates were performed to the systems and the script       #
# might not, or might to some extent, no longer function.                                                                                         #
#                                                                                                                                                 #
# Therefor, I would suggest running the script in a test environment first, cmdlet per cmdlet, before effectively running it in production        #
# environments.                                                                                                                                   #
#                                                                                                                                                 #
# Created by Leon Moris                                                                                                                           #
# Website: www.switchtojoy.be                                                                                                                     #
# Github: https://github.com/Joy-Leon                                                                                                             #
#-------------------------------------------------------------------------------------------------------------------------------------------------#

#-------------------------------------------------------------------------------------------------------------------------------------------------#
# Declared functions.

function func_logging {   
    param ($String) 
    func_writeok $string
    Start-Sleep -Seconds 1 
    return "[{0:dd/MM/yy} {0:HH:mm:ss}] $String" -f (Get-Date)  | Out-File $logfile -append
}
function func_writeok {
    param ($string)
    write-host ""
    write-host $string -f green
    Start-Sleep -Seconds 1
}
function func_writenok {
    param ($string)
    write-host ""
    write-host $string -f red
    Start-Sleep -Seconds 1
}

function func_directory {
    param($Path)
    if (!(Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path | out-null
    }
}

function func_checkvariable {
    param ($variable, $filename, $name)
    if ($null -eq $variable){
        func_writenok "An error has occurred with gathering data from the file $FILENAME"
        func_writenok "Some data is missing. Please check your configuration and retry."
        break 
    } Else {
        func_logging "The $name is $($variable)"
    }
}

#-------------------------------------------------------------------------------------------------------------------------------------------------#

#-------------------------------------------------------------------------------------------------------------------------------------------------#
# Declared variables.

$Root = "C:\Joy"
func_directory $Root
(get-item $Root).Attributes += 'Hidden'

$logfile = "$Root\logfile.txt"
if (Test-Path $logfile) {
    if (Test-Path "$logfile.old") {
        Remove-Item "$logfile.old"
    }
    move-item $logfile -destination "$logfile.old"
}
new-item $logfile | func_logging "A logfile has been created at $logfile"

#-------------------------------------------------------------------------------------------------------------------------------------------------#
# Gather information regarding the server instance

$NIC = Import-Csv .\SRV-InstallAD-NIC.csv -Delimiter ';'
$Machine = Import-CSV .\SRV-InstallAD-Host.csv -Delimiter ';'
 
$FILENAME = "SRV-InstallAD-NIC.csv"
$NAME = "IP identifier"
func_checkvariable $NIC.IPAddress $filename $name
$NAME = "Prefix length"
func_checkvariable $NIC.PrefixLength $filename $name
$NAME = "Default gateway"
func_checkvariable $NIC.DefaultGateway $filename $name

$FILENAME = "SRV-InstallAD-Host.csv"
$NAME = "Hostname"
func_checkvariable $MACHINE.Hostname $filename $name

#-------------------------------------------------------------------------------------------------------------------------------------------------#
# Gather information regarding the domain

$FQDN = Import-Csv .\SRV-InstallAD-Domain.csv -Delimiter ';'
$FILENAME = "SRV-InstallAD-Domain.csv"
$NAME = "Domain prefix"
func_checkvariable $fqdn.DomainPrefix $filename $name
$NAME = "Second level domain"
func_checkvariable $FQDN.SecondLevelDomain $filename $name
$NAME = "Top level domain"
func_checkvariable $FQDN.TopLevelDomain $filename $name

$FQDN = $($FQDN.DomainPrefix) + "." + $($FQDN.SecondLevelDomain) + "." + $($FQDN.TopLevelDomain)

$adminpwd = ConvertTo-SecureString "Pass-w0rd" -AsPlainText -force
func_writenok "The administrator password has been set to 'Pass-w0rd'. Please remember to change the password!"

#-------------------------------------------------------------------------------------------------------------------------------------------------#
# Install AD & DNS and configure the PTR record in the reverse DNS zone

Get-NetIPInterface -InterfaceIndex (Get-NetAdapter).InterfaceIndex | Set-NetIPInterface -Dhcp Disabled
New-NetIPAddress -InterfaceIndex (Get-NetAdapter).InterfaceIndex -IPAddress $nic.IPAddress -PrefixLength $NIC.PrefixLength -DefaultGateway $NIC.DefaultGateway | Out-File $logfile
func_logging "The IP address has been configured on the default ethernet adapter of the server."

install-windowsfeature AD-domain-services -IncludeManagementTools
Import-Module ADDSDeployment
Install-ADDSForest `
-DomainName $FQDN `
-DomainMode WinThreshold `
-ForestMode WinThreshold `
-InstallDNS `
-CreateDNSDelegation:$false `
-DatabasePath "C:\Windows\NTDS" `
-LogPath "C:\Windows\NTDS" `
-SysvolPath "C:\Windows\SYSVOL" `
-NoRebootOnCompletion:$true `
-safemodeadministratorpassword $adminpwd `
-Force | Out-File $logfile
func_logging "The Microsoft AD DS services has been installed and configured"

Set-DnsClientServerAddress -InterfaceAlias $Ethernet.name -ServerAddresses ($NIC.IPAddress) | Out-File $logfile
func_logging "The DNS address has been configured on the default ethernet adapter of the server."
Set-DnsClient -InterfaceAlias $Ethernet.name -connectionspecificsuffix $FQDN | Out-File $logfile
func_logging "The DNS suffix has been configured on the default ethernet adapter of the server."
func_logging "The script has completed, we recommend to reboot your server before proceeding further."
