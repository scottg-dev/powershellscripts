# Script Name: PDS ProjectArch Install
# Description: This copies files down from the project drive and sets up the environment for ProjectArch.
# Script Version: 1.0.0
# Created: 07/14/2020 SMG

# Script Arguments: $EdeAppsNetDir,$AppGroupAbbr,$AppsetraFileStore,$AppAbbr,$ProjAbbr,$SubpAbbr,$ProjectDriveLetter,$projstdpath,$projGEDir,$CmpyStdGEpath,$AppVersion,$SubpDirname
# Clear the error variable.
$error.clear()

param(
  [string]$EdeAppsNetDir,
  [string]$AppGroupAbbr,
  [string]$AppsetraFileStore,
  [string]$AppAbbr,
  [string]$ProjAbbr,
  [string]$SubpAbbr,
  [string]$ProjectDriveLetter,
  [string]$projstdpath,
  [string]$projGEDir,
  [string]$CmpyStdGEpath,
  [string]$AppVersion,
  [string]$SubpDirname
)


# #region localtestvariables
# $SubpDirname = '3d'
# $EdeAppsNetDir = 'B:\Apps'
# $AppGroupAbbr = 'edeparchplus12'
# $AppsetraFileStore = '\\VANVA01ESTST302\PSJBfiles-Staging'
# $AppAbbr = 'PARCH0704_12'
# $ProjectDriveLetter = 'S'
# $projstdpath = '3DStds'
# $projGEDir = 'ge'
# $CmpyDir = 'W'
# $CmpyStdGEdir = 'ge'
# $AppVersion = '07.01'
# $ProjAbbr = 'SMG-Proj1'
# $Subproject = '3D'
#
# 
# #endregion
 
 #region dynamic variables
 
 $DiscAbbr = [System.Environment]::GetEnvironmentVariable('DisciplineAbbr',[System.EnvironmentVariableTarget]::Machine)
 $SubpDirname = [System.Environment]::GetEnvironmentVariable('SubpDirname',[System.EnvironmentVariableTarget]::Machine)
 $projpath = $SubpDirname
 $stringStds = 'Stds'
 $projstdpath = "$projpath$stringStds"
 $CmpyStdGEPath= $CmpyDir + ":\" + $CmpyStdGEdir
 $CmpyStdDiscPath = $CmpyDir + ":\" + $DiscAbbr	
 
 #endregion
 
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

$stringbackslash = '\'
$workspaceusers = 'workspace\users\'
$homeprefs = 'home\prefs\'
$doublebackslash = '\\'
$colonbackslash = ':\'

#region Replace the license manager interface dll with one that works with SPLM10+
$D = 'C:\AECDesignWare\PArchPlus\Bin\'
$S = "$EdeAppsNetDir$stringbackslash$AppGroupAbbr$stringbackslash$AppAbbr$backslash"
#endregion

#region CopyFiles

$RboCpyOpts = @("/V" , "/IT" , "/R:3" , "/W:1") 
$RboLogOpts1 = @("/log+:C:\Temp\RoboCopySectionProjArch.log")
$cmdArgsSection1 =@($RboCpyOpts + $RboLogOpts1)
$RboCpyLog = "C:\Temp\RoboCopySectionProjArch.log"

if (!(Test-Path $RboCpyLog)) {
    New-Item -Path $RboCpyLog -Type "file" -Force 
}

$fileprojarch = "gen_lice.dll"
if (Test-Path $D)
{
RoboCopy $S $D $fileprojarch $cmdArgsSection1
WriteToLog $LogLevelInfo, "Copied the gen_lice.dll"
}
#endregion


#region Disciplines
$dict = [ordered]@{}
$dict.Add('Architectural','ar')
$dict.Add('Backgrounds','bk')
$dict.Add('Civil','ce')
$dict.Add('Electrical','ee')
$dict.Add('CAD General','ge')
$dict.Add('Instrumentation','in')
$dict.Add('Material Handling','mh')
$dict.Add('Mechanical Process','mp')
$dict.Add('Mechanical Utilities','mu')
$dict.Add('Piping','pd')
$dict.Add('Structural','se')
$dict.Add('Vessels','vs')
#endregion Disciplines

#region ! Copy the default parchplus.ucf file to the workstation, then append the project specific variables to it.

$RegName = 'PathName'
$UstnExePath = (Get-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Bentley\Microstation\$AppVersion -Name $RegName).$RegName
$UstnPath = $UstnExePath.Substring(0,11)

