#get all computers that are in domain
$ADCOMPS=@(Get-ADComputer -Filter {OperatingSystem -like "Windows Server*"}   -Properties Name | select name | ft -HideTableHeaders)

$table = @()

foreach ($x in $ADCOMPS){
    #get hard drive size
    $hdfreespace = Get-WmiObject Win32_LogicalDisk -ComputerName $x | Measure-Object -Property Freespace -Sum | % {[Math]::Round(($_.sum / 1MB),2)}
    $hdSize = Get-WmiObject Win32_LogicalDisk -ComputerName $x | Measure-Object -Property Size -Sum | % {[Math]::Round(($_.sum / 1MB),2)}
    # get ram size
    $ramSize = Get-WMIObject -class Win32_PhysicalMemory -ComputerName $x | Measure-Object -Property capacity -Sum | % {[Math]::Round(($_.sum / 1GB),2)}
    $table.Add($x,$hdfreespace,$hdSize,$ramSize)
}
