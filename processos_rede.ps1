Get-NetTCPConnection | ForEach-Object {

try{
$p = Get-Process -Id $_.OwningProcess
}
catch{
$p = "N/A"
}

[PSCustomObject]@{

Processo=$p.ProcessName
PID=$_.OwningProcess
LocalPort=$_.LocalPort
RemoteIP=$_.RemoteAddress
Estado=$_.State

}

} | Format-Table