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
    Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object Caption,Version,LastBootUpTime | Export-Csv c:\temp\OS_Systemrapport.csv -NoTypeInformation
    Get-CimInstance -ClassName Win32_Processor | Select-Object Name,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed | Export-Csv c:\temp\CPU_Systemrapport.csv -NoTypeInformation
    Get-CimInstance -ClassName Win32_PhysicalMemory | Select-Object Manufacturer,Capacity,Speed | Export-Csv c:\temp\RAM_Systemrapport.csv -NoTypeInformation
    Get-CimInstance -ClassName Win32_NetworkAdapter -Filter "PhysicalAdapter = True" | Select-Object Name,NetConnectionID,MACAddress,PhysicalAdapter,AdapterType,Manufacturer | Export-Csv c:\temp\NET_Systemrapport.csv -NoTypeInformation
    Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Select-Object Description,IPAddress,IPSubnet,DefaultIPGateway,DNSServerSearchOrder,MACAddress,DHCPEnabled | Export-Csv c:\temp\NET_Conf_Systemrapport.csv -NoTypeInformation
    Write-Host "Eksporteret data til csv"
}