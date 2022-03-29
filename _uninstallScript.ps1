# Created by:   Tyler Laskey
# Created on:   2022-03-28
# Last updated: 2022-03-28 
 
# Don't bother trying to see if the ScheduledTask exists, it will error if it does not. May as well delete and error if it doesnt exist
try {
  Unregister-ScheduledTask -TaskName "Update AnyConnect Adapter Interface Metric for WSL2" -TaskPath "\WSL\" -Confirm:$false
} catch {}

try {
  Unregister-ScheduledTask -TaskName "Update DNS in WSL2 Linux VM's" -TaskPath "\WSL\" -Confirm:$false
} catch {}

try {
  Unregister-ScheduledTask -TaskName "Enable HTTPS_PROXY for TELUS by vpn" -TaskPath "\WSL\" -Confirm:$false
} catch {}

try {
  Unregister-ScheduledTask -TaskName "Disable HTTPS_PROXY for TELUS by vpn" -TaskPath "\WSL\" -Confirm:$false
} catch {}











