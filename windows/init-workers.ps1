param(
  [Parameter(Mandatory = $True)]
  [string]
  $credentials
)

New-NetFirewallRule -DisplayName "Allow Swarm TCP" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 2377, 7946 | Out-Null
New-NetFirewallRule -DisplayName "Allow Swarm UDP" -Direction Inbound -Action Allow -Protocol UDP -LocalPort 4789, 7946 | Out-Null

curl https://the.earth.li/~sgtatham/putty/latest/w64/plink.exe -o plink.exe
$finger_print = (((.\plink.exe -v -batch 10.0.1.11) 2>&1)[9] -split " ")[2]
$token = .\plink.exe local_admin@10.0.1.11 -pw $credentials -hostkey $finger_print -batch 'docker swarm join-token worker -q' 2>&1 

docker swarm join --token $token 10.0.1.11:2377
