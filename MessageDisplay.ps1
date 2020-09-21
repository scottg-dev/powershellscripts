# Script Name: MessageDisplay
# Description: Display the specified text in a message box.
# Script Version: 1.0.1

# Script Arguments:
# mode: Message display mode
# mode 1 = MessageDisplay with OK button.
# mode 2 = MessageDisplay with OK and Cancel buttons.

# messageText: Text to be displayed.
# messageIcon: Error, Warning or Information. If no input is provided, the default information icon will be used.

# Usage: .\MessageDisplay.ps1 1 "Test Message"
# Usage: .\MessageDisplay.ps1 2 "Test Message"
# Usage: .\MessageDisplay.ps1 1 "Test Message" "Warning"
# Usage: .\MessageDisplay.ps1 1 "Test Message" "Error"

param(
  [int]$mode,
  [string]$messageText,
  [string]$messageIcon
)

# Load assembly
[void] [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic") 

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

# Replace "\n" with "`r`n" for handling line-break.
$messageText = $messageText.Replace("\n", "`r`n")

WriteToLog $LogLevelInfo "Executing script $scriptName"
WriteToLog $LogLevelInfo "Printing input params"
WriteToLog $LogLevelInfo "Value of mode = $mode"
WriteToLog $LogLevelInfo "Value of messageText = $messageText"
WriteToLog $LogLevelInfo "Value of messageIcon = $messageIcon"

# Check if the text is empty.
if (!$messageText) { 
    WriteToLog $LogLevelError "Cannot proceed without a valid message text."
    exit 2
}

# Set the icon as per the input.
if ($messageIcon -eq "Error")
{
    $messageIcon = "Critical"
}
elseif ($messageIcon -eq "Warning")
{
    $messageIcon = "Exclamation"
}
else # if the input is Information or empty or invalid, set it to Information (default value)
{
    $messageIcon = "Information"
}

# Set the title of the message.
$messageTitle = "Appsetra Message"

switch ($mode) 
{ 
    1 # mode1 - MessageDisplay
    {
        $ret = [Microsoft.VisualBasic.Interaction]::MsgBox($messageText, "OKOnly,SystemModal,$messageIcon", $MessageTitle)
        
        if ($ret -eq "Ok")
        {
            WriteToLog $LogLevelInfo "User Response: Ok."
            exit 0;
        }

        break
    } 
    2 # mode1 - MessageDisplayCancel
    {
        $ret = [Microsoft.VisualBasic.Interaction]::MsgBox($messageText, "OKCancel,SystemModal,$messageIcon", $MessageTitle)

        if ($ret -eq "Ok")
        {
            WriteToLog $LogLevelInfo "User Response: Ok."
            exit 0;
        }
        else
        {
            WriteToLog $LogLevelInfo "User Response: Cancel."
            exit 2;
        }

        break
    } 
    default 
    {
        Write-Host "Invalid mode received."
        exit 2;
    }
}

WriteToLog $LogLevelInfo "Done executing script $scriptName"