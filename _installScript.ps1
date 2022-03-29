# Created by:   Tyler Laskey
# Created on:   2022-03-28
# Last updated: 2022-03-28

# Move our scripts to a common location
$destPath = "$($env:homepath)\wsl\scripts"
if (-not (Test-Path $destPath -PathType Container)){
  New-Item -path $destPath -ItemType Directory
}
# $PSScriptRoot -- this is where the script is located
Copy-Item "$($PSScriptRoot)\disableHttpsProxy.ps1" "$($destPath)\disableHttpsProxy.ps1"
Copy-Item "$($PSScriptRoot)\enableHttpsProxy.ps1"  "$($destPath)\enableHttpsProxy.ps1"
Copy-Item "$($PSScriptRoot)\setCiscoVpnMetric.ps1" "$($destPath)\setCiscoVpnMetric.ps1"
Copy-Item "$($PSScriptRoot)\setDns.ps1" "$($destPath)\setDns.ps1"
Copy-Item "$($PSScriptRoot)\wsl_dns.py" "$($destPath)\wsl_dns.py"


$scheduleObject = New-Object -ComObject schedule.service
$scheduleObject.connect()
$rootFolder = $scheduleObject.GetFolder("\")
# Attempt to create the task scheduler folder to house our tasks
try {$rootFolder.CreateFolder("WSL")}
catch{}


$class = cimclass MSFT_TaskEventTrigger root/Microsoft/Windows/TaskScheduler

# Check if task exists
try {
  Get-ScheduledTask -TaskName "Update AnyConnect Adapter Interface Metric for WSL2" -TaskPath "\WSL\"
} catch {
  $principal = New-ScheduledTaskPrincipal -Id 'Author' -UserId 't856052' -RunLevel Highest
  $settings = New-ScheduledTaskSettingsSet -Compatibility Vista -AllowStartIfOnBatteries
  $action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-WindowStyle Hidden -NonInteractive -ExecutionPolicy Bypass -File %HOMEPATH%\wsl\scripts\setCiscoVpnMetric.ps1"
  
  $t1 = $class | New-CimInstance -ClientOnly
  $t1.Enabled = $true
  $t1.Subscription = '<QueryList><Query Id="0" Path="Cisco AnyConnect Secure Mobility Client"><Select Path="Cisco AnyConnect Secure Mobility Client">*[System[Provider[@Name=''acvpnagent''] and EventID=2039]]</Select></Query></QueryList>'
  $t2 = $class | New-CimInstance -ClientOnly
  $t2.Enabled = $true
  $t2.Subscription = '<QueryList><Query Id="0" Path="Cisco AnyConnect Secure Mobility Client"><Select Path="Cisco AnyConnect Secure Mobility Client">*[System[Provider[@Name=''acvpnagent''] and EventID=2041]]</Select></Query></QueryList>'
  $trigger = @($t1,$t2)

  $taskName = "TEST"
  $taskPath = "\WSL\"
  Register-ScheduledTask -Principal $principal -Setting $settings -Action $action -Trigger $trigger -TaskName $taskName -TaskPath $taskPath 
}

try {
  Get-ScheduledTask -TaskName "Update DNS in WSL2 Linux VM's" -TaskPath "\WSL\"
} catch {
  $principal = New-ScheduledTaskPrincipal -Id 'Author' -UserId 't856052'
  $settings = New-ScheduledTaskSettingsSet -Compatibility Vista -AllowStartIfOnBatteries
  $action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-WindowStyle Hidden -NonInteractive -ExecutionPolicy Bypass -File %HOMEPATH%\wsl\scripts\setDns.ps1"

  $t1 = $class | New-CimInstance -ClientOnly
  $t1.Enabled = $true
  $t1.Subscription = '<QueryList><Query Id="0" Path="Cisco AnyConnect Secure Mobility Client"><Select Path="Cisco AnyConnect Secure Mobility Client">*[System[Provider[@Name=''acvpnagent''] and EventID=2039]]</Select></Query></QueryList>'
  $t2 = $class | New-CimInstance -ClientOnly
  $t2.Enabled = $true
  $t2.Subscription = '<QueryList><Query Id="0" Path="Cisco AnyConnect Secure Mobility Client"><Select Path="Cisco AnyConnect Secure Mobility Client">*[System[Provider[@Name=''acvpnagent''] and EventID=2010]]</Select></Query></QueryList>'
  $t3 = $class | New-CimInstance -ClientOnly
  $t3.Enabled = $true
  $t3.Subscription = '<QueryList><Query Id="0" Path="Cisco AnyConnect Secure Mobility Client"><Select Path="Cisco AnyConnect Secure Mobility Client">*[System[Provider[@Name=''acvpnagent''] and EventID=2061]]</Select></Query></QueryList>'
  $t4 = $class | New-CimInstance -ClientOnly
  $t4.Enabled = $true
  $t4.Subscription = '<QueryList><Query Id="0" Path="Cisco AnyConnect Secure Mobility Client"><Select Path="Cisco AnyConnect Secure Mobility Client">*[System[Provider[@Name=''acvpnagent''] and EventID=2041]]</Select></Query></QueryList>'

  $trigger = @($t1,$t2,$t3,$4)

  $taskName = "Update DNS in WSL2 Linux VM's"
  $taskPath = "\WSL\"
  Register-ScheduledTask -Principal $principal -Setting $settings -Action $action -Trigger $trigger -TaskName $taskName -TaskPath $taskPath 
}

try {
  Get-ScheduledTask -TaskName "Enable HTTPS_PROXY for TELUS by vpn" -TaskPath "\WSL\"
} catch {
  $principal = New-ScheduledTaskPrincipal -Id 'Author' -UserId 't856052'
  $settings = New-ScheduledTaskSettingsSet -Compatibility Vista -AllowStartIfOnBatteries
  $action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-WindowStyle Hidden -NonInteractive -ExecutionPolicy Bypass -File %HOMEPATH%\wsl\scripts\enableHttpsProxy.ps1"

  $trigger = $class | New-CimInstance -ClientOnly
  $trigger.Enabled = $true
  $trigger.Subscription = '<QueryList><Query Id="0" Path="Cisco AnyConnect Secure Mobility Client"><Select Path="Cisco AnyConnect Secure Mobility Client">*[System[Provider[@Name=''acvpnagent''] and EventID=2039]]</Select></Query></QueryList>'

  $taskName = "Enable HTTPS_PROXY for TELUS by vpn"
  $taskPath = "\WSL\"
  Register-ScheduledTask -Principal $principal -Setting $settings -Action $action -Trigger $trigger -TaskName $taskName -TaskPath $taskPath 
}

try {
  Get-ScheduledTask -TaskName "Disable HTTPS_PROXY for TELUS by vpn" -TaskPath "\WSL\"
} catch {
  $principal = New-ScheduledTaskPrincipal -Id 'Author' -UserId 't856052'
  $settings = New-ScheduledTaskSettingsSet -Compatibility Vista -AllowStartIfOnBatteries
  $action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-WindowStyle Hidden -NonInteractive -ExecutionPolicy Bypass -File %HOMEPATH%\wsl\scripts\disableHttpsProxy.ps1"

  $trigger = $class | New-CimInstance -ClientOnly
  $trigger.Enabled = $true
  $trigger.Subscription = '<QueryList><Query Id="0" Path="Cisco AnyConnect Secure Mobility Client"><Select Path="Cisco AnyConnect Secure Mobility Client">*[System[Provider[@Name=''acvpnagent''] and EventID=2010]]</Select></Query></QueryList>'

  $taskName = "Disable HTTPS_PROXY for TELUS by vpn"
  $taskPath = "\WSL\"
  Register-ScheduledTask -Principal $principal -Setting $settings -Action $action -Trigger $trigger -TaskName $taskName -TaskPath $taskPath 
}
