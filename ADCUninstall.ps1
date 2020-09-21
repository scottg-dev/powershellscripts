# Script Name: ADCUninstall
# Description: Uninstalls traditional ADC installs
# Script Version: 1.0.0
# Last Modified: 9/14/2020 CO - Initial version

# Load assembly for message box
[void] [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic") 

# Set the log variables.
$LogLevelInfo = "Info"
$LogLevelError = "Error"
$LogLevelDebug = "Debug"

# Define the application states applicable.
$appStateInvalid = 0
$appStateLaunching = 0x00000020
$appStateMounted = 0x00000010

# Define the application info state index to get state from appInfo object.
$appInfoStateIndex = 0
        
# Create the log file if it does not exist.
$scriptPath = $MyInvocation.MyCommand.Definition
$logFilePath = (Get-Item $scriptPath ).Directory.parent.parent.FullName + "\Log\DAPPPowerShell.log"
if (!(Test-Path $logFilePath)) {
    New-Item -Path $logFilePath -Type "file" -Force 
}

# PowerShell log set up
$scriptName = $MyInvocation.MyCommand.Name
function WriteToLog ($logLevel, $text) {
    $timeStamp = "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
    $delimiter = ":"
    Add-Content $logFilePath "$timeStamp $scriptName$delimiter $logLevel$delimiter $text" -ErrorAction Ignore
}

# Helper function to exit with error.
function ExitWithCode ($code) {
    # Get Error Details.
    $errorCmdLet = $error[0].InvocationInfo.MyCommand.Name
    $errorLine = $error[0].InvocationInfo.ScriptLineNumber
    $lastError = $error[0].Exception.Message

    if ($lastError) {
        WriteToLog $LogLevelError "Cmdlet Details: $errorCmdLet"
        WriteToLog $LogLevelError "Line Number: $errorLine"
        WriteToLog $LogLevelError "Message: $lastError"
        $code = 6
    }

    exit $code
}

# Clear the error variable.
$error.Clear();

WriteToLog $LogLevelInfo "Executing script $scriptName"

# Stop player to avoid uninstall of virtualized ADC and AdSSO
WriteToLog $LogLevelInfo "Closing Cloudpaging Player..."
Stop-Process -name Jukebox* -Force
Stop-Process -name CoreHelper* -Force

# Search the uninstall keys and remove it by executing the uninstall exe along with silent parameters:
$items = Get-ItemProperty HKLM:\software\microsoft\windows\currentversion\Uninstall\*,HKLM:\software\wow6432node\microsoft\windows\currentversion\Uninstall\* | Where-Object {($_.DisplayName -like "Autodesk Desktop Connector") -and !($_.UninstallString -like "MsiExec.exe*")}

if ($items) {
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

    WriteToLog $LogLevelInfo "Uninstalling Autodesk Desktop Connector"
    foreach ($item in $items) {
        Start-Process -FilePath $item.BundleCachePath -ArgumentList "/uninstall /quiet" -Wait -Verb RunAs
    }
 
    # Display message saying ADC has been uninstalled
    WriteToLog $LogLevelInfo "Autodesk Desktop Connector has been uninstalled"
    $messageText = "Previous version of Autodesk Desktop Connector has been uninstalled"
    $messageIcon = "Exclamation"
    $messageTitle = "Autodesk Desktop Connector Uninstall"
    [Microsoft.VisualBasic.Interaction]::MsgBox($messageText, "OKOnly,SystemModal,$messageIcon", $messageTitle)    
}

# Restart Windows Explorer and Player
Stop-Process -ProcessName explorer -Force
Start-Process -FilePath "C:\Program Files\Numecent\Application Jukebox Player\JukeboxPlayer.exe" -PassThru
Start-Sleep -Seconds 5

WriteToLog $LogLevelInfo "Done executing script $scriptName"
ExitWithCode 0