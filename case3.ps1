Write-Host "Hvilken server skal du have en rapport fra?"
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
Invoke-Command -ComputerName $computer -Credential (Get-Credential) -ScriptBlock {
    Get-ADUser -Filter * -SearchBase "OU=Users,OU=Andeby,DC=jaadom,DC=local" -Properties Title,Company,StreetAddress,City,State,Enabled |
    Where-Object {$_.Enabled -eq "True"} |
    Select-Object Name,SamAccountName,UserPrincipalName,Title,Company,StreetAddress,City,State |
    Sort-Object Name |
    Export-Csv -Path C:\temp\users.csv -NoTypeInformation
    Write-Host "CSV er eksporteret"
}
