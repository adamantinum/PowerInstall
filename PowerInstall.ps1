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

$Choise = Read-Host "Please select an option

c.  Show License
q.  Quit"

if ($Choise -eq "c") {
    Get-Content -Path $ScriptDir/COPYING | Out-Host -Paging
} elseif ($Choise -eq "q") {
    Write-Host "Goodbye"
    exit
}

echo ciao
