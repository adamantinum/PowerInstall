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

$global:ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

function Show-Menu {
    $Choise = Read-Host "Installazion steps: `n s.  Disk partitioning and start installation `n c.  Show License `n q.  Quit `n
    Please select an option"

    Switch ($Choise)
    {
        "c" {
            Get-Content -Path $ScriptDir/COPYING | Out-Host -Paging
	    Show-Menu
        }
	"s" {
            Initialize-Disk
	    Start-Installation
	}
        "q" {
            Write-Host "`n Goodbye `n"
	    exit
        }
    }
}

function Initialize-Disk {
    $Check = pacman -Q | Select-String parted
    if (-not $Check) {
        pacman -Syu parted
    }
    $Check = pacman -Q | Select-String dosfstools
    if (-not $Check) {
        pacman -Syu dosfstools
    }
    Write-Host "Available disks: `n"
    lsblk -o NAME
    $global:SystemDisk = Read-Host "Please select a disk to install Arch Linux"

    $Alert = Read-Host "`n ATTENTION! The disk /dev/$SystemDisk will be erased! Continue? [Y/n]"

    if ($Alert -ne "Y") 
    {
        exit
    }

    Write-Host "Creating GUID Partition Table..."
    parted /dev/$SystemDisk mklabel gpt

    # Edit for NVME
    if ($global:SystemDisk | Select-String nvme) {
        $global:SystemDisk = $global:SystemDisk+"p"
    }

    Write-Host "Creating EFI partition..."
    parted /dev/$global:SystemDisk mkpart EFI fat32 1 250
    parted /dev/$global:SystemDisk set 1 esp on
    Write-Host "Creating System partition..."
    parted /dev/$global:SystemDisk mkpart ArchLinux ext4 250 100%		# In future dynamic selection will be implemented

    Write-Host "Formatting partitions..."
    mkfs.vfat -F32 /dev/$global:SystemDisk`1
    mkfs.ext4 /dev/$global:SystemDisk`2
}

function Start-Installation {

    # Checking if arch-install-scripts are installed
    $Check = pacman -Q | Select-String arch`-install`-scripts
    if (-not $Check) {
        pacman -Syu arch`-install`-scripts
    }
	
    # Umounting /mnt
    umount -R /mnt

    # Mountpoint creation
    New-Item -Path /mnt/system -ItemType Directory

    # Mounting system partition
    mount /dev/$global:SystemDisk`2 /mnt/system

    # Mounting EFI partition
    New-Item -Path /mnt/system/boot -ItemType Directory
    mount /dev/$global:SystemDisk`1 /mnt/system/boot

    # System bootstrapping
    pacstrap /mnt/system base linux linux`-firmware base`-devel gnome gnome`-extra

    # Writing configuration files
    genfstab -U /mnt/system | Out-File -Append /mnt/system/etc/fstab
	
    Copy-Item /etc/resolv.conf -Destination /mnt/system/etc

    Write-Host "Choose Administrator password"
    arch-chroot /mnt/system /bin/bash -c "passwd"

    $Username = Read-Host "Choose Username"
    arch-chroot /mnt/system /bin/bash -c "useradd -m $Username"

    Write-Host "Choose User password"
    arch-chroot /mnt/system /bin/bash -c "passwd $Username"

    Write-Host "Enabling Services..."
    arch-chroot /mnt/system /bin/bash -c "systemctl enable NetworkManager; systemctl enable bluetooth; systemctl enable gdm"

    Write-Host "Installing bootloader..."
    arch-chroot /mnt/system /bin/bash -c "bootctl install"
    
    Out-File -Path /mnt/system/boot/loader/loader.conf -InputObject "default   arch.conf
timeout   5
console-mode max
editor    yes"

    $UUID = lsblk /dev/$global:SystemDisk`2 -o UUID
    $UUID = $UUID[1]
    Out-File -Path /mnt/system/boot/loader/entries/arch.conf -InputObject "title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=`"UUID=$UUID`" rw"

    Write-Host "Cleaning..."
    umount -R /mnt/system
    Remove-Item -Path /mnt/system

    Write-host "Installation complete."
    $Choise = Read-Host "Press r to reboot, m to return to main menu"
    switch ($Choise)
    {
        "r" {
	    Write-Host "Reboot in 5 seconds"
	    Wait-Event -Timeout 5
	    
	    Write-Host "`n Thank you for using my script! `n"
	    systemctl reboot
	}
	"m" {
	    Show-Menu
	}
    }
}

Show-Menu
