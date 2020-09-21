# Script Name: HydraCAD 9.0 Setup
# Description: Load and Leave Install setup
# Script Version: 1.0.0

$SetupHASP = 'c:\temp\HASPUserSetup.exe'
$SetupHydraCAD = 'c:\temp\install\setup.exe'
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

#Check to see if HASP Setup is located in the C:\Temp
if (!(Test-Path $SetupHASP))
{
 WriteToLog $LogLevelError , "Cannot proceed without the application not in the C:\Temp Drive"
 exit 2
}
#Run the setup for HASP
start-process -FilePath $SetupHASP

#Check to see if the Hydratec Setup is located in the C:\Temp\Install Folder
if (!(Test-Path $SetupHydraCAD))
{
 WriteToLog $LogLevelError , "Cannot proceed without the HydraCAD install. It is not located in the C:\Temp\Install Drive"
 exit 2
}
# Run the setup for HydraCAD
start-process -FilePath $SetupHydraCAD