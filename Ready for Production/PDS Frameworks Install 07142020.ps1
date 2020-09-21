# Script Name: PDS Frameworks Config
# Description: This copies files down from the project drive and sets up the environment for Frameworks.
# Script Version: 1.0.0
# Created: 07/14/2020 SMG

# Script Arguments: $EdeAppsNetDir, $AppGroupAbbr,$AppsetraFileStore

# Clear the error variable.
$error.clear()

param(
  [string]$EdeAppsNetDir,
  [string]$AppGroupAbbr,
  [string]$AppsetraFileStore
)

#$EdeAppsNetDir = 'B:\Apps'
#$AppGroupAbbr = 'edeframeworks12'
#$AppsetraFileStore = '\\VANVA01ESTST302\PSJBfiles-Staging'

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
#endregion

#Region Key

$key = 'HKLM:\SOFTWARE\Wow6432Node\Intergraph\FrameWorks Plus\CurrentVersion'
if (!(Test-Path $key))
{
WriteToLog $LogLevelError,"The Frameworks Path is not populated in the Registry!"
#Exit 2
}

$RegName = 'PathName'
$FrameworksExePath = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Intergraph\FrameWorks Plus\CurrentVersion' -Name $RegName).$RegName

#endregion 

#region localvariables
$backslash = '\'
$binslash = 'bin\'
$sapfiles = '\sap2000_ma_files\'


$FrameworksDir = [System.Environment]::SetEnvironmentVariable('FW_PRODUCT', $FrameworksExePath,[System.EnvironmentVariableTarget]::Machine)
$GetFrameworksDir = [System.Environment]::GetEnvironmentVariable('FW_PRODUCT',[System.EnvironmentVariableTarget]::Machine)

#endregion

#region CopyFiles
$RboCpyOpts = @("/V" , "/IT" , "/R:3" , "/W:1") 
$RboLogOpts1 = @("/log+:C:\Temp\RoboCopySectionFrameworks.log")
$cmdArgsSection1 =@($RboCpyOpts + $RboLogOpts1)
$RboCpyLog = "C:\Temp\RoboCopySectionProjArch.log"

if (!(Test-Path $RboCpyLog)) {
    New-Item -Path $RboCpyLog -Type "file" -Force 
}

$X1 = "$EdeAppsNetDir$backslash$AppGroupAbbr$sapfiles"
$FW_BIN = $GetFrameworksDir + $binslash
$fileframeworks = "*.*"
if (Test-Path $FW_BIN)
{
RoboCopy $X1 $FW_BIN $fileframeworks $cmdArgsSection1
WriteToLog $LogLevelInfo "Copied the files to the FW_BIN directory."
}
#endregion
ExitWithCode 0