$UstnWKspUsersDir   = "$UstnPath$workspaceusers"
$UstnPrefsDir       = "$Ustnpath$homeprefs"
$fileparchplus = 'parchplus.ucf'

if (Test-Path $UstnWKspUsersDir)
{
RoboCopy $S $UstnWKspUsersDir $fileparchplus $cmdArgsSection1
WriteToLog $LogLevelInfo, "Copied the parchplus.ucf"
}

$ModifyFile = "$UstnWKspUsersDir$fileparchplus"

foreach ($key in $dict.values)
{
#ForAllDisc(MS_RFDIR > + $ProjPath  + $SubpLinkPath  + \ + $SubpDirname  + \ + $DiscDirname  + \\  # Discipline)
#$string = "MS_RFDIR >" + $ProjectDriveLetter + ":\" + $SubpLinkPath + "\" + $SubpDirname + "\" + $key + "\\"  +  "  # Discipline"
$stringOne = "MS_RFDIR >" + "$ProjectDriveLetter$colonbackslash$SubpDirname$stringbackslash$key$doublebackslash"  # Discipline"
Add-Content -Path $ModifyFile -Value $stringOne | Sort-Object
}
foreach ($key in $dict.values)
{
#ForAllDisc(MS_RFDIR > + $ProjStdPath +  $DiscDirname  + \\  # Discipline)
#$string = "MS_RFDIR >" + $ProjectDriveLetter + ":\" + $SubpLinkPath + "\" + $SubpDirname + "\" + $key + "\\"  +  "  # Discipline"
$stringTwo = "MS_RFDIR >" + "$ProjectDriveLetter$colonbackslash$ProjStdPath$stringbackslash$key"  # Discipline"
Add-Content -Path $ModifyFile -Value $stringTwo | Sort-Object
}
Add-Content -Path $ModifyFile -Value "PROJ=$ProjAbbr # Project abbreviation."
Add-Content -Path $ModifyFile -Value "SUBP=$SubpAbbr # Subproject abbreviation."
Add-Content -Path $ModifyFile -Value "DISC=$DiscAbbr # Discipline directory name."

foreach ($key in $dict.values)
{
$stringthree = $key.ToUpper() + "=" + $ProjectDriveLetter + ":\" + $SubpDirname + "\" + $key + "\\"  + "  # Discipline"
Add-Content -Path $ModifyFile -Value $stringthree | Sort-Object -Descending
}

foreach ($key in $dict.values)
{
$stringfour = "PS" + $key.ToUpper() + "=" + $ProjectDriveLetter +":\"+ $projstdpath +"\"+ $key + "\\" + "  # Discipline"
Add-Content -Path $ModifyFile -Value $stringfour | Sort-Object
}
$ProjStdGEPath = "$ProjectDriveLetter$colonbackslash$projstdpath$stringBackSlash$projGEDir"
$ProjStdDiscPath = "$ProjectDriveLetter$colonbackslash$projstdpath$stringBackSlash$DiscAbbr"

Add-Content -Path $ModifyFile -Value "PS=$ProjStdGEPath\\         # Project standard GE."
Add-Content -Path $ModifyFile -Value "PJ=$ProjStdDiscPath\\         # Project standard Disc."
Add-Content -Path $ModifyFile -Value "CSTD=$CmpyStdGEpath\\         # Company standards STD GE."
Add-Content -Path $ModifyFile -Value "DSTD=$CmpyStdDiscPath\\         # Company standards STD Disc."
#endregion

#region !Replace the default batch script template file with one from the project that contains a command to mount the project drive to the server. This is done to allow the batch processes to work on Windows machines.

$X3 = "$ProjStdGEPath$stringbackslash$AppGroupAbbr$stringbackslash$AppAbbr$stringbackslash"
$X4 = "$ProjStdDiscPath$stringbackslash$AppGroupAbbr$stringbackslash$AppAbbr$stringbackslash" 
$DestDir = 'C:\AECDesignWare\PArchPlus\Support\'
$fileTemplate = 'template.cmd'

$source = @($X3,$X4)
foreach($dir in $source)
{
Try
{
RoboCopy $dir $DestDir $fileTemplate $cmdArgsSection1
}
Catch
{
WriteToLog $LogLevelError "Error with RoboCopy in Section 2 (template.cmd)"
ExitWithCode 2
}
}
#endregion
ExitWithCode 0