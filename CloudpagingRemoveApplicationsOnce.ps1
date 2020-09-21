# Script Name: CloudpagingRemoveApplicationsOnce
# Description: Stops and removes all the applications from the Cloudpaging Player. Places an entry in the registry, so it only runs once.
# Script Version: 1.0.0

param([string]$scriptName)

# Define the application states applicable.
$appStateInvalid = 0
$appStateLaunching = 0x00000020
$appStateMounted = 0x00000010

# Define the application info state index to get state from appInfo object.
$appInfoStateIndex = 0

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

WriteToLog $LogLevelInfo "Executing script $scriptName"
WriteToLog $LogLevelInfo "Getting the list of applications in the Cloudpaging Player..."
WriteToLog $LogLevelInfo "Value of RunOnce registry entry = $scriptName"
WriteToLog $LogLevelInfo "Checking registry to see if the user has marked this message to run only once..."

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

$global:exitCode = 0

Function CreateRunOnceEntry()
{
    if (!(Test-Path $runOnceRegPath))
    {
        New-Item -Path $runOnceRegPath -Force | Out-Null
    }
    
    New-ItemProperty -Path $runOnceRegPath -Name $scriptName -PropertyType "String" -Force | Out-Null
}

# Start the Cloudpaging Player if its not running.
$processActive = Get-Process "JukeboxPlayer" -ErrorAction SilentlyContinue
if(!$processActive)
{
    WriteToLog $LogLevelInfo "Starting Cloudpaging Player..."
    $cloudPagingPlayerPath = & 'C:\Program Files\Numecent\Application Jukebox Player\JukeboxPlayer.exe'
    Start-Process -FilePath $cloudPagingPlayerPath -PassThru
    Start-Sleep -Seconds 5
}

# Create the COM Object.
$streamingApp = New-Object -ComObject StreamingCore.StreamingApplication
$streamingApp.Initialize($pid)

# Get the list of appGUIDs
$appMask = -1
$size = 0
$appIds = $streamingApp.GetApplicationIdList($appMask, [ref]$size)

# Remove applications from the player.
WriteToLog $LogLevelInfo "Removing applications from the Cloudpaging Player..."
for ($i=0; $i -lt $size; $i++) 
{
    $applicationId = $appIds[$i]
    $appInfoMaskState = 0x00000001
    $appInfo = $streamingApp.GetApplicationInfo($applicationId, $appInfoMaskState)
    $appState = $appInfo[$appInfoStateIndex]
    
    # Stop the application if it is running.
    if ($appState -ge $appStateLaunching) 
    {
        $streamingApp.StopApplication($applicationId)
    }

    # Remove the application from the Player.
    if ($appState -ne $appStateInvalid) 
    {
        $streamingApp.RemoveApplication($applicationId)
    }
}
CreateRunOnceEntry
WriteToLog $LogLevelInfo "Done executing script $scriptName"

exit 0