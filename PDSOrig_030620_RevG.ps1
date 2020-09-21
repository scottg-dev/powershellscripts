# ScriptName: PDS Install
# Script Version: 1.0.0
param(
  [string]$EdeAppsNetDir,
  [string]$ProjectDriveLetter,
  [string]$projstdpath,
  [string]$projpath,
  [string]$AppGroupAbbr,
  [string]$AppAbbr,
  [string]$AppVersion,
  [string]$projGEDir,
  [string]$AppsetraFileStore,
  [string]$ProjectDrive
)
# Set the log variables.
$LogLevelInfo = "Info"
$LogLevelError = "Error"
$LogLevelDebug = "Debug"

$WorkDir = 'c:\pdsworkdir'
if(!(Test-Path $WorkDir))
{
New-Item -ItemType Directory -Force -Path $WorkDir
}

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




WriteToLog $LogLevelInfo, "Entering the script!"

#Remove after testing
#$EdeAppsNetDir = 'B'
#$AppGroupAbbr = 'edepds12'
#$AppVersion = '12.01'
#$PDSWorkingDir = 'c:\aworkdir\'
#$ProjServPath ='\\capas01nacifs01'
#$ProjStdGEPath = 'GE'
#$ProjectDriveLetter = 'S'
#$projstdpath = '3DStds'
#$projGEDir = 'ge'

#Variables

$delimiter = ";"
$colonbackslash = ":\"
$stringBackSlash = "\"
$stringApps = ':\Apps\'


$DiscAbbr = [System.Environment]::GetEnvironmentVariable('DisciplineAbbr',[System.EnvironmentVariableTarget]::Machine)
WriteToLog $LogLevelInfo,"DiscAbbr = $DiscAbbr"
$ProjStdGEPath = "$ProjectDriveLetter$colonbackslash$projstdpath$stringBackSlash$projGEDir"
WriteToLog $LogLevelInfo,"ProjStdGEPath = $ProjStdGEPath" 
$ProjStdDiscPath = "$ProjectDriveLetter$colonbackslash$projstdpath$stringBackSlash$DiscAbbr"
WriteToLog $LogLevelInfo,"ProjStdDiscPath = $ProjStdDiscPath"



$key = 'HKLM:\SOFTWARE\Wow6432Node\Intergraph\PD_SHELL\' + $AppVersion
if (!(Test-Path $key))
{
WriteToLog $LogLevelError,"The PDS Path is not populated in the Registry!"
#Exit 2
}

#Find the PDS Shell Path
#C:\\WIN32APP\\INGR\\PDSHELL\
$RegName = 'PathName'
$PDSLoc = (Get-ItemProperty -Path HKLM:\SOFTWARE\WOW6432Node\Intergraph\PD_SHELL\$AppVersion -Name $RegName).$RegName

$resultsThree = 'The Pathname for PDS Shell Path = ' + $PDSLoc
WriteToLog $LogLevelInfo, $resultsThree

#Get the path to the RIS product directory
$ImagePath = 'ImagePath'
$y = Get-Item -Path HKLM:\SYSTEM\CurrentControlSet\Services\RIStcpsrService
$RISexe = $y.GetValue($ImagePath)
$RISdir = $RISexe.Substring(0,32)

$resultsFour = 'The RISexe = ' + $RISexe + ' and RISdir = ' + $RISdir + ' !'
WriteToLog $LogLevelInfo, $resultsFour

$BNetworkpath = $EdeAppsNetDir 
$BpathExists = Test-Path -Path $Networkpath

If (-not ($BpathExists)) {
(new-object -com WScript.Network).MapNetworkDrive("B:",$AppsetraFileStore)
WriteToLog $LogLevelInfo, "Had to map the B Drive!"
}

$SNetworkpath = "$ProjectDriveLetter$colonbackslash"
$SpathExists = Test-Path -Path $Networkpath
If (-not ($SpathExists)) {
(new-object -com WScript.Network).MapNetworkDrive("S:",$ProjectDrive)
WriteToLog $LogLevelInfo, "Had to map the S Drive!"
}

$cmdArgs =@("/XO","/log+:C:\Temp\RoboCopy.log")
$fileschemas = "schemas"
$X1 = "$EdeAppsNetDir$AppGroupAbbr"
$X2 = "$ProjStdGEPath$stringBackSlash$AppGroupAbbr"
$X3 = "$ProjStdDiscPath$stringBackSlash$AppGroupAbbr"

if (Test-Path $X1)
{
RoboCopy $X1 $RISdir $fileschemas $cmdArgs
}
if (Test-Path $X2)
{
RoboCopy $X2 $RISdir $fileschemas $cmdArgs
}
if (Test-Path $X3)
{
RoboCopy $X3 $RISdir $fileschemas $cmdArgs
}

$logresulta = 'Path = ' + $X1 + $delimiter + ' Destination = ' + $RISdir
$logresultb = 'Path = ' + $X2 + $delimiter + ' Destination = ' + $RISdir

WriteToLog $LogLevelInfo, ($logresulta + ',' + $logresultb)

$X4 = "$EdeAppsNetDir$AppGroupAbbr$stringBackSlash"
$X5 = "$ProjStdGEPath$stringBackSlash$AppGroupAbbr$stringBackSlash"
$X6 = "$ProjStdDiscPath$stringBackSlash$AppGroupAbbr$stringBackSlash"
$filepds = "pds.cmd"
if (Test-Path $X4)
{
RoboCopy $X4 $PDSWorkingDir $filepds $cmdArgs
#Copy-Item -Path $X4  -Destination  $EDEClientWorkDir
}
if (Test-Path $X5)
{
RoboCopy $X5 $PDSWorkingDir $filepds $cmdArgs
#Copy-Item -Path $X5  -Destination  $EDEClientWorkDir 
}
if (Test-Path $X6)
{
RoboCopy $X6 $PDSWorkingDir $filepds $cmdArgs
#Copy-Item -Path $X6  -Destination  $EDEClientWorkDir 
}

#Copy the pdsfont.rsc file from the Site, Project GE, or Project Discipline directory 
#to the workstation for use with PDS (optional).

#B:\Apps\edepds12\pdsfont.rsc
$X7 = "$EdeAppsNetDir$AppGroupAbbr"
#S:\3DStds\GE\edepds12\pdsfont.rsc
$X8 = "$ProjStdGEPath$stringBackSlash$AppGroupAbbr"
#Need to look at a discipline structure. I have never seen one
$X9 = "$ProjStdDiscPath$stringBackSlash$AppGroupAbbr"

#PDSLoc 
#C:\\WIN32APP\\INGR\\PDSHELL\

$d = "$PDSLoc\font"
$fontLogging = "$d\pdsfont.rsc"
WriteToLog $LogLevelInfo, $fontLogging
$cmdArgs =@("/XO","/log+:C:\Temp\RoboCopy.log")
$filepdsfont = 'pdsfont.rsc'

If (Test-Path $X7)
{
RoboCopy $X7 $d $filepdsfont $cmdArgs
$logresulte = 'Path = ' + $X7 + $delimiter+ ' Destination = ' + $d + '\pdsfont.rsc'
WriteToLog $LogLevelInfo, ($logresulte)
}
If (Test-Path $X8)
{
RoboCopy $X8 $d $filepdsfont $cmdArgs
$logresultf = 'Path = ' + $X8 + $delimiter+ ' Destination = ' + $d + '\pdsfont.rsc'
WriteToLog $LogLevelInfo, ($logresultf)
}
If (Test-Path $X9)
{
RoboCopy $X9 $d $filepdsfont $cmdArgs
$logresultg = 'Path = ' + $X8 + $delimiter+ ' Destination = ' + $d + '\pdsfont.rsc'
WriteToLog $LogLevelInfo, ($logresultg)
}
$markFile = 'font\pdsfont.rsc'
$markFileReadOnly = "$PDSLoc$markFile"

Set-ItemProperty -Path $markFileReadOnly -Name IsReadOnly -Value $True

WriteToLog $LogLevelInfo, "The pdsfont.rsc should be set to read only!"

$forms = "forms\"
$FormsPath = "$PDSLoc$forms"
$s = $FormsPath + 'upversion.fb'

if (Test-Path $s)
{
Copy-Item -Path $s -Destination 'C:\win32app\ingr\PDSHELL\forms\upversion.fb'
Rename-Item -Path $s -NewName upversionx.fb
$logresulth = 'Path = ' + $s + ', new name = upversionx.fb'
WriteToLog $LogLevelInfo, $logresulth
}

exit 0