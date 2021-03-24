New-NetFirewallRule -DisplayName 'Allow Swarm TCP' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 2377, 7946 | Out-Null
New-NetFirewallRule -DisplayName 'Allow Swarm UDP' -Direction Inbound -Action Allow -Protocol UDP -LocalPort 4789, 7946 | Out-Null
docker swarm init --advertise-addr 10.0.1.11 --default-addr-pool 10.0.1.0/23
Add-WindowsCapability -Online -Name (Get-WindowsCapability -Online -Name 'OpenSSH.Server*').Name
