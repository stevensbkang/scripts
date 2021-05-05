param(
  [Parameter(Mandatory = $True)]
  [string]
  $credentials
)

New-NetFirewallRule -DisplayName "Allow Swarm TCP" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 2377, 7946 | Out-Null
New-NetFirewallRule -DisplayName "Allow Swarm UDP" -Direction Inbound -Action Allow -Protocol UDP -LocalPort 4789, 7946 | Out-Null

$plink_execution = "curl https://the.earth.li/~sgtatham/putty/latest/w64/plink.exe -o plink.exe"
Invoke-Expression $plink_execution

$token_execution = "cmd.exe /c echo y | ./plink.exe 10.0.1.11 -P 22 -l local_admin -pw '$credentials' docker swarm join-token -q worker"
Invoke-Expression $token_execution | Out-Null

$token = Invoke-Expression $token_execution

if ($token) {
  docker swarm join --token $token 10.0.1.11:2377
}
