while($true){
    Clear-Host
    Write-Host "MONITOR DE PORTAS E CONEXÕES ATIVAS" -ForegroundColor Green
    Write-Host "Atualização: $(Get-Date)"
    Write-Host "Pressione CTRL+C para encerrar o monitoramento.`n"

    # Filtra conexões que não estão apenas escutando localmente (evita poluição por 0.0.0.0)
    Get-NetTCPConnection -ErrorAction SilentlyContinue | 
        Where-Object { $_.State -ne "Listen" } |
        Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State, OwningProcess |
        Sort-Object LocalPort |
        Format-Table -Autosize

    Start-Sleep 5
}