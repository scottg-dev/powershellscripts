# ScriptName: PDS Install
# Description:  Validates the logged-in user user and exits if the user is not in the accessControlUserList.
# Script Version: 1.0.0

# Script Arguments:

# Examples: Event Handler Parameters : $EdeAppsNetDir,$EDEClientWorkDir,$ProjectDriveLetter,$ProjStdGEPath,$ProjStdDiscPath,$AppGroupAbbr,$AppAbbr,$AppVersion

#Clear-Host
param(
  [string]$EdeAppsNetDir,
  [string]$EDEClientWorkDir,
  [string]$ProjectDriveLetter,
  [string]$ProjStdGEPath,
  [string]$ProjStdDiscPath,
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
$logFilePath = (Get-Item $scriptPath ).Directory.parent.parent.FullName + "\Log\DAPPDSPowerShell.log"
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

#Check to see if the B and S drives are mapped if not, create them
if (!(Test-Path -Path B:\))
{
New-PSDrive -Name "B" -PSProvider FileSystem -Root "\\vanva01estst302\PSJBfiles-Staging" -Persist
}
if (!(Test-Path -Path S:\))
{
New-PSDrive -Name "S" -PSProvider FileSystem -Root "\\capas01nacifs01\ESS" -Persist
}
$Networkdrives = Get-PSDrive
WriteToLog $LogLevelInfo, $Networkdrives

#
##Remove after testing
#$EdeAppsNetDir = 'B:\'
#$AppGroupAbbr = 'EDEPDS12'
#$AppVersion = '12.01'
#$EDEClientWorkDir = 'c:\aworkdir\'
#$ProjServPath ='\\capas01nacifs01'
#$ProjStdGEPath = '3DStds\GE'
#$ProjStdDiscPath ='NA\'
#$ProjectDriveLetter = 'S:'
#
$ProjGEPath = $ProjectDriveLetter + '\' + $ProjStdGEPath + '\' + $AppGroupAbbr
#Redefine EDEClientWorkDir to legacy value.
#
##Appsetra Variables used in the Event Handler
$AppsetraVariables = $EdeAppsNetDir,$EDEClientWorkDir,$ProjectDriveLetter,$ProjStdGEPath,$ProjStdDiscPath,$AppGroupAbbr,$AppAbbr,$AppVersion
WriteToLog $LogLevelInfo , $AppsetraVariables
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

#Create the PDS Command 
$file = $EDEClientWorkDir + 'pds.cmd'

New-Item $key -Force | Out-Null
New-ItemProperty $key -Name 'ControlFile' -Value $file | Out-Null

$resultsOne = 'The Control file was created at key = ' + $key + ' and file = ' + $file
WriteToLog $LogLevelInfo, $resultsOne

#Make sure there's a c:\temp, and that the env vars point to it.
$temp = 'C:\Temp'
if (!(Test-Path $EDEClientWorkDir))
{
New-Item -ItemType Directory -Force -Path $temp
$resultsTwo = 'The directory ' + $temp + ' was created!'
WriteToLog $LogLevelInfo, $resultsTwo
}

#Create the environment variable for TEMP and TMP
[System.Environment]::SetEnvironmentVariable('TEMP','C:\Temp',[System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable('TMP','C:\Temp',[System.EnvironmentVariableTarget]::Machine)
WriteToLog $LogLevelInfo, 'The Enviroment Variable TEMP and TMP was created!'

#Find the PDS Shell Path
$RegName = 'PathName'
$PDSLoc = Get-Item -Path HKLM:\SOFTWARE\WOW6432Node\Intergraph\PD_SHELL\$AppVersion
#$x = Get-Item -Path $PDSLoc 
$PDSShellPath = Get-RegistryValue -key $PDSLoc -name $RegName

$resultsThree = 'The Pathname for PDS Shell Path = ' + $PDSShellPath
WriteToLog $LogLevelInfo, $resultsThree

#Get the path to the RIS product directory
$ImagePath = 'ImagePath'
$y = Get-Item -Path HKLM:\SYSTEM\CurrentControlSet\Services\RIStcpsrService
$RISexe = $y.GetValue($ImagePath)
$RISdir = $RISexe.Substring(0,32)

$resultsFour = 'The RISexe = ' + $RISexe + ' and RISdir = ' + $RISdir + ' !'
WriteToLog $LogLevelInfo, $resultsFour

#Copy the Site, Project GE, or Discipline Project schemas file to the workstation
$X1 = $EdeAppsNetDir + 'APPS\' + $AppGroupAbbr + '\schemas'
$X2 = $ProjectDriveLetter + '\' + $ProjStdGEPath + '\' + $AppGroupAbbr + '\schemas'
#$X3 = $ProjectDriveLetter + '\' + $ProjStdDiscPath + '\' + $AppGroupAbbr + '\schemas'

Copy-Item -Path $X1 -Destination  $RISdir 
Copy-Item -Path $X2 -Destination  $RISdir 
#Copy-Item -Path $X3 -Destination  $RISdir 

$logresulta = 'Path = ' + $X1 + 'Destination = ' + $RISdir
$logresultb = 'Path = ' + $X2 + 'Destination = ' + $RISdir

WriteToLog $LogLevelInfo, ($logresulta + ',' + $logresultb)

#Copy the pds.cmd file from the Site, Project GE, or Project Discipline directory 
$X4 = $EdeAppsNetDir + 'APPS\' + $AppGroupAbbr +'\pds.cmd'
$X5 = $ProjectDriveLetter + '\' + $ProjStdGEPath + '\' + $AppGroupAbbr + '\pds.cmd'
#$X6 = $ProjectDriveLetter + '\' + $ProjStdDiscPath + '\' + $AppGroupAbbr + '\pds.cmd'

Copy-Item -Path $X4  -Destination  $EDEClientWorkDir 
Copy-Item -Path $X5  -Destination  $EDEClientWorkDir 
#Copy-Item -Path $X6  -Destination  $EDEClientWorkDir 

$logresultc = 'Path = ' + $X7 + 'Destination = ' + $EDEClientWorkDir
$logresultd = 'Path = ' + $X8 + 'Destination = ' + $EDEClientWorkDir

WriteToLog $LogLevelInfo, ($logresultc + ',' + $logresultd)

#Copy the pdsfont.rsc file from the Site, Project GE, or Project Discipline directory 
#to the workstation for use with PDS (optional).
$X7 = $EdeAppsNetDir + 'APPS\' + $AppGroupAbbr + '\pdsfont.rsc'
$X8 = $ProjectDriveLetter + '\' + $ProjStdGEPath + '\' + $AppGroupAbbr + '\pdsfont.rsc'
#$X9 = $ProjectDriveLetter + '\' + $ProjStdDiscPath + '\' + $AppGroupAbbr + '\pdsfont.rsc'
$d = $PDSShellPath + 'font\pdsfont.rsc'
WriteToLog $LogLevelInfo, $d

Set-ItemProperty -Path $d -Name IsReadOnly -Value $True
Copy-Item -Path $X7  -Destination  $d 
Copy-Item -Path $X8  -Destination  $d 
#Copy-Item -Path $X9  -Destination  $d 
$logresulte = 'Path = ' + $X7 + 'Destination = ' + $d
$logresultf = 'Path = ' + $X8 + 'Destination = ' + $d

WriteToLog $LogLevelInfo, ($logresulte + ',' + $logresultf)

$FormsPath = $PDSShellPath + 'forms\'
$s = $FormsPath + 'upversion.fb'

if (!(Test-Path $s))
{
Copy-Item -Path $s -Destination 'C:\win32app\ingr\PDSHELL\upversion.fb'
Rename-Item -Path $s -NewName upversionx.fb
}

$logresultg = 'Path = ' + $s + ',new name = upversionx.fb'


WriteToLog $LogLevelInfo, $logresultg

exit 0