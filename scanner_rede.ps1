$rede = "192.168.1"

Write-Host "Escaneando rede local..." -ForegroundColor Yellow

1..254 | ForEach-Object{

$ip="$rede.$_"

if(Test-Connection -ComputerName $ip -Count 1 -Quiet){

Write-Host "Host ativo: $ip" -ForegroundColor Green

}

}