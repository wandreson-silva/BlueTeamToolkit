Get-NetTCPConnection -ErrorAction SilentlyContinue | ForEach-Object {
    $processName = "N/A"
    try {
        # O '-ErrorAction Stop' força o comando a ir para o Catch caso o PID tenha sumido da memória
        $p = Get-Process -Id $_.OwningProcess -ErrorAction Stop
        $processName = $p.ProcessName
    }
    catch {
        $processName = "Desconhecido/Encerrado"
    }

    [PSCustomObject]@{
        Processo   = $processName
        PID        = $_.OwningProcess
        PortaLocal = $_.LocalPort
        IPRemoto   = $_.RemoteAddress
        Estado     = $_.State
    }
} | Format-Table -Autosize