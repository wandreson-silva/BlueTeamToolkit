Write-Host "Tabela ARP atual:" -ForegroundColor Cyan
arp -a

Write-Host ""
Write-Host "Verifique se um mesmo MAC aparece para vários IPs." -ForegroundColor Yellow