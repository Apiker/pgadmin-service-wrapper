# Self-elevate to Administrator
if (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$baseDir = "C:\Program Files\PostgreSQL"

# Validate installation
if (-Not (Test-Path $baseDir)) {
    Write-Error "PostgreSQL must be installed already."
    Read-Host "Press Enter to exit..."
    exit
}

# Dynamically detect version (grabs the highest number if multiple exist)
$versionFolder = Get-ChildItem -Path $baseDir -Directory | Sort-Object Name -Descending | Select-Object -First 1

if (-Not $versionFolder) {
    Write-Error "PostgreSQL must be installed already."
    Read-Host "Press Enter to exit..."
    exit
}

$pgVersion = $versionFolder.Name
$targetDir = "$baseDir\$pgVersion\start"
$serviceName = "postgresql-x64-$pgVersion"
Set-Service -Name $serviceName -StartupType Manual
$pgAdminPath = "$baseDir\$pgVersion\pgAdmin 4\runtime\pgAdmin4.exe"

New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

$batPath = "$targetDir\Start PostgreSQL Server.bat"
$vbsPath = "$targetDir\launch.vbs"

# Write the Batch File
$batContent = @"
@echo off

start /b powershell -Command "Add-Type -AssemblyName System.Windows.Forms; `$n = New-Object System.Windows.Forms.NotifyIcon; `$n.Icon = [System.Drawing.SystemIcons]::Information; `$n.Visible = `$true; `$n.ShowBalloonTip(5000, 'PostgreSQL', 'Starting Server...', [System.Windows.Forms.ToolTipIcon]::Info); Start-Sleep -s 5; `$n.Visible = `$false; `$n.Dispose()"
net start $serviceName

start /b powershell -Command "Add-Type -AssemblyName System.Windows.Forms; `$n = New-Object System.Windows.Forms.NotifyIcon; `$n.Icon = [System.Drawing.SystemIcons]::Information; `$n.Visible = `$true; `$n.ShowBalloonTip(5000, 'PostgreSQL', 'Successfully started server.', [System.Windows.Forms.ToolTipIcon]::Info); Start-Sleep -s 5; `$n.Visible = `$false; `$n.Dispose()"
start "" "$pgAdminPath"

:WAITLOOP
timeout /t 3 /nobreak >nul
tasklist /FI "IMAGENAME eq pgAdmin4.exe" 2>NUL | find /I /N "pgAdmin4.exe">NUL
if "%ERRORLEVEL%"=="0" goto WAITLOOP

start /b powershell -Command "Add-Type -AssemblyName System.Windows.Forms; `$n = New-Object System.Windows.Forms.NotifyIcon; `$n.Icon = [System.Drawing.SystemIcons]::Information; `$n.Visible = `$true; `$n.ShowBalloonTip(5000, 'PostgreSQL', 'Closing Server...', [System.Windows.Forms.ToolTipIcon]::Info); Start-Sleep -s 5; `$n.Visible = `$false; `$n.Dispose()"
net stop $serviceName

start /b powershell -Command "Add-Type -AssemblyName System.Windows.Forms; `$n = New-Object System.Windows.Forms.NotifyIcon; `$n.Icon = [System.Drawing.SystemIcons]::Information; `$n.Visible = `$true; `$n.ShowBalloonTip(5000, 'PostgreSQL', 'Successfully stopped server.', [System.Windows.Forms.ToolTipIcon]::Info); Start-Sleep -s 5; `$n.Visible = `$false; `$n.Dispose()"
"@
Set-Content -Path $batPath -Value $batContent

# Write the VBS Wrapper
$vbsContent = @"
Set UAC = CreateObject("Shell.Application")
UAC.ShellExecute "$batPath", "", "", "runas", 0
"@
Set-Content -Path $vbsPath -Value $vbsContent

# Create the Start Menu Shortcut
$WshShell = New-Object -ComObject WScript.Shell
$ShortcutPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\PostgreSQL.lnk"
$Shortcut = $WshShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = "wscript.exe"
$Shortcut.Arguments = "`"$vbsPath`""
$Shortcut.IconLocation = "$pgAdminPath,0"
$Shortcut.Save()

# Reboot the system
Write-Host "Setup complete. Press Enter to reboot your computer and apply the Start Menu shortcut..."
Read-Host
Restart-Computer