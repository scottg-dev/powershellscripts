# Pass in "true" to avoid prompting for confirmation
$confirm=$args[0]

# Requires Administrator Rights
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You do not have Administrator rights to run this script.`nPlease re-run this script as an Administrator."
    return
}

# Prompt for confirmation to run script
If ($confirm -ne "true")
{
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    $OUTPUT= [System.Windows.Forms.MessageBox]::Show("This script will disable the following services and scheduled tasks:`n`nDefender real-time monitoring`nWindows search`nWindows updates`nWindows Store updates`nSystem restore`nSuper fetch`nChkdsk task`nDisk defrag task`nDisk cleanup tasks`n`nDo you wish to proceed?", "Confirmation" , 4) 
    if ($OUTPUT -eq "NO" ) 
    {
        return
    } 
}

function Disable-Task
{
    param([string]$TaskName,
          [string]$TaskFolder,
          [string]$ComputerName = "localhost"
          )
    
    $TaskScheduler = New-Object -ComObject Schedule.Service
    $TaskScheduler.Connect($ComputerName)
    $TaskRootFolder = $TaskScheduler.GetFolder($TaskFolder)
    $Task = $TaskRootFolder.GetTask($TaskName)
    If (-Not $?)
    {
        Write-Error "Task $TaskName not found on $ComputerName"
        return
    }
    $Task.Enabled = $False
    Write-Host "  $TaskFolder\$TaskName disabled"
}


# Identify the Operating System
$OSName = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName
$OSVersion = [Environment]::OSVersion.Version
Write-Host "Disabling components on" $OSName $OSVersion `n

# Disable System Restore
Write-Host "Disabling System Restore..."
Disable-ComputerRestore -Drive "C:\"

# Disable Microsoft Defender
Try
{
    $defenderOptions = Get-MpComputerStatus -ErrorAction Stop
    If (-NOT [string]::IsNullOrEmpty($defenderOptions))
    {
        Write-Host "Disabling Microsoft Defender..."
        Set-MpPreference -DisableRealtimeMonitoring $true
    }
}
Catch
{
    Write-Host "Microsoft Defender is NOT installed or Remotely Managed."
}

# Disable Windows Search
Write-Host "Disabling Windows Search..."
Set-Service WSearch -StartupType Disabled
Stop-Service WSearch

# Disable Windows Updates
Write-Host "Disabling Windows Updates..."
Set-Service wuauserv -StartupType Disabled
Stop-Service wuauserv

# Disable Superfetch service
Write-Host "Disabling Superfetch Service..."
Set-Service SysMain -StartupType Disabled
Stop-Service SysMain

# Disable AppX Deployment service
If ($OSVersion -ge (new-object 'Version' 6,2))
{
    Write-Host "Stopping AppX Deployment Service..."
    Stop-Service AppXSVC
}
Else 
{
    Write-Host "AppX Deployment Service NOT on legacy OSes."
}

# Disable Microsoft Store updates
If ($OSVersion -ge (new-object 'Version' 6,2))
{
    Write-Host "Disabling Windows Store App Updates..."
    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
    $Name = "AutoDownload"
    $value = "2"
    If (!(Test-Path $registryPath))
    {
    	New-Item -Path $registryPath -Force | Out-Null
    }
    New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null
}
Else 
{
    Write-Host "Windows Store App NOT on legacy OSes."
}

# Disable Scheduled task - Chkdsk, Disk Defrag, Disk Cleanup
Write-Host "Disabling Scheduled tasks:"
If ($OSVersion -ge (new-object 'Version' 6,2))
{
    Disable-ScheduledTask -TaskName "\Microsoft\Windows\Chkdsk\ProactiveScan"
    Disable-ScheduledTask -TaskName "\Microsoft\Windows\Defrag\ScheduledDefrag"
    Disable-ScheduledTask -TaskName "\Microsoft\Windows\DiskCleanup\SilentCleanup"
}
Else
{
    Disable-Task "ScheduledDefrag" "\Microsoft\Windows\Defrag"
    Disable-Task "MP Scheduled Scan" "\Microsoft\Windows Defender"
}