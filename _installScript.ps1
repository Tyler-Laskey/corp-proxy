# Created by:   Tyler Laskey
# Created on:   2022-03-28
# Last updated: 2022-03-30
Clear-Host

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


## "global" variables
# replace {{EID}} with the event id
$QueryStr = '<QueryList><Query Id="0" Path="Cisco AnyConnect Secure Mobility Client"><Select Path="Cisco AnyConnect Secure Mobility Client">*[System[Provider[@Name="acvpnagent"] and EventID={{EID}}]]</Select></Query></QueryList>'
$settings = New-ScheduledTaskSettingsSet -Compatibility Vista -AllowStartIfOnBatteries
$class = Get-cimclass MSFT_TaskEventTrigger root/Microsoft/Windows/TaskScheduler
$TaskPath = "\WSL\"

# Check if task exists
$TaskName = "Update AnyConnect Adapter Interface Metric for WSL2"
try {
  Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction Stop
} catch {
  $principal = New-ScheduledTaskPrincipal -UserId $env:UserName -RunLevel Highest
  $action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-WindowStyle Hidden -NonInteractive -ExecutionPolicy Bypass -File %HOMEPATH%\wsl\scripts\setCiscoVpnMetric.ps1"
  
  $t1 = $class | New-CimInstance -ClientOnly
  $t1.Enabled = $true
  $t1.Subscription = $QueryStr.Replace("{{EID}}","2039")
  
  $t2 = $class | New-CimInstance -ClientOnly
  $t2.Enabled = $true
  $t2.Subscription =  $QueryStr.Replace("{{EID}}","2041")

  $trigger = @($t1, $t2)

  try {
    Register-ScheduledTask -Principal $principal -Setting $settings -Action $action -Trigger $trigger -TaskName $TaskName -TaskPath $TaskPath 
    Write-Host "Task created successfully: " + $TaskPath + $TaskName -ForegroundColor Green
  } catch {
    Write-Host "Task creation failed: " + $TaskPath + $TaskName -ForegroundColor Red -BackgroundColor Black
  }
  
}


$TaskName = "Update DNS in WSL2 Linux VM's"
try {
  Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction Stop
} catch {
  $principal = New-ScheduledTaskPrincipal -UserId $env:UserName
  $action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-WindowStyle Hidden -NonInteractive -ExecutionPolicy Bypass -File %HOMEPATH%\wsl\scripts\setDns.ps1"

  $t1 = $class | New-CimInstance -ClientOnly
  $t1.Enabled = $true
  $t1.Subscription = $QueryStr.Replace("{{EID}}", "2039")

  $t2 = $class | New-CimInstance -ClientOnly
  $t2.Enabled = $true
  $t2.Subscription = $QueryStr.Replace("{{EID}}", "2010")

  $t3 = $class | New-CimInstance -ClientOnly
  $t3.Enabled = $true
  $t3.Subscription = $QueryStr.Replace("{{EID}}", "2061")

  $t4 = $class | New-CimInstance -ClientOnly
  $t4.Enabled = $true
  $t4.Subscription = $QueryStr.Replace("{{EID}}", "2041")

  $trigger = @($t1,$t2,$t3,$t4)

  try {
    Register-ScheduledTask -Principal $principal -Setting $settings -Action $action -Trigger $trigger -TaskName $TaskName -TaskPath $TaskPath 
    Write-Host "Task created successfully: " + $TaskPath + $TaskName -ForegroundColor Green
  } catch {
    Write-Host "Task creation failed: " + $TaskPath + $TaskName -ForegroundColor Red -BackgroundColor Black
  }
}


$TaskName = "Enable HTTPS_PROXY for TELUS by vpn"
try {
  Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction Stop
} catch {
  $principal = New-ScheduledTaskPrincipal -UserId $env:UserName
  $action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-WindowStyle Hidden -NonInteractive -ExecutionPolicy Bypass -File %HOMEPATH%\wsl\scripts\enableHttpsProxy.ps1"

  $trigger = $class | New-CimInstance -ClientOnly
  $trigger.Enabled = $true
  $trigger.Subscription = $QueryStr.Replace("{{EID}}", "2039")

  try {
    Register-ScheduledTask -Principal $principal -Setting $settings -Action $action -Trigger $trigger -TaskName $TaskName -TaskPath $TaskPath 
    Write-Host "Task created successfully: " + $TaskPath + $TaskName -ForegroundColor Green
  } catch {
    Write-Host "Task creation failed: " + $TaskPath + $TaskName -ForegroundColor Red -BackgroundColor Black
  }
}


$TaskName = "Disable HTTPS_PROXY for TELUS by vpn"
try {
  Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction Stop
} catch {
  $principal = New-ScheduledTaskPrincipal -UserId $env:UserName
  $action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-WindowStyle Hidden -NonInteractive -ExecutionPolicy Bypass -File %HOMEPATH%\wsl\scripts\disableHttpsProxy.ps1"

  $trigger = $class | New-CimInstance -ClientOnly
  $trigger.Enabled = $true
  $trigger.Subscription = $QueryStr.Replace("{{EID}}", "2010")

  try {
    Register-ScheduledTask -Principal $principal -Setting $settings -Action $action -Trigger $trigger -TaskName $TaskName -TaskPath $TaskPath 
    Write-Host "Task created successfully: " + $TaskPath + $TaskName -ForegroundColor Green
  } catch {
    Write-Host "Task creation failed: " + $TaskPath + $TaskName -ForegroundColor Red -BackgroundColor Black
  }
}

Read-Host -Prompt "Press any key to complete..."