$disks = Get-Disk | Where partitionstyle -eq 'raw' | sort number
$count = 0
    $letter = "F","L","S"
    foreach ($disk in $disks) {
        $drive = $letter[$count].ToString()
        $disk | 
        Initialize-Disk -PartitionStyle MBR -PassThru |
        New-Partition -UseMaximumSize -DriveLetter $drive |
        Format-Volume -FileSystem NTFS -NewFileSystemLabel $letter[$count] -Confirm:$false -Force
    $count++
    }

Get-WmiObject -Class Win32_volume -Filter "DriveLetter = 'E:'" |Set-WmiInstance -Arguments @{DriveLetter='Z:'}
Get-WmiObject -Class Win32_volume -Filter "DriveLetter = 'F:'" |Set-WmiInstance -Arguments @{DriveLetter='E:';Label='sqlData:'}
Get-WmiObject -Class Win32_volume -Filter "DriveLetter = 'L:'" |Set-WmiInstance -Arguments @{Label='sqlLog:'}
Get-WmiObject -Class Win32_volume -Filter "DriveLetter = 'S:'" |Set-WmiInstance -Arguments @{Label='sqlSystem:'}
