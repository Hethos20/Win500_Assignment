# to be stored in C:\temp on SRV1-AD

$compName = $args[0]
$power = $args[1]

if ($power -eq $true) {
    $customObj = New-Object psobject -Property @{`
        "Computer" = $compName;
        "HDD_Freespace_MB" = Get-WmiObject Win32_LogicalDisk -ComputerName $compName | Measure-Object -Property Freespace -Sum | % {[Math]::Round(($_.sum / 1MB),2)};
        "HDD_Size_MB" = Get-WmiObject Win32_LogicalDisk -ComputerName $compName | Measure-Object -Property Size -Sum | % {[Math]::Round(($_.sum / 1MB),2)};
        "Ram_Size_GB" = Get-WMIObject -class Win32_PhysicalMemory -ComputerName $compName | Measure-Object -Property capacity -Sum | % {[Math]::Round(($_.sum / 1GB),2)}
        "Operating_System" = Invoke-Command -ComputerName $compName -ScriptBlock {(Get-WMIObject win32_operatingsystem).caption}
    }
    
    $result = $customObj | select Computer,HDD_Freespace_MB,HDD_Size_MB,Ram_Size_GB,Operating_System

    return $result
}

else{

    $customObj = New-Object psobject -Property @{`
        "Computer" = $compName;
    }

    $result = $customObj | select Computer
    
    return $result
}
