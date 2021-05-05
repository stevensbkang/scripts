param(
  $credentials,
  $portainer_agent_image,
  portainer_environment_is_agent,
  portainer_environment_is_edge,
  portainer_admin_password
)

if ( $portainer_environment_is_agent ) {
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
} elseif ( $portainer_environment_is_edge ) {
  
  $portainer_jwt = (C:\Python39\Scripts\http.exe POST http://10.0.1.11:9000/api/auth Username="admin" Password="${portainer_admin_password}" | ConvertFrom-Json).jwt
  $ip_address = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -match "10.0"}).IPAddress
  
  $edge_key = (C:\Python39\Scripts\http.exe --form POST http://10.0.1.11:9000/api/endpoints "Authorization: Bearer ${portainer_jwt}" Name="edge-${ip_address}" EndpointCreationType=4 URL="http://10.0.1.11:9000" | ConvertFrom-Json).EdgeKey
  $edge_uuid = (New-Guid).Guid
  
  docker run -d `
    --mount type=npipe,src=\\.\pipe\docker_engine,dst=\\.\pipe\docker_engine `
    --mount type=bind,src=C:\ProgramData\docker\volumes,dst=C:\ProgramData\docker\volumes `
    --mount type=volume,src=portainer_agent_data,dst=C:\data `
    --restart always `
    -e EDGE=1 `
    -e EDGE_ID=$edge_uuid `
    -e EDGE_KEY=$edge_key `
    -e CAP_HOST_MANAGEMENT=1 `
    --name portainer_edge_agent `
    $portainer_agent_image
}
