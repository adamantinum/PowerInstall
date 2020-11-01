<#

    Copyright (c) 2020 Alessandro Piras

    
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

#>

Write-Host "`t PowerInstall  Copyright  (C)  2020  Alessandro Piras `n
`t This program comes with ABSOLUTELY NO WARRANTY.
`t This is free software, and you are welcome to redistribute it
`t under certain conditions.
`t Read COPYING file for details about GNU Public License v3 `n"

$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

function Show-Menu {
    $Choise = Read-Host "Please select an option `n p.  Disk Partitioning `n c.  Show License `n q.  Quit"

    Switch ($Choise)
    {
        "c" {
            Get-Content -Path $ScriptDir/COPYING | Out-Host -Paging
        }
	"p" {
	    Write-Host "`n Insert sudo password"
            Initialize-Disk
	}
        "q" {
            Write-Host "`n Goodbye `n"
	    exit
        }
    }
}

function Initialize-Disk {
    Write-Host "Available disks: `n"
    lsblk -o NAME
    $SystemDisk = Read-Host "Please select a disk to install Arch Linux"

    $Alert = Read-Host "`n ATTENTION! The disk /dev/$SystemDisk will be erased! Continue? [Y/n]"

    if ($Alert -ne "Y") 
    {
        exit
    }
    Write-Host "Creating GUID Partition Table..."
    parted /dev/$SystemDisk mklabel gpt
    Write-Host "Creating EFI partition..."
    parted /dev/$SystemDisk mkpart EFI fat32 1 250
    Write-Host "Creating System partition..."
    parted "/dev/$SystemDisk mkpart Arch` Linux ext4 250 -1s"
}

Show-Menu
