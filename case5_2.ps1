Start-Transcript -Path c:\temp\add-ad-user.log -Append
Write-Host "Hvilken server skal du oprette en bruger på?"
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
    $Users = Import-Csv -Path C:\temp\nye_brugere2.csv

    $Report = @()

    foreach ($User in $Users) {
        try {
            $existingUser = Get-ADUser -Filter "SamAccountName -eq '$($User.SamAccountName)'" -ErrorAction SilentlyContinue

            if ($existingUser) {
                Write-Host "Bruger findes allerede: $($User.SamAccountName)" -ForegroundColor Yellow
                $Report += [PSCustomObject]@{
                    Navn     = "$($User.GivenName) $($User.Surname)"
                    Konto    = $User.SamAccountName
                    Gruppe   = $User.Groups
                    Oprettet = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                    Status   = "Findes allerede"
                }
                continue
            }

            $confirm = Read-Host "Vil du oprette brugeren $($User.SamAccountName)? (Y/N)"
            if ($confirm -ne "Y") {
                Write-Host "Springer over $($User.SamAccountName)" -ForegroundColor Yellow
                $Report += [PSCustomObject]@{
                    Navn     = "$($User.GivenName) $($User.Surname)"
                    Konto    = $User.SamAccountName
                    Gruppe   = ""
                    Oprettet = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                    Status   = "Afvist af bruger"
                }
                continue
            }

            New-ADUser `
                -SamAccountName $User.SamAccountName `
                -UserPrincipalName $User.Email `
                -Name $User.GivenName `
                -GivenName $User.GivenName `
                -Surname $User.Surname `
                -DisplayName "$($User.GivenName) $($User.Surname)" `
                -Department $User.Department `
                -Path $User.OU `
                -EmailAddress $User.Email `
                -Enabled $true `
                -AccountPassword (ConvertTo-SecureString $User.Password -AsPlainText -Force) `
                -Confirm:$false

            if (Get-ADUser -Filter "SamAccountName -eq '$($User.SamAccountName)'") {
                Write-Host "Oprettet: $($User.SamAccountName)" -ForegroundColor Green
                Add-ADGroupMember -Identity $User.Groups -Members $User.SamAccountName
                Write-Host "Tilføjet $($User.GivenName) $($User.Surname) til $($User.Groups) gruppen" -ForegroundColor Green
                $Report += [PSCustomObject]@{
                    Navn     = "$($User.GivenName) $($User.Surname)"
                    Konto    = $User.SamAccountName
                    Gruppe   = ""
                    Oprettet = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                    Status   = "Oprettet"
                }
            }
            else {
                Write-Host "Bruger blev ikke oprettet: $($User.SamAccountName)" -ForegroundColor Yellow
                $Report += [PSCustomObject]@{
                    Navn     = "$($User.GivenName) $($User.Surname)"
                    Konto    = $User.SamAccountName
                    Gruppe   = ""
                    Oprettet = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                    Status   = "Ikke oprettet"
                }
            }

        } catch {
            Write-Error "Fejl ved oprettelse af $($User.SamAccountName) : $($_.Exception.Message)"
            $Report += [PSCustomObject]@{
                Navn     = "$($User.GivenName) $($User.Surname)"
                    Konto    = $User.SamAccountName
                    Gruppe   = ""
                    Oprettet = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                    Status   = "Fejl: $($_.Exception.Message)"
            }
        }
    }
    $ReportPath = "C:\temp\AD_User_Report_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
    $Report | Export-Csv -Path $ReportPath -NoTypeInformation -Encoding UTF8
}
Stop-Transcript
