# Script Name: PDS HVAC Install
# Description: This copies files down from the project drive and sets up the environment for HVAC.
# Script Version: 1.0.0
# Created: 07/14/2020 SMG

# Script Arguments: $EdeAppsNetDir, $AppGroupAbbr,$AppVersion,$projstdpath,$ProjectDriveLetter,$projGEDir,$AppsetraFileStore,$ProjectDrive

# Clear the error variable.
$error.clear()

param(
  [string]$EdeAppsNetDir,
  [string]$AppGroupAbbr,
  [string]$AppVersion,
  [string]$projstdpath,
  [string]$ProjectDriveLetter,
  [string]$projGEDir,
  [string]$AppsetraFileStore,
  [string]$ProjectDrive
)

#$EdeAppsNetDir = 'B:\Apps'
#$AppGroupAbbr = 'edepehvac12'
#$AppVersion = '07.01'
#$projstdpath = '3DStds'
#$ProjectDriveLetter = 's'
#$projGEDir = 'ge'
#$AppsetraFileStore = '\\VANVA01ESTST302\PSJBfiles-Staging'
#$ProjectDrive = '\\capas01nacifs01\ESS'

$stringBackSlash = '\'
$doublebackslash = '\\'
$colonbackslash = ':\'

$DiscAbbr = [System.Environment]::GetEnvironmentVariable('DisciplineAbbr',[System.EnvironmentVariableTarget]::Machine)
$ProjStdGEPath = "$ProjectDriveLetter$colonbackslash$projstdpath$stringBackSlash$projGEDir"
$ProjStdDiscPath = "$ProjectDriveLetter$colonbackslash$projstdpath$stringBackSlash$DiscAbbr"

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

#region !Redefine EDEClientWorkDir to legacy value.
$WorkDir = 'c:\pdsworkdir'
if(!(Test-Path $WorkDir))
{
New-Item -ItemType Directory -Force -Path $WorkDir
}
#endregion

#region !Get the path to the RIS product directory.
$ImagePath = 'ImagePath'
$y = Get-Item -Path HKLM:\SYSTEM\CurrentControlSet\Services\RIStcpsrService
$RISexe = $y.GetValue($ImagePath)
$RISdir = $RISexe.Substring(0,32)
#endregion 

#region !Copy the Site, Project GE, or Discipline Project schemas file to the workstation
$RboCpyOpts = @("/V" , "/IT" , "/R:3" , "/W:1") 
$RboLogOpts1 = @("/log+:C:\Temp\RoboCopySectionHVAC.log")
$cmdArgsSection1 =@($RboCpyOpts + $RboLogOpts1)
$fileHVAC = "schemas"
$X1 = "$EdeAppsNetDir$AppGroupAbbr$stringBackSlash"
$X2 = "$ProjStdGEPath$stringBackSlash$AppGroupAbbr$stringBackSlash"
$X3 = "$ProjStdDiscPath$stringBackSlash$AppGroupAbbr$stringBackSlash"
$source = @($X1,$X2,$X3)
foreach($dir in $source)
{
Try
{
RoboCopy $dir $RISdir $fileHVAC $cmdArgsSection1
}
Catch
{
WriteToLog $LogLevelError "Error with RoboCopy in Section 1 (schemas)"
ExitWithCode 2
}
}
#endregion

#region !Copy the peh.cmd file from the Site, Project GE, or Project Discipline directory to the workstation.
$X4 = "$EdeAppsNetDir$AppGroupAbbr$stringBackSlash"
$X5 = "$ProjStdGEPath$stringBackSlash$AppGroupAbbr$stringBackSlash"
$X6 = "$ProjStdDiscPath$stringBackSlash$AppGroupAbbr$stringBackSlash"
$filePeh = "peh.cmd"

$source = @($X4,$X5,$X6)
foreach($dir in $source)
{
Try
{
RoboCopy $dir $WorkDir $filePeh $cmdArgsSection1
}
Catch
{
WriteToLog $LogLevelError "Error with RoboCopy in Section 1 (schemas)"
ExitWithCode 2
}
}
#endregion

#region ! Move the olecntr.ma file out of the way to resolve problem between it and PEHvac.
$RegName = 'PathName'
$UstnExePath = (Get-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Bentley\Microstation\$AppVersion -Name $RegName).$RegName
$UstnPath = $UstnExePath.Substring(0,32)

$olecntr = 'olecntr.ma'
$ustnvar = 'mdlsys\asneeded\'
$Mpath = "$UstnPath$ustnvar"
$f = "$Mpath$olecntr"

if (Test-Path $f)
{
Rename-Item -Path $f -NewName olecntr.save
}
#endregion
ExitWithCode 0