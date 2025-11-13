Write-Host "Hvilken server skal du have en rapport fra?"
Write-Host "1. AD Server"
Write-Host "2. DNS Server"
$svar = Read-Host "Hvilken server? (1/2)"

switch ($svar) {
    1 { $computer = "10.101.225.251" }
    2 { $computer = "10.101.67.225" }
    Default { 
        Write-Host "Noget gik galt. Skrev du tal?"
        exit
    }
}

Invoke-Command -ComputerName $computer -Credential (Get-Credential) -ScriptBlock {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $cpu = Get-CimInstance -ClassName Win32_Processor
    $ram = Get-CimInstance -ClassName Win32_PhysicalMemory
    $nic = Get-CimInstance -ClassName Win32_NetworkAdapter -Filter "PhysicalAdapter = True"
    $ipinfo = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Where-Object{$_.IPEnabled}

    [PSCustomObject]@{
        Server = $env:COMPUTERNAME
        "OS Navn" = $os.Caption
        "OS Version" = $os.Version
        "Sidste start" = $os.LastBootUpTime
        "CPU navn" = ($cpu.Name -join ",")
        "CPU cores" = ($cpu | Measure-Object NumberOfCores -Sum).Sum
        "CPU Processorer" = ($cpu | Measure-Object NumberOfLogicalProcessors -Sum).Sum
        "CPU Speed" = ($cpu.MaxClockSpeed | Select-Object -First 1)
        "RAM producent" = $ram.Manufacturer
        "RAM Kapacitet" = $ram.Capacity
        "RAM Hastighed" = $ram.Speed
        "NIC Navn" = $nic.Name
        "NIC ID" = $nic.NetConnectionID
        "NIC MAC" = $nic.MACAddress
        "NIC type" = $nic.AdapterType
        "NIC Producent" = $nic.Manufacturer
        "IP Info" = $ipinfo.Description
        "IP Adresse" = ($ipinfo.IPAddress -join " ")
        "IP Subnet" = ($ipinfo.IPSubnet | ForEach-Object {$_.ToString()}) -join " "
        "IP Gateway" = ($ipinfo.DefaultIPGateway | ForEach-Object {$_.ToString()}) -join " "
        "IP DNS" = ($ipinfo.DNSServerSearchOrder | ForEach-Object {$_.ToString()}) -join " "
        "IP Mac" = $ipinfo.MACAddress
        "IP DHCP" = $ipinfo.DHCPEnabled
    } | Export-Csv -Path c:\temp\case4_2.csv -NoTypeInformation
 }
 write-host "Rapport genereret"