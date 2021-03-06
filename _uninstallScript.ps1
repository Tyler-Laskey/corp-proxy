# Created by:   Tyler Laskey
# Created on:   2022-03-28
# Last updated: 2022-03-30
Clear-Host

If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
  # Relaunch as an elevated process:
  Start-Process powershell.exe "-File",('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
  exit
}
# Now running elevated and can continue.

$TaskPath = "\WSL\"

$TaskName = "Update AnyConnect Adapter Interface Metric for WSL2"
Write-Host "Removing Tasks:"
Write-Host ""
try {
  try {
    Write-Host "Testing '"$TaskPath$TaskName"'"
    Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction Stop
    Write-Host "Task '"$TaskPath$TaskName"' detected." -ForegroundColor Green
    Unregister-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -Confirm:$false
    Write-Host "Task '"$TaskPath$TaskName"' removed." -ForegroundColor Green
  } catch {
    Write-Host "Task '"$TaskPath$TaskName"' not detected."
  }
} catch {}

$TaskName = "Update DNS in WSL2 Linux VM's"
try {
  try {
    Write-Host "Testing '"$TaskPath$TaskName"'"
    Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction Stop
    Write-Host "Task '"$TaskPath$TaskName"' detected." -ForegroundColor Green
    Unregister-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -Confirm:$false
    Write-Host "Task '"$TaskPath$TaskName"' removed." -ForegroundColor Green
  } catch {
    Write-Host "Task '"$TaskPath$TaskName"' not detected."
  }
} catch {}

$TaskName = "Enable HTTPS_PROXY for TELUS by vpn"
try {
  try {
    Write-Host "Testing '"$TaskPath$TaskName"'"
    Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction Stop
    Write-Host "Task '"$TaskPath$TaskName"' detected." -ForegroundColor Green
    Unregister-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -Confirm:$false
    Write-Host "Task '"$TaskPath$TaskName"' removed." -ForegroundColor Green
  } catch {
    Write-Host "Task '"$TaskPath$TaskName"' not detected."
  }
} catch {}

$TaskName = "Disable HTTPS_PROXY for TELUS by vpn"
try {
  try {
    Write-Host "Testing '"$TaskPath$TaskName"'"
    Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction Stop
    Write-Host "Task '"$TaskPath$TaskName"' detected." -ForegroundColor Green
    Unregister-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -Confirm:$false
    Write-Host "Task '"$TaskPath$TaskName"' removed." -ForegroundColor Green
  } catch {
    Write-Host "Task '"$TaskPath$TaskName"' not detected."
  }
} catch {}

Read-Host -Prompt "Press any key to complete..."