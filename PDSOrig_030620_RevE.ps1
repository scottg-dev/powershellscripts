# ScriptName: PDS Install
# Description:  Validates the logged-in user user and exits if the user is not in the accessControlUserList.
# Script Version: 1.0.0

# Script Arguments:

# Examples: Event Handler Parameters : $EdeAppsNetDir,$EDEClientWorkDir,$ProjectDriveLetter,$ProjStdGEPath,$ProjStdDiscPath,$AppGroupAbbr,$AppAbbr,$AppVersion
param(
  [string]$EdeAppsNetDir,
  [string]$EDEClientWorkDir,
  [string]$ProjectDriveLetter,
  [string]$projstdpath,
  [string]$AppGroupAbbr,
  [string]$AppAbbr,
  [string]$AppVersion
)

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
#Function to get the registry values by providing the Key and Name
function Get-RegistryValue {
  param(
    $key,
    $name
  )  
  $key = $key -replace ':',''
  $regkey = "Registry::$key"
  Get-ItemProperty -Path $regkey -Name $name | 
    Select-Object -ExpandProperty $name
}


#if (!(Test-Path -Path B:\))
#{
#New-PSDrive -Name "B" -PSProvider FileSystem -Root "\\vanva01estst302\PSJBfiles-Staging" -Persist
#}
#if (!(Test-Path -Path S:\))
#{
#New-PSDrive -Name "S" -PSProvider FileSystem -Root "\\capas01nacifs01\ESS" -Persist
#}


$Networkdrives = Get-PSDrive
#
#Remove after testing
#$EdeAppsNetDir = 'B:\'
#$AppGroupAbbr = 'edepds12'
#$AppVersion = '12.01'
#$EDEClientWorkDir = 'c:\aworkdir\'
#$ProjServPath ='\\capas01nacifs01'
#$ProjStdGEPath = 'GE'
#$ProjStdDiscPath ='NA\'
#$ProjectDriveLetter = 'S:'
#
$DiscAbbr = [System.Environment]::GetEnvironmentVariable('DisciplineAbbr',[System.EnvironmentVariableTarget]::Machine)

$ProjStdGEPath = $ProjectDriveLetter + ":\" + $projstdpath + "\" + $projGEDir

$ProjStdDiscPath = $ProjectDriveLetter + ":\" + $projstdpath + "\" + $DiscAbbr

#$ProjGEPath = $ProjectDriveLetter + '\' + $ProjStdGEPath + '\' + $AppGroupAbbr
#Redefine EDEClientWorkDir to legacy value.
#
WriteToLog $LogLevelInfo , 'Creating the EDE Client Work Directory.'

if (!(Test-Path $EDEClientWorkDir))
{
New-Item -ItemType Directory -Force -Path $EDEClientWorkDir
}

$key = 'HKLM:\SOFTWARE\Wow6432Node\Intergraph\PD_SHELL\' + $AppVersion
if (!(Test-Path $key))
{
$LogLevelError,"The PDS Path is not populated in the Registry!"
Exit 2
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



$cmdArgs =@("/XO","/log+:C:\Temp\RoboCopy.log")
$file = "*"

#Copy the Site, Project GE, or Discipline Project schemas file to the workstation
$X1 = $EdeAppsNetDir + 'apps\' + $AppGroupAbbr + '\schemas'
$X2 = $ProjectDriveLetter + '\' + $ProjStdGEPath + '\' + $AppGroupAbbr + '\schemas'
$X3 = $ProjectDriveLetter + '\' + $ProjStdDiscPath + '\' + $AppGroupAbbr + '\schemas'

if (Test-Path $X1)
{
RoboCopy $X1 $RISdir $file $cmdArgs
#Copy-Item -Path $X1 -Destination  $RISdir 
}
if (Test-Path $X2)
{
RoboCopy $X2 $RISdir $file $cmdArgs
#Copy-Item -Path $X2 -Destination  $RISdir 
}
if (Test-Path $X3)
{
RoboCopy $X3 $RISdir $file $cmdArgs
#Copy-Item -Path $X3 -Destination  $RISdir 
}

$logresulta = 'Path = ' + $X1 + 'Destination = ' + $RISdir
$logresultb = 'Path = ' + $X2 + 'Destination = ' + $RISdir

WriteToLog $LogLevelInfo, ($logresulta + ',' + $logresultb)

#Copy the pds.cmd file from the Site, Project GE, or Project Discipline directory 
#$X4 = $EdeAppsNetDir + 'apps\' + $AppGroupAbbr +'\pds.cmd'
#$X5 = $ProjectDriveLetter + '\' + $ProjStdGEPath + '\' + $AppGroupAbbr + '\pds.cmd'
#$X6 = $ProjectDriveLetter + '\' + $ProjStdDiscPath + '\' + $AppGroupAbbr + '\pds.cmd'

$X4 = $EdeAppsNetDir + "apps\" + $AppGroupAbbr +"\"
$X5 = $ProjectDriveLetter + "\" + $ProjStdGEPath + "\" + $AppGroupAbbr + "\"
$X6 = $ProjectDriveLetter + "\" + $ProjStdDiscPath + '\' + $AppGroupAbbr + "\"
$file = "pds.cmd"
if (Test-Path $X4)
{
RoboCopy $X4 $RISdir $file $cmdArgs
#Copy-Item -Path $X4  -Destination  $EDEClientWorkDir
}
if (Test-Path $X5)
{
RoboCopy $X5 $RISdir $file $cmdArgs
#Copy-Item -Path $X5  -Destination  $EDEClientWorkDir 
}
if (Test-Path $X6)
{
RoboCopy $X6 $RISdir $file $cmdArgs
#Copy-Item -Path $X6  -Destination  $EDEClientWorkDir 
}

$logresultc = 'Path = ' + $X7 + 'Destination = ' + $EDEClientWorkDir
$logresultd = 'Path = ' + $X8 + 'Destination = ' + $EDEClientWorkDir

WriteToLog $LogLevelInfo, ($logresultc + ',' + $logresultd)

#Copy the pdsfont.rsc file from the Site, Project GE, or Project Discipline directory 
#to the workstation for use with PDS (optional).

#B:\Apps\edepds12\pdsfont.rsc
$X7 = $EdeAppsNetDir + 'apps\' + $AppGroupAbbr
#S:\3DStds\GE\edepds12\pdsfont.rsc
$X8 = $ProjectDriveLetter + '\' + $ProjStdGEPath + '\' + $AppGroupAbbr
#Need to look at a discipline structure. I have never seen one
$X9 = $ProjectDriveLetter + '\' + $ProjStdDiscPath + '\' + $AppGroupAbbr

#PDSLoc 
#C:\\WIN32APP\\INGR\\PDSHELL\

$d = $PDSLoc + 'font'
WriteToLog $LogLevelInfo, $d + '\pdsfont.rsc'
$cmdArgs =@("/XO","/log+:C:\Temp\RoboCopy.log")
$file = 'pdsfont.rsc'

If (Test-Path $X7)
{

RoboCopy $X7 $d $file $cmdArgs
$logresulte = 'Path = ' + $X7 + 'Destination = ' + $d + '\pdsfont.rsc'
WriteToLog $LogLevelInfo, ($logresulte)
}
If (Test-Path $X8)
{
RoboCopy $X8 $d $file $cmdArgs
$logresultf = 'Path = ' + $X8 + 'Destination = ' + $d + '\pdsfont.rsc'
WriteToLog $LogLevelInfo, ($logresultf)
}
If (Test-Path $X9)
{
RoboCopy $X9 $d $file $cmdArgs
$logresultg = 'Path = ' + $X8 + 'Destination = ' + $d + '\pdsfont.rsc'
WriteToLog $LogLevelInfo, ($logresultg)
}

$markfilereadonly = $PDSLoc + 'font\pdsfont.rsc'

Set-ItemProperty -Path $markfilereadonly -Name IsReadOnly -Value $True

WriteToLog $LogLevelInfo, "The pdsfont.rsc should be set to read only!"


$FormsPath = $PDSLoc + 'forms\'
$s = $FormsPath + 'upversion.fb'

if (Test-Path $s)
{
Copy-Item -Path $s -Destination 'C:\win32app\ingr\PDSHELL\forms\upversion.fb'
Rename-Item -Path $s -NewName upversionx.fb
$logresulth = 'Path = ' + $s + ', new name = upversionx.fb'
WriteToLog $LogLevelInfo, $logresulth
}

exit 0