
#get all computers that are in domain
$computers = Get-ADComputer -Filter 'operatingsystem -like "*server*" -and enabled -eq "true"' `
-Properties Name,Operatingsystem,OperatingSystemVersion,IPv4Address |
Sort-Object -Property Operatingsystem |
Select-Object -Property Name,Operatingsystem,OperatingSystemVersion,IPv4Address


