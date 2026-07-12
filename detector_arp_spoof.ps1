[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "Iniciando Detetor ARP Spoofing focado no Gateway..." -ForegroundColor Cyan

# 1. Identifica o IP do Gateway Padrão (Roteador) de forma dinâmica
$gatewayIP = (Get-NetRoute -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue | 
              Where-Object { $_.NextHop -ne "0.0.0.0" } | 
              Select-Object -First 1).NextHop

if (-not $gatewayIP) {
    Write-Host "[-] Alerta: Não foi possível determinar o Gateway Padrão automaticamente." -ForegroundColor Yellow
} else {
    Write-Host "[+] Gateway Padrão detectado: $gatewayIP" -ForegroundColor Green
}

# 2. Captura e filtra a tabela ARP (padrão estrito de MAC)
$arpLines = arp -a | Where-Object { $_ -match '\s+([0-9\.]+)\s+(([0-9a-f]{2}-){5}[0-9a-f]{2})\s+(\w+)' }
$arpEntries = foreach ($line in $arpLines) {
    if ($line -match '\s+(?<IP>[0-9\.]+)\s+(?<MAC>([0-9a-f]{2}-){5}[0-9a-f]{2})\s+(?<Type>\w+)') {
        [PSCustomObject]@{
            IP  = $Matches.IP
            MAC = $Matches.MAC.ToLower()
        }
    }
}

# Exibe a tabela capturada para o operador do SOC
if ($arpEntries) {
    Write-Host "`nTabela ARP Atualizada:" -ForegroundColor Gray
    $arpEntries | Format-Table -Property IP, MAC -Autosize
} else {
    Write-Host "[-] Tabela ARP vazia ou sem entradas válidas." -ForegroundColor Yellow
    return
}

# 3. Análise direcionada ao Gateway Padrão
if ($gatewayIP) {
    $gatewayEntry = $arpEntries | Where-Object { $_.IP -eq $gatewayIP }
    
    if ($gatewayEntry) {
        $gatewayMAC = $gatewayEntry.MAC
        Write-Host "[*] Validando integridade do MAC do Gateway: $gatewayMAC" -ForegroundColor Gray
        
        # Procura qualquer OUTRO IP na rede que esteja usando o MESMO MAC do Gateway
        $gatewayClones = $arpEntries | Where-Object { $_.MAC -eq $gatewayMAC -and $_.IP -ne $gatewayIP }
        
        if ($gatewayClones) {
            Write-Host "`n[!!!] ALERTA CRÍTICO: SEU GATEWAY ESTÁ SENDO ENVENENADO!" -ForegroundColor Red
            Write-Host "O endereço MAC do roteador ($gatewayMAC) está associado a IPs clonados." -ForegroundColor Yellow
            Write-Host "Identidade do provável atacante na rede local:" -ForegroundColor Red
            foreach ($clone in $gatewayClones) {
                Write-Host "  -> IP do Atacante: $($clone.IP)" -ForegroundColor DarkRed
            }
            Write-Host "[!] Seu tráfego de internet está possivelmente sendo interceptado agora." -ForegroundColor Red
            return
        }
    } else {
        Write-Host "[-] O IP do Gateway ($gatewayIP) não está na tabela ARP local." -ForegroundColor Yellow
        Write-Host "[*] Dica: Execute um ping para o IP do seu roteador para forçar o mapeamento ARP." -ForegroundColor Gray
    }
}

# 4. Varredura global secundária (para o restante da rede)
$globalSpoof = $arpEntries | Where-Object { 
    $_.MAC -ne "ff-ff-ff-ff-ff-ff" -and $_.MAC -notlike "01-00-5e*" 
} | Group-Object MAC | Where-Object { $_.Count -gt 1 }

if ($globalSpoof) {
    Write-Host "`n[!] Aviso: Duplicidade detectada em outros dispositivos da rede (não-gateway):" -ForegroundColor Yellow
    foreach ($match in $globalSpoof) {
        Write-Host "O MAC [$($match.Name)] está compartilhado entre:" -ForegroundColor DarkYellow
        foreach ($item in $match.Group) {
            Write-Host "  -> $($item.IP)" -ForegroundColor DarkYellow
        }
    }
} else {
    Write-Host "`n[+] Sucesso: Nenhuma anomalia ou ataque de ARP Spoofing detectado na rede." -ForegroundColor Green
}