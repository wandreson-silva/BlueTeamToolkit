while($true){

Clear-Host
Write-Host "MONITOR DE PORTAS ATIVAS" -ForegroundColor Green
Write-Host "Atualização: $(Get-Date)"
Write-Host ""

Get-NetTCPConnection |
Select LocalAddress,LocalPort,RemoteAddress,RemotePort,State,OwningProcess |
Sort LocalPort |
Format-Table

Start-Sleep 5

}