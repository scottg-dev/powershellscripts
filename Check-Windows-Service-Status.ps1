# Script Name: Check Windows Service Status
# Description: Check a windows service is it running after an initial delay.
# Script Ver/sion: 1.0.0
# Created: 08/19/2020 SMG


# Script Arguments: $ServiceName,$TimedDelay

#$ServiceName = The name of the windows service. To find this, double click on the Windows Service  and look for the "service Name".
#$TimedDelay =  Int32, The number of Minutes you want to wait to check. 

param(
  [string]$ServiceName,
  [int32]$TimedDelay
)

#$TimedDelay = 3
#$ServiceName = "AGMService"
$TimeOut = New-TimeSpan -Minutes $TimedDelay
$messageIcon = "Information"

$error.clear()
#region logfile
# Set the log variables.
$LogLevelInfo = "Info"
$LogLevelError = "Error"
$LogLevelDebug = "Debug"
        
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
        $code = 5
    }

    exit $code
}
#endregion logfile

Start-Sleep -s $TimedDelay


$sw = [Diagnostics.Stopwatch]::StartNew()
While($sw.elapsed -lt $TimeOut)
{
$arrService = Get-Service -Name $ServiceName
if($arrService.Status -ne "Running")
{
$messageText = "$ServiceName service is not running!"
#Write-Host = "$ServiceName service is not running!"
}

if($arrService.Status -eq "Running")
{
#Write-Host = "$ServiceName service is running!"
$messageText = "$ServiceName service is running!"
return
}
WriteToLog $LogLevelInfo "Waiting 2 Seconds"
#Write-Host "Waiting 2 Seconds"
Start-Sleep -Seconds 2
}

# Load assembly
[void] [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic") 

$messageTitle = "Appsetra Message"

        $ret = [Microsoft.VisualBasic.Interaction]::MsgBox($messageText, "OKCancel,SystemModal,$messageIcon", $MessageTitle)

        if ($ret -eq "Ok")
        {
            WriteToLog $LogLevelInfo "User Response: Ok."
#            Write-Host "User Response: Ok."
            ExitWithCode 0;
        }
        else
        {
            WriteToLog $LogLevelInfo "User Response: Cancel."
#			Write-Host  "User Response: Cancel."
            ExitWithCode 2;
        }