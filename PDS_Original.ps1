
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
#Remove after testing
$EdeAppsNetDir = 'B:\'
$AppGroupAbbr = 'EDEPDS12'
$AppVersion = '12.01'
$EDEClientWorkDir = 'c:\aworkdir\'
$ProjServPath =''
$ProjStdGEPath = 'ESS'
$ProjStdDiscPath ='NA\'
$ProjectDriveLetter = 'S:'

$ProjStdGEPath = $ProjectDriveLetter  + '\' + $AppGroupAbbr + '\GE'
#Redefine EDEClientWorkDir to legacy value.

if (!(Test-Path $EDEClientWorkDir))
{
New-Item -ItemType Directory -Force -Path $EDEClientWorkDir
}

$key = 'HKLM:\SOFTWARE\Wow6432Node\Intergraph\PD_SHELL\' + $AppVersion

#Create the PDS Command 
$file = $EDEClientWorkDir + 'pds.cmd'

New-Item $key -Force | Out-Null
New-ItemProperty $key -Name 'ControlFile' -Value $file | Out-Null

#SOFTWARE\Wow6432Node\Intergraph\PD_SHELL\12.01
$x = "HKLM:\SOFTWARE\WOW6432Node\Intergraph\PD_SHELL\" + $AppVersion + '\'
$PDShellPath = (Get-ItemProperty -Path $x -Name 'PathName')


#Make sure there's a c:\temp, and that the env vars point to it.
$temp = 'C:\Temp'
if (!(Test-Path $dir))
{
New-Item -ItemType Director -Force -Path $temp
}

[System.Environment]::SetEnvironmentVariable('TEMP','C:\Temp',[System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable('TMP','C:\Temp',[System.EnvironmentVariableTarget]::Machine)


#Get the path to the RIS product directory
$ImagePath = 'ImagePath'
$y = Get-Item -Path HKLM:\SYSTEM\CurrentControlSet\Services\RIStcpsrService
$RISexe = $y.GetValue($ImagePath)
$RISdir = $RISexe.Substring(0,32)

#Copy the Site, Project GE, or Discipline Project schemas file to the workstation

$X1 = $EdeAppsNetDir + $AppGroupAbbr + '\' + 'schemas'
$X2 = $ProjStdGEPath + '\' + 'schemas'
$X3 = $ProjStdDiscPath + '\' + 'schemas'

Copy-Item -Path $X1 -Destination  $RISdir 
Copy-Item -Path $X2 -Destination  $EDEClientWorkDir 
Copy-Item -Path $X3 -Destination  $EDEClientWorkDir 

#Copy the pds.cmd file from the Site, Project GE, or Project Discipline directory 

$X4 = $EdeAppsNetDir + $AppGroupAbbr + '\' + 'pds.cmd'
$X5 = $ProjStdGEPath + '\' + 'pds.cmd'
$X6 = $ProjStdDiscPath + '\' + 'pds.cmd'

Copy-Item -Path $X4  -Destination  $RISdir 
Copy-Item -Path $X5  -Destination  $EDEClientWorkDir 
Copy-Item -Path $X6  -Destination  $EDEClientWorkDir 

#Copy the pdsfont.rsc file from the Site, Project GE, or Project Discipline directory 
#to the workstation for use with PDS (optional).

$X7 = $EdeAppsNetDir + $AppGroupAbbr + '\' + 'pdsfont.rsc'
$X8 = $ProjStdGEPath  + '\' + 'pdsfont.rsc'
$X9 = $ProjStdDiscPath  + '\' + 'pdsfont.rsc'


$d = ($PDShellPath + '\font\' + 'pdsfont.rsc')

Set-ItemProperty -Path $d -Name IsReadOnly -Value $True
Copy-Item -Path $X8  -Destination  $RISdir 
Copy-Item -Path $X8  -Destination  $EDEClientWorkDir 
Copy-Item -Path $X9  -Destination  $EDEClientWorkDir 
