Write-Host "Hvilken server skal du slukke en process på?"
Write-Host "1. AD Server"
Write-Host "2. DNS Server"
$svar = Read-Host "Hvilken server? (1/2)"

switch ($svar) {
    1 { $computer = "10.101.225.251" }
    2 { $computer = "10.101.67.225" }
    Default { 
        Write-Host "Du skal skrive 1 eller 2"
        exit
    }
}
#$computer = "10.101.225.251"
#$creds = Get-Credential

Invoke-Command -ComputerName $computer -Credential (Get-Credential) -ScriptBlock {
    Get-CimInstance Win32_Service | Where-Object {$_.State -eq 'Running'} | Select-Object Name, DisplayName, State | Sort-Object DisplayName
    $process = Read-Host "Skriv service som skal slukkes"
    Stop-Service -Name $process
}