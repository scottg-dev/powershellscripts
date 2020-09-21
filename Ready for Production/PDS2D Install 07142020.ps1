# Script Name: PDS PDS2D Install
# Description: This copies files down from the project drive and sets up the environment for PDS2D.
# Script Version: 1.0.0
# Created: 07/14/2020 SMG

# Script Arguments: $EdeAppsNetDir,$AppGroupAbbr,$AppVersion,$ProjectDriveLetter,$projstdpath,$projGEDir
# Clear the error variable.
$error.clear()
param(
  [string]$EdeAppsNetDir,
  [string]$AppGroupAbbr,
  [string]$AppVersion,
  [string]$ProjectDriveLetter,
  [string]$projstdpath,
  [string]$projGEDir
)

##region testvariable
###Remove after testing
#$EdeAppsNetDir = 'B:\'
#$AppGroupAbbr = 'edepds12'
#$AppVersion = '07.00'
#$ProjectDriveLetter = 'S'
#$projstdpath = '3DStds'
#$projGEDir = 'ge'
##endregion

$cmdArgs =@("/XO","/log+:C:\Temp\RoboCopy.log")
$colonbackslash = ':\'
$stringBackSlash = '\'

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

$RegName = 'PathName'
$UstnExePath = (Get-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Bentley\Microstation\07.01 -Name $RegName).$RegName
$UstnPath = $UstnExePath.Substring(0,31)
$UstnDefCfg = $UstnExePath.Substring(0,11)
$stringHomePrefs = 'home\prefs\'
$stringDfltuserCfg = "dfltuser.cfg"
$UstnPrefsDir = "$UstnDefCfg$stringHomePrefs"
$S = "$UstnPrefsDir"

#C:\Bentley\Home\prefs
#$UstnPath = [System.Environment]::SetEnvironmentVariable('MS', $UstnPath,[System.EnvironmentVariableTarget]::Machine)
#endregion

#region !Copy the default ucf file back the to the workstation.
#ProdPath=GetRegValue(HKEY_LOCAL_MACHINE, SOFTWARE\Intergraph\PDS2D\CurrentVersion\, PathName)
#ProdCfgPath=$ProdPath + cfg\
#x1 = $EdeAppsNetDir + $AppGroupAbbr + \
#CopyMFile($ProdCfgPath, pds2d.ucf, $x1)


$RboCpyOpts = @("/V" , "/IT" , "/R:3" , "/W:1") 
$RboLogOpts1 = @("/log+:C:\Temp\RoboCopySectionPDS.log")
$cmdArgsSection1 =@($RboCpyOpts + $RboLogOpts1)

$RegName = 'PathName'
$ProdPath = (Get-ItemProperty -Path HKLM:\SOFTWARE\WOW6432Node\Intergraph\PDS2D\CurrentVersion\ -Name $RegName).$RegName
$stringCfg = 'cfg\'
$ProdCfgPath="$ProdPath$stringCfg"
$X1 = "$EdeAppsNetDir$AppGroupAbbr$stringBackSlash"
$copyFileName =  'pds2d.ucf'

if (Test-Path $X1)
{
RoboCopy $X1 $ProdCfgPath $copyFileName $cmdArgsSection1
}

if (Test-Path $S)
{
RoboCopy $S $ProdCfgPath $stringDfltuserCfg $cmdArgsSection1
}

#endregion

#region !Copy the Site, Project GE, or Discipline Project schemas file to the workstation
$ImagePath = 'ImagePath'
$y = Get-Item -Path HKLM:\SYSTEM\CurrentControlSet\Services\RIStcpsrService
$RISexe = $y.GetValue($ImagePath)
$RISdir = $RISexe.Substring(0,32)

$fileschemas = "schemas"
$X1 = "$EdeAppsNetDir$AppGroupAbbr"
$X2 = "$ProjStdGEPath$stringBackSlash$AppGroupAbbr"
$X3 = "$ProjStdDiscPath$stringBackSlash$AppGroupAbbr"
$source = @($X1,$X2,$X3)
foreach($dir in $source)
{
Try
{
RoboCopy $dir $RISdir $fileschemas $cmdArgsSection1
$source = $null
}
Catch
{
WriteToLog $LogLevelError "Error with RoboCopy in Section 1 (Copy Schemas)"
ExitWithCode 2
}
}
#endregion

#Region !Copy the parameters file from the Site, Project GE, or Project Discipline directory to the workstation.
$stringNtParams = 'ntparams.dat'
$strRemoveItem = "$ProdCfgPath$stringNtParams"
if (Test-Path $strRemoveItem)
{
Remove-Item $strRemoveItem
}
$X4 = "$EdeAppsNetDir$AppGroupAbbr"
$X5 = "$ProjStdGEPath$stringBackSlash$AppGroupAbbr"
$X6 = "$ProjStdDiscPath$stringBackSlash$AppGroupAbbr"

$source = @($X4,$X5,$X6)
foreach($dir in $source)
{
Try
{
RoboCopy $dir $ProdCfgPath $stringNtParams $cmdArgsSection1
}
Catch
{
WriteToLog $LogLevelError "Error with RoboCopy in Section 1 (Copy Schemas)"
ExitWithCode 2
}
}
#endregion

#region !Create the projparm.bat file
$stringProjBat = 'projparm.bat'
$stringNewFile = "$ProdCfgPath$stringProjBat"
$stringNewLocation = $ProdCfgPath
$stringBinnt = "binnt"
if (Test-Path $stringNewFile)
{
Remove-Item $stringNewFile
}
if (-not (Test-Path $stringNewFile))
{
New-Item -path $stringNewLocation -Name $stringProjBat
}
$stringProjCrea = 'projcrea'
$stringSpace = ' '
$stringEnglish ='english'
$ComputerName = $env:computername
#C:\win32app\ingr\PDS2D\
$stringContent = "$ProdPath$stringBinnt$stringBackSlash$stringProjCrea$stringSpace$ProdPath$stringBinnt$stringBackSlash$stringSpace$ProdPath$stringSpace$stringEnglish$stringSpace$DiscAbbr$stringSpace$ComputerName"
Add-Content -Path $stringNewFile -Value $stringContent
#endregion

#Region pds2d0700.ecom

#!Note that some variables are defined in ecoms previously executed.

#!Copy the dfltuser.ucf file to the pds2d.ucf file so the EDE workspace is invoked.

$stringDfltuserLoc = "C:\win32app\ingr\PDS2D\cfg\"
$stringPds2ducfile = "C:\win32app\ingr\PDS2D\cfg\pds2d.ucf"
$stringDfltUsercfgfile = "C:\win32app\ingr\PDS2D\cfg\dfltuser.cfg"

if (Test-Path $stringPds2ducfile)
{
Rename-Item -Path $stringPds2ducfile -NewName pds2d.ucf.old
Copy-Item -Path $stringDfltUsercfgfile -Destination $stringDfltuserLoc
Rename-Item $stringDfltUsercfgfile -NewName pds2d.ucf
}

$stringFont = "font.rsc"
$stringBinPath = "$ProdPath$stringBinnt"
$stringBinPathFont = "$ProdPath$stringBinnt$stringBackslash$stringFont"
$markFile = 'font.rsc'
$markFileReadOnly = "$stringBinPath"

Set-ItemProperty -Path $markFileReadOnly -Name IsReadOnly -Value $True

$ProjUstnWkspDir = $AppGroupAbbr + '\wksp\'
$ProjWkspSymbDir    = $ProjUstnWkspDir + 'symb\'

#!Copy the resource files to the product dir so that the proper fonts show.
$X7 = "$ProjStdGEPath$stringBackslash$ProjWkspSymbDir"
$X8 = "$ProjStdDiscPath$stringBackslash$ProjWkspSymbDir"


$source = @($X7,$X8)
foreach($dir in $source)
{
Try
{
RoboCopy $dir $stringBinPath $stringFont $cmdArgsSection1
$source = $null
}
Catch
{
WriteToLog $LogLevelError "Error with RoboCopy in Section 1 (Copy Schemas)"
ExitWithCode 2
}
}
#endregion
ExitWithCode 0