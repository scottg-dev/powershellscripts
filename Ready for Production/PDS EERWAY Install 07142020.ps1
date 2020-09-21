# Script Name: PDS EERWY Install
# Description: This copies files down from the project drive and sets up the environment for EE Rway.
# Script Version: 1.0.0
# Created: 07/14/3030 SMG

# Script Arguments: $EdeAppsNetDir, $AppGroupAbbr,$AppsetraFileStore,$ProjectDriveLetter,$projstdpath,$projGEDir                                                                                                                               

# Clear the error variable.
$error.clear()

param(
  [string]$EdeAppsNetDir,
  [string]$AppGroupAbbr,
  [string]$AppsetraFileStore,
  [string]$ProjectDriveLetter,
  [string]$projstdpath,
  [string]$projGEDir
)

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

#region TestVariables
#$EdeAppsNetDir = "b:\"
#$AppGroupAbbr = "EERWAYPDS1201"
#$AppsetraFileStore = "\\vanva01estst302\PSJBFiles-Staging"
#$ProjectDriveLetter = "S"
#$projstdpath = "3dstds"
#$projGEDir = "ge"
#endregion

#region LocalVariables

$PDSWorkingDir = 'c:\pdsworkdir\'
$delimiter = ";"
$colonbackslash = ":\"
$stringBackSlash = "\"
$stringApps = ':\Apps\'

#endregion

#region othervariablesnotsetbyappsetra

$DiscAbbr = [System.Environment]::GetEnvironmentVariable('DisciplineAbbr',[System.EnvironmentVariableTarget]::Machine)
$SubpDirname = [System.Environment]::GetEnvironmentVariable('SubpDirname',[System.EnvironmentVariableTarget]::Machine)
$projpath = $SubpDirname
$stringStds = 'Stds'
$projstdpath = "$projpath$stringStds"


WriteToLog $LogLevelInfo,"DiscAbbr = $DiscAbbr"
$ProjStdGEPath = "$ProjectDriveLetter$colonbackslash$projstdpath$stringBackSlash$projGEDir"
WriteToLog $LogLevelInfo,"ProjStdGEPath = $ProjStdGEPath" 
$ProjStdDiscPath = "$ProjectDriveLetter$colonbackslash$projstdpath$stringBackSlash$DiscAbbr"
WriteToLog $LogLevelInfo,"ProjStdDiscPath = $ProjStdDiscPath"

#endregion

$RboCpyOpts = @("/V" , "/IT" , "/R:3" , "/W:1") 
$RboLogOpts1 = @("/log+:C:\Temp\RoboCopySectionEERWAY.log")
$cmdArgsSection1 =@($RboCpyOpts + $RboLogOpts1)

if (!(Test-Path $RboCpyLog)) {
    New-Item -Path $RboCpyLog -Type "file" -Force 
}

#region xAxBxC
$XA = "$EdeAppsNetDir$stringBackSlash$AppGroupAbbr"
$XB = "$ProjectDriveLetter$colonbackslash$projstdpath$stringBackSlash$ProjStdGEPath$stringBackSlash$AppGroupPipingAbbr$stringBackSlash"
$XC = "$ProjectDriveLetter$colonbackslash$projstdpath$stringBackSlash$DiscAbbr$stringBackSlash$AppGroupPipingAbbr"
$filepds = "pds.cmd"

$source = @($XA,$XB,$XC)
foreach($dir in $source)
{
Try
{
RoboCopy $dir $PDSWorkingDir $filepds $cmdArgsSection1
}
Catch
{
WriteToLog $LogLevelError "Error with RoboCopy in Section A (Copy pds.cmd)"
ExitWithCode 2
}
}
WriteToLog $LogLevelInfo "Finished with RoboCopy in Section A (Copy pds.cmd)"
#endregion

#region x1x2x3
$X1 = "$EdeAppsNetDir$AppGroupAbbr$stringBackSlash"
$X2 = "$ProjStdGEPath$stringBackSlash$AppGroupAbbr$stringBackSlash"
$X3 = "$ProjStdDiscPath$stringBackSlash$AppGroupAbbr$stringBackSlash"
$fileerwy = "ee.cfg"
$source = @($X4,$X5,$X6)
foreach($dir in $source)
{
Try
{
RoboCopy $dir $PDSWorkingDir $fileerwy $cmdArgsSection1
}
Catch
{
WriteToLog $LogLevelError "Error with RoboCopy in Section 1 (ee.cfg)"
ExitWithCode 2
}
}
WriteToLog $LogLevelInfo "Finished with RoboCopy in Section 1 (ee.cfg)"
#endregion

#region x4x5x6
$X4 = "$EdeAppsNetDir$AppGroupAbbr$stringBackSlash"
$X5 = "$ProjStdGEPath$stringBackSlash$AppGroupAbbr$stringBackSlash"
$X6 = "$ProjStdDiscPath$stringBackSlash$AppGroupAbbr$stringBackSlash"
$fileeepasswd = "eepasswd"

$source = @($X4,$X5,$X6)
foreach($dir in $source)
{
Try
{
RoboCopy $dir $PDSWorkingDir $fileeepasswd $cmdArgsSection1
}
Catch
{
WriteToLog $LogLevelError "Error with RoboCopy in Section 2 (eepasswd)"
ExitWithCode 2
}
}
WriteToLog $LogLevelInfo "Finished with RoboCopy in Section 2 (eepasswd)"
#endregion
ExitWithCode 0