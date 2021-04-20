param(
  [Parameter(Mandatory = $True)]
  [string]
  $credentials
)

New-NetFirewallRule -DisplayName "Allow Swarm TCP" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 2377, 7946 | Out-Null
New-NetFirewallRule -DisplayName "Allow Swarm UDP" -Direction Inbound -Action Allow -Protocol UDP -LocalPort 4789, 7946 | Out-Null

## Configuration of SSH Server - Debugging Purpose
Add-WindowsCapability -Online -Name (Get-WindowsCapability -Online -Name 'OpenSSH.Server*').Name
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
Get-NetFirewallRule -Name *ssh*
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
################################################################################################################################################################

Set-Location $ENV:TMP

curl https://the.earth.li/~sgtatham/putty/latest/w64/plink.exe -o plink.exe
$finger_print = (((.\plink.exe -v -batch 10.0.1.11) 2>&1)[9] -split " ")[2]

$finger_print | Out-File "$ENV:TMP\temp.txt"

# $token = .\plink.exe local_admin@10.0.1.11 -pw $credentials -hostkey $finger_print -batch docker swarm join-token -q worker

# Write-Host $token

# docker swarm join --token $token 10.0.1.11:2377
