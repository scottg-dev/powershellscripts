# Script Name: HydraCAD 9.0 Configure Revit Addin Assistant
# Description: Load and Leave Install setup
# Script Version: 1.0.0
Add-Type -AssemblyName PresentationCore,PresentationFramework

param([string]$scriptName)

# Define the application info state index to get state from appInfo object.
$appInfoStateIndex = 0

# Define the application location that is going to be installed

$ConfigureHydraCAD = "C:\HES\Hydratec for Revit\Programs\HydratecRevitAddinAssistant.exe"

# Set the log variables.
$LogLevelInfo = "Info"
$LogLevelError = "Error"
$LogLevelDebug = "Debug"

# Create the log file if it does not exist.
$scriptPath = $MyInvocation.MyCommand.Definition

$logFilePath = (Get-Item $scriptPath ).Directory.parent.parent.FullName + "\Log\DAPPPowerShell.log"
if (!(Test-Path $logFilePath))
{
    New-Item -Path $logFilePath -Type "file" -Force 
}

# PowerShell log set up
$scriptName = $MyInvocation.MyCommand.Name
function WriteToLog ($logLevel, $text)
{
    $timeStamp = "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
    $delimiter = ":"
    Add-Content $logFilePath "$timeStamp $scriptName$delimiter $logLevel$delimiter $text"
}

$runOnceRegPath = "HKCU:\Software\DAPPClient\RunOnce"

if (Test-Path -Path $runOnceRegPath -ErrorAction Ignore)
{
    $eventHandlerExistsInRegistry = Get-ItemProperty -Path $runOnceRegPath -Name $scriptName
    if (!$eventHandlerExistsInRegistry)
    {
        WriteToLog $LogLevelInfo "The entry for $scriptName does not exist in RunOnce registry."
    }
    else
    {
        WriteToLog $LogLevelInfo "The entry for $scriptName exists in RunOnce registry. Skipping script execution..."
        exit 0
    }
}

Function CreateRunOnceEntry()
{
    if (!(Test-Path $runOnceRegPath))
    {
        New-Item -Path $runOnceRegPath -Force | Out-Null
    } 
    New-ItemProperty -Path $runOnceRegPath -Name $scriptName -PropertyType "String" -Force | Out-Null
}

#Check to see if HASP Setup is located in the C:\Temp
if (!(Test-Path $ConfigureHydraCAD))
{
 WriteToLog $LogLevelError , "Cannot proceed without the application not installed"
 exit 2
}
#Run the setup for HASP

start-process -FilePath $ConfigureHydraCAD -Verb runAs

CreateRunOnceEntry
WriteToLog $LogLevelInfo "Done executing script $scriptName"

$global:exitCode = 0


exit 0
