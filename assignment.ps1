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
