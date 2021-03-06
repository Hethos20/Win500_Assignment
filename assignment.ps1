Function CreateUserSession{
    param
    (
        $userSession,
        $compName
    )

    # create session
    $theSession = New-PSSession -ComputerName $compName -Name $userSession
    
    # list all sessions
    Get-PSSession
}

Function EnterUserSession{
    param(
    $sessionName
    )
    
    # go to session
    Enter-PSSession -Session $sessionName

    # wait for user to agree to kill session
    Read-Host "Kill Session?"
    
    # Kill the pssession
    Remove-PSSession -Session $sessionName
}

Function ServerInventory{
    # Design style of the table
    $Header = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #72e4ff;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@

    # get all computers that are in domain
    $tempFile = @(Get-ADComputer -Filter * -Properties Name | Select-Object Name | ft -HideTableHeaders | Out-File C:\temp\computers.txt)
    # get all computer names
    $ADComp = Get-Content -Path C:\temp\computers.txt
    # remove all empty lines
    $ADComp = $ADComp | where{$_ -ne ""}

    # Array that stores computer info values
    $getcomp = @()

    # add all computers that are online into the array called $getcomp
    foreach ($comp in $ADComp){
        # remove all leading white spaces
        $computer = $comp.Trim()

        # if computer is online
        if (Test-Connection $computer -Count 1){
            $result = &"C:\temp\comp_info.ps1" $computer $true
            $getcomp += $result
        }
    }

    # this will add all computers that aren't online into the bottom of the array called $getcomp
    foreach ($comp in $ADComp){
        # remove all leading white spaces
        $computer = $comp.Trim()

        # if computer is not online
        if (!(Test-Connection $computer -Count 1)){
            $result = &"C:\temp\comp_info.ps1" $computer $false
            $getcomp += $result
        }
    }

    # output the array $getcomp
    # sort by operating system
    # convert to html with table headers
    # output html file 
    $getcomp | Sort-Object Operating_System | ConvertTo-Html -Property Computer,HDD_Freespace_MB,hdd_Size_MB,Ram_Size_GB,Operating_System -Head $Header | Out-File C:\temp\report.html

    # open the html file in browser
    Invoke-Item C:\temp\report.html
}

Function Firewall{

    # get all computers that are in domain
    Get-ADComputer -Filter * -Properties Name | Select-Object Name | ft -HideTableHeaders | Out-File "C:\temp\mysystems.txt"
    # get all computer names
    $ADComp = Get-Content -Path C:\temp\mysystems.txt
    # remove all empty lines
    $ADComp = $ADComp | where{$_ -ne ""}

    $firewallStuff = @()

    foreach($comp in $ADComp){
        $computer = $comp.Trim()

        # change firewall profile to true
        Invoke-Command -ComputerName $computer -Credential Administrator -ScriptBlock {Set-NetFirewallProfile -Profile * -Enabled True}
        # check firewall status
        Invoke-Command -ComputerName $computer -ScriptBlock {Get-NetFirewallProfile | Select-Object Enabled}
    }

    Clear-Content C:\temp\firewall.txt

    foreach($comp in $ADComp){
        $computer = $comp.Trim()
        Invoke-Command -ComputerName $computer -ScriptBlock {Get-NetFirewallRule | Select-Object Name} | Out-File -Append C:\temp\firewall.txt
    }
}

clear

Write-Host "1) Server Inventory`n2) Sessions`n3) Remote Functions`n4) User Management`n5) Module`n6) Endpoints`n7) Picture Management`n8) Firewall`n9) Quit"
$choice = Read-Host "Choose an option from the list (1-8)"

$exit = $false

DO
{
    switch ($choice)
    {
        1 {ServerInventory}
        2 {
            DO
            {
                $theChoice = Read-Host "1:Create session or 2:Enter session?"; 
                if ($theChoice -eq "1") 
                {
                    $sessionName = Read-Host "Enter name of session" 
                    $CompName = Read-Host "Enter name of computer" 
                    CreateUserSession $sessionName $CompName
                    $1exit = $true
                }
                elseif ($theChoice -eq "2")
                {
                    $sessionName = Read-Host "Enter name of session"
                    Enter-PSSession $sessionName
                    $1exit = $true
                }
                else{
                    Write-Host "ERROR: incorrect option"
                }
            } while ($1exit = $false)
          }
        3 {}
        4 {}
        5 {}
        6 {}
        7 {}
        8 {Firewall}
        9 {Write-Host "Good Bye"; $exit=$true}
        default {Write-Host "Option not found"}
    }
} while ($exit = $false)
