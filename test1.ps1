# Script Name: FileCreate
# Description: Creates a new file as per the path specified.
# If the file exists in path, it will be overwritten.
# Script Version: 1.0.1
# Last Modified: CO 6/20/2019 - Added timeout after file creation

# Script Arguments:
# filePath: Full path of the file to be created.

param([string]$filePath)

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
    Add-Content $logFilePath "$timeStamp $scriptName$delimiter $logLevel$delimiter $text" -ErrorAction Ignore
}

# Helper function to exit with error.
function ExitWithCode ($code)
{
    # Get Error Details.
    $errorCmdLet = $error[0].InvocationInfo.MyCommand.Name
    $errorLine = $error[0].InvocationInfo.ScriptLineNumber
    $lastError = $error[0].Exception.Message

    if ($lastError)
    {
        WriteToLog $LogLevelError "Cmdlet Details: $errorCmdLet"
        WriteToLog $LogLevelError "Line Number: $errorLine"
        WriteToLog $LogLevelError "Message: $lastError"
        $code = 3
    }

    exit $code
}


# Clear the error variable
$error.clear()

WriteToLog $LogLevelInfo "Executing script $scriptName"
WriteToLog $LogLevelInfo "Printing input params"
WriteToLog $LogLevelInfo "Value of filePath = $filePath"

# Check if the path variable is null.
if (!$filePath) 
{ 
    WriteToLog $LogLevelError "Cannot proceed without a valid path."
    ExitWithCode 2
}

# Create the new file at the path specified.
New-Item -Path $filePath -ItemType file -force

WriteToLog $LogLevelInfo "Waiting 5 seconds"
Start-Sleep -seconds 5

WriteToLog $LogLevelInfo "Done executing script $scriptName"

ExitWithCode 0