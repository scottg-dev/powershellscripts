# ScriptName: PDS Install
# Script Version: 1.0.0
param(
  [string]$EdeAppsNetDir,
  [string]$AppGroupAbbr,
  [string]$AppVersion,
  [string]$ProjectDriveLetter,
  [string]$projstdpath,
  [string]$projpath,
  [string]$AppAbbr,
  [string]$projGEDir,
  [string]$AppsetraFileStore,
  [string]$ProjectDrive
)

##region Create working dir
#$WorkDir = 'c:\pdsworkdir'
#if(!(Test-Path $WorkDir))
#{
#New-Item -ItemType Directory -Force -Path $WorkDir
#}
##endregion

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

WriteToLog $LogLevelInfo, "Entering the script!"

#region testvariable
#Remove after testing
#$EdeAppsNetDir = 'B:\'
#$AppGroupAbbr = 'edepds12'
#$AppVersion = '12.01'
#$PDSWorkingDir = 'c:\pdsworkdir\'
#$ProjServPath ='\\capas01nacifs01'
#$ProjStdGEPath = 'GE'
#$ProjectDriveLetter = 'S'
#$projstdpath = '3DStds'
#$projGEDir = 'ge'
#$AppsetraFileStore = '\\VANVA01ESTST302\PSJBfiles-Staging'
#$projpath ='3d'
#endregion

#region LocalVariables
$PDSWorkingDir = 'c:\pdsworkdir\'
$delimiter = ";"
$colonbackslash = ":\"
$stringBackSlash = "\"
$stringApps = ':\Apps\'
$stringGE = "ge\"
#endregion

#region othervariablesnotsetbyappsetra

$DiscAbbr = [System.Environment]::GetEnvironmentVariable('DisciplineAbbr',[System.EnvironmentVariableTarget]::Machine)
$SubpDirname = [System.Environment]::GetEnvironmentVariable('SubpDirname',[System.EnvironmentVariableTarget]::Machine)

$projpath = $SubpDirname
$stringStds = 'Stds'
$projstdpath = "$projpath$stringStds"

WriteToLog $LogLevelInfo,"DiscAbbr = $DiscAbbr"
WriteToLog $LogLevelInfo,"SubpDirName = $projpath"
$ProjStdGEPath = "$ProjectDriveLetter$colonbackslash$projstdpath$stringBackSlash$projGEDir"
WriteToLog $LogLevelInfo,"ProjStdGEPath = $ProjStdGEPath" 
$ProjStdDiscPath = "$ProjectDriveLetter$colonbackslash$projstdpath$stringBackSlash$DiscAbbr"
WriteToLog $LogLevelInfo,"ProjStdDiscPath = $ProjStdDiscPath"

$projpath = $SubpDirname
$stringStds = 'Stds'
$projstdpath = "$projpath$stringStds"

#endregion

#Region Key

$key = 'HKLM:\SOFTWARE\Wow6432Node\Intergraph\PD_SHELL\' + $AppVersion
$stringKey = "The PDS Path key is the following - " + $key
WriteToLog $LogLevelInfo,$stringKey
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

##Get the path to the RIS product directory
#$ImagePath = 'ImagePath'
#$y = Get-Item -Path HKLM:\SYSTEM\CurrentControlSet\Services\RIStcpsrService
#$RISexe = $y.GetValue($ImagePath)
#$RISdir = $RISexe.Substring(0,32)
#$resultsFour = 'The RISexe = ' + $RISexe + ' and RISdir = ' + $RISdir + ' !'
#WriteToLog $LogLevelInfo, $resultsFour

#endregion

##Region x1x2x3
#
#$RboCpyOpts = @("/V" , "/IT" , "/R:3" , "/W:1") 
#$RboLogOpts1 = @("/log+:C:\Temp\RoboCopySectionPDS.log")
#$cmdArgsSection1 =@($RboCpyOpts + $RboLogOpts1)
#
##$cmdArgs =@("/XO","/log+:C:\Temp\RoboCopy.log")
#$fileschemas = "schemas"
#$X1 = "$EdeAppsNetDir$AppGroupAbbr"
#$X2 = "$ProjStdGEPath$stringBackSlash$AppGroupAbbr"
#$X3 = "$ProjStdDiscPath$stringBackSlash$AppGroupAbbr"
#$checkRoboCopyLog = "C:\Temp\RoboCopySectionPDS.log"
#$checkRoboCopyLogCreate = "C:\Temp\RoboCopySectionPDS.log"
#
#if (-not (Test-Path $checkRoboCopyLogCreate))
#{
#New-Item  $checkRoboCopyLogCreate
#}
#if (!(Test-Path $checkRoboCopyLog))
#{
#ExitWithCode = 2 	
#}
#
#$source = @($X1,$X2,$X3)
#foreach($dir in $source)
#{
#Try
#{
#RoboCopy $dir $RISdir $fileschemas $cmdArgsSection1
#$source = $null
#}
#Catch
#{
#WriteToLog $LogLevelError "Error with RoboCopy in Section 1 (Copy Schemas)"
#error 2
#}
#}
#WriteToLog $LogLevelInfo "Finished with RoboCopy in Section 1 (Copy Schemas)"
##endregion

#region x4x5x6
$X4 = "$EdeAppsNetDir$AppGroupAbbr"
$X5 = "$ProjStdGEPath$stringGE$AppGroupAbbr"
$X6 = "$ProjStdDiscPath$stringBackSlash$AppGroupAbbr"
$filepds = "pds.cmd"

$source = @($X4,$X5,$X6)
foreach($dir in $source)
{
Try
{
RoboCopy $dir $PDSWorkingDir $filepds $cmdArgsSection1
}
Catch
{
WriteToLog $LogLevelError "Error with RoboCopy in Section 2 (Copy pds.cmd)"
ExitWithCode 2
}
}
WriteToLog $LogLevelInfo "Finished with RoboCopy in Section 2 (Copy pds.cmd)"
#endregion

#region x7x8x9
#Copy the pdsfont.rsc file from the Site, Project GE, or Project Discipline directory 
#to the workstation for use with PDS (optional).

#B:\Apps\edepds12\pdsfont.rsc
$X7 = "$EdeAppsNetDir$AppGroupAbbr"
#S:\3DStds\GE\edepds12\pdsfont.rsc
$X8 = "$ProjStdGEPath$AppGroupAbbr"
#Need to look at a discipline structure. I have never seen one
$X9 = "$ProjStdDiscPath$stringBackSlash$AppGroupAbbr"

#PDSLoc 
#C:\\WIN32APP\\INGR\\PDSHELL\
$stringFontDir = "font"
$d = "$PDSLoc$stringFontDir"
$stringpdsfont = "pdsfont.rsc"
$fontLogging = "$d$stringBackSlash$stringpdsfont"
WriteToLog $LogLevelInfo, $fontLogging
$filepdsfont = 'pdsfont.rsc'

$source = @($X7,$X8,$X9)
foreach($dir in $source)
{
Try
{
RoboCopy $dir $d $filepdsfont $cmdArgsSection1
}
Catch
{
WriteToLog $LogLevelError "Error with RoboCopy in Section 3 (Copy pdsfont.rsc)"
ExitWithCode 2
}
}
WriteToLog $LogLevelInfo "Finished with RoboCopy in Section 3 (Copy pdsfont.rsc)"
#endregion

$markFile = 'font\pdsfont.rsc'
$markFileReadOnly = "$PDSLoc$markFile"

Set-ItemProperty -Path $markFileReadOnly -Name IsReadOnly -Value $True

WriteToLog $LogLevelInfo, "The pdsfont.rsc should be set to read only!"
#endregion

#region forms
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
#endregion
ExitWithCode 0