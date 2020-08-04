function comp_info{
    param(
        $compName
    )
    
    # if computer is online
    if (!(Test-Connection $compName -Count 1)){
        Write-Warning "Computer is not active"
        break
    }

    else{
        $customObj = New-Object psobject -Property @{`
            "Computer" = Invoke-Command -ComputerName $compName -ScriptBlock {$env:computername};
            "HDD_Freespace" = Get-WmiObject Win32_LogicalDisk -ComputerName $compName | Measure-Object -Property Freespace -Sum | % {[Math]::Round(($_.sum / 1MB),2)};
            "HDD_Size" = Get-WmiObject Win32_LogicalDisk -ComputerName $compName | Measure-Object -Property Size -Sum | % {[Math]::Round(($_.sum / 1MB),2)};
            "Ram_Size" = Get-WMIObject -class Win32_PhysicalMemory -ComputerName $compName | Measure-Object -Property capacity -Sum | % {[Math]::Round(($_.sum / 1GB),2)}
        }
        
        $result = $customObj | select HDD_Freespace,HDD_Size,Ram_Size
        
        return $result
    }
}

#get all computers that are in domain
$ADCOMPS=@(Get-ADComputer -Filter {OperatingSystem -like "Windows Server*"}   -Properties Name | select name | ft -HideTableHeaders)

foreach ($comp in $ADCOMPS){
    $getcomp += comp_info -compName $comp
}
