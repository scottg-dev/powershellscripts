

#region Params
param(
  [string]$ProjAbbr,
  [string]$EDEClientWorkDir,
  [string]$AppGroupAbbr,
  [string]$EdeAppsNetDir,
  [string]$LocationAbbr,
  #[string]$AppVersion,
  [string]$SubpDirname,
  [string]$projGEDir,
  [string]$CmpyStdGEdir,
  [string]$projPath,
  [string]$projstdpath,
  [string]$CmpyDir
)

#$ProjAbbr = "SMG-PROJ"
#$EDEClientWorkDir = "b:\"
#$AppGroupAbbr = "ustnsmg"
#$EdeAppsNetDir = "B:\Apps"
#$LocationAbbr = "CAPAS01"
$AppVersion = "07.01"
#$SubpDirname = "3d"
#$projGEDir = "ge"
#$CmpyStdGEdir = "ge"
#$projPath = "S"
#$projstdpath = "3dstds"
#$CmpyDir = "W"

$DiscAbbr = [System.Environment]::GetEnvironmentVariable('DisciplineAbbr',[System.EnvironmentVariableTarget]::Machine)

$stringColonBackslash = ":\"
$stringBackslash = "\"
$stringColon = ":"
$ProjStdGEPath = "$projPath$stringColonBackslash$projstdpath$stringBackslash$projGEDir"
$ProjStdDiscPath = "$projPath$stringColonBackslash$projstdpath$stringBackslash$DiscAbbr"
$CmpyStdGEPath= "$CmpyDir$stringColonBackslash$CmpyStdGEdir"
$CmpyStdDiscPath = "$CmpyDir$stringColonBackslash$DiscAbbr"
$projPathWColon = "$projPath$stringColon"

#endregion Params

#region Logging 

# Set the log variables.
$LogLevelInfo = "Info"
$LogLevelError = "Error"
$LogLevelDebug = "Debug"

# Create the log file if it does not exist.
$scriptPath = $MyInvocation.MyCommand.Definition
$logFilePath = (Get-Item $scriptPath ).Directory.parent.parent.FullName + "\Log\DAPPPowerShell.log"
#$logFilePath = "C:\Temp\DAPPPowerShell.log"
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

WriteToLog $LogLevelInfo "Variables that are being set"
WriteToLog $LogLevelInfo $ProjAbbr
WriteToLog $LogLevelInfo $EDEClientWorkDir
WriteToLog $LogLevelInfo $AppGroupAbbr
WriteToLog $LogLevelInfo $EdeAppsNetDir
WriteToLog $LogLevelInfo $LocationAbbr
  #[string]$AppVersion,
WriteToLog $LogLevelInfo $SubpDirname
WriteToLog $LogLevelInfo $projGEDir
WriteToLog $LogLevelInfo $CmpyStdGEdir
WriteToLog $LogLevelInfo $projPath
WriteToLog $LogLevelInfo $projstdpath,
WriteToLog $LogLevelInfo $CmpyDir

WriteToLog $LogLevelInfo $DiscAbbr 
WriteToLog $LogLevelInfo $AppVersion
WriteToLog $LogLevelInfo $ProjStdGEPath
WriteToLog $LogLevelInfo $ProjStdDiscPath
WriteToLog $LogLevelInfo $CmpyStdGEPath
WriteToLog $LogLevelInfo $CmpyStdDiscPath

WriteToLog $LogLevelInfo "End of Variables"

#endregion Logging

WriteToLog $LogLevelInfo "Entering region SetVariables"

#Region SetVariables

$ProjUstnWkspDir = $AppGroupAbbr + '\wksp\'
$ProjWkspCellDir    = $ProjUstnWkspDir + 'cell\'
$ProjWkspDataDir    = $ProjUstnWkspDir + 'data\'
$ProjWkspSeedDir    = $ProjUstnWkspDir + 'seed\'
$ProjWkspSymbDir    = $ProjUstnWkspDir + 'symb\'
$ProjWkspUcmDir     = $ProjUstnWkspDir + 'ucm\'
$ProjWkspMacroDir   = $ProjUstnWkspDir + 'macros\'
$ProjWkspPlotDrvDir = $ProjUstnWkspDir + 'plotdrv\'
$ProjWkspIntfDir    = $ProjUstnWkspDir + 'interfaces\' + $AppVersion + '\'
$ProjWkspFkeysDir   = $ProjWkspIntfDir + 'fkeys\'
$ProjWkspPenTableDir= $ProjUstnWkspDir + 'tables\pen\'

$EdeWkspNetDir        = $EdeAppsNetDir + "\" + $AppGroupAbbr + '\wksp\'
$EdeWkspIntfNetDir    = $EdeWkspNetDir + 'interfaces\' + $AppVersion + '\'
$EdeWkspFkeysNetDir   = $EdeWkspIntfNetDir + 'fkeys\'
$EdeWkspCellNetDir    = $EdeWkspNetDir + 'cell\'
$EdeWkspDataNetDir    = $EdeWkspNetDir + 'data\'
$EdeWkspSeedNetDir    = $EdeWkspNetDir + 'seed\'
$EdeWkspSymbNetDir    = $EdeWkspNetDir + 'symb\'
$EdeWkspUcmNetDir     = $EdeWkspNetDir + 'ucm\'
$EdeWkspMacroNetDir   = $EdeWkspNetDir + 'macros\'
$EdeWkspPlotDrvNetDir = $EdeWkspNetDir + 'plotdrv\'
$EdeWkspPenTableNetDir= $EdeWkspNetDir + 'tables\pen\'

$EdeSiteWkspNetDir         = $EdeAppsNetDir + "\" + $AppGroupAbbr + '\' + $AppGroupAbbr + '_' + $LocationAbbr + '\wksp\'
$EdeSiteWkspIntfNetDir     = $EdeSiteWkspNetDir + 'interfaces\'  + $AppVersion + '\'
$EdeSiteWkspFkeysNetDir    = $EdeSiteWkspIntfNetDir + 'fkeys\'
$EdeSiteWkspCellNetDir     = $EdeSiteWkspNetDir + 'cell\'
$EdeSiteWkspDataNetDir     = $EdeSiteWkspNetDir + 'data\'
$EdeSiteWkspSeedNetDir     = $EdeSiteWkspNetDir + 'seed\'
$EdeSiteWkspSymbNetDir     = $EdeSiteWkspNetDir + 'symb\'
$EdeSiteWkspUcmNetDir      = $EdeSiteWkspNetDir + 'ucm\'
$EdeSiteWkspMacroNetDir    = $EdeSiteWkspNetDir + 'macros\'
$EdeSiteWkspPlotDrvNetDir  = $EdeSiteWkspNetDir + 'plotdrv\'
$EdeSiteWkspPenTableNetDir = $EdeSiteWkspNetDir + 'tables\pen\'

#Uncomment the next three lines when you put into appsetra. It is hard coded to C:\Bentley now. 
$RegName = 'PathName'
$UstnExePath = (Get-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Bentley\Microstation\$AppVersion -Name $RegName).$RegName
$UstnPath = $UstnExePath.Substring(0,11)
#It should return this C:\Bentley
#Comment out after testing

#if(!(Test-Path "C:\Bentley"))
#{
#New-Item -ItemType Directory -Force -Path "C:\Bentley"
#}

$UstnConfigDir      = $UstnPath + 'program\microstation\config\'
$UstnPrefsDir       = $Ustnpath + 'home\prefs\'
$UstnConfigFile     = $UstnPath + 'home\prefs\dfltuser.cfg'
$UstnEdeCfgFile     = $UstnPath + 'workspace\users\ede.ucf'
$UstnAppCfgDir      = $UstnPath + 'program\microstation\config\appl\'
$UstnSystemCfgDir   = $UstnPath + 'program\microstation\config\system\'
$UstnSysPlotDrvDir  = $UstnPath + 'workspace\system\plotdrv\'
$UstnSysPenTableDir = $UstnPath + 'workspace\system\tables\pen\'
$UstnSysDataDir     = $UstnPath + 'workspace\system\data\'

$EdeWkspDir      = $UstnPath   + 'Workspace\projects\ede\'
$EdeWkspIntfDir  = $UstnPath   + 'Workspace\interfaces\microstation\ede\'
$EdeWkspFkeysDir = $UstnPath   + 'Workspace\interfaces\fkeys\'
$EdeWkspCellDir  = $EdeWkspDir + 'cell\'
$EdeWkspDataDir  = $EdeWkspDir + 'data\'
$EdeWkspSeedDir  = $EdeWkspDir + 'seed\'
$EdeWkspSymbDir  = $EdeWkspDir + 'symb\'
$EdeWkspUcmDir   = $EdeWkspDir + 'ucm\'
$EdeWkspMacroDir = $EdeWkspDir + 'macros\'

#endregion SetVariables

WriteToLog $LogLevelInfo "Finished region SetVariables"

WriteToLog $LogLevelInfo "Entering region CreateLegacyWorkDir"

#region CreateLegacyWorkDir

$TempDir = 'c:\temp'
if(!(Test-Path $TempDir))
{
New-Item -ItemType Directory -Force -Path $TempDir
}

#Legacy working directory
$WorkDir = 'c:\aworkdir'
if(!(Test-Path $WorkDir))
{
New-Item -ItemType Directory -Force -Path $WorkDir
}

#endregion CreateLegacyWorkDir

WriteToLog $LogLevelInfo "Finished region CreateLegacyWorkDir"

WriteToLog $LogLevelInfo "Entering region CreateDirs"

#region CreateDirs
#Create Directories
if(!(Test-Path $EdeWkspDir))
{
New-Item -ItemType Directory -Force -Path $EdeWkspDir
}

if(!(Test-Path $EdeWkspIntfDir))
{
New-Item -ItemType Directory -Force -Path $EdeWkspIntfDir
}

if(!(Test-Path $EdeWkspCellDir))
{
New-Item -ItemType Directory -Force -Path $EdeWkspCellDir
}

if(!(Test-Path $EdeWkspDataDir))
{
New-Item -ItemType Directory -Force -Path $EdeWkspDataDir
}

if(!(Test-Path $EdeWkspSeedDir))
{
New-Item -ItemType Directory -Force -Path $EdeWkspSeedDir
}

if(!(Test-Path $EdeWkspSymbDir))
{
New-Item -ItemType Directory -Force -Path $EdeWkspSymbDir
}

if(!(Test-Path $EdeWkspUcmDir))
{
New-Item -ItemType Directory -Force -Path $EdeWkspUcmDir
}

if(!(Test-Path $EdeWkspMacroDir))
{
New-Item -ItemType Directory -Force -Path $EdeWkspMacroDir
}

$edeout = $EdeWkspDir + "out"

if(!(Test-Path $edeout))
{
New-Item -ItemType Directory -Force -Path $edeout
}

#endregion CreateDirs

WriteToLog $LogLevelInfo "Finished region CreateDirs"

#region SiteConfig
#
##Rename site.cfg file to eliminate potential confilcts.
$configsystem = $UstnSystemCfgDir + 'site.cfg'
if(Test-Path $configsystem)
{
Rename-Item -Path $configsystem -NewName 'site.cfg.save'
}
else
{
WriteToLog $LogLevelInfo "site.cfg file was not found, skipped!"
}
#endregion SiteConfig


WriteToLog $LogLevelInfo "Entering region CopyFiles"

#Region CopyFiles
##Section 1
$files = "*"
$cmdArgs =@("/XO","/log+:C:\Temp\RoboCopy.log")
#EdeWkspNetDir = B:\ustnsmg\wksp
#$ProjUstnWkspDir = $AppGroupAbbr + '\wksp\'
#ustnsmg\wksp\
# ----Copy Cell Libraries
#$EdeWkspCellNetDir    = $EdeWkspNetDir + 'cell\'
#$ProjWkspCellDir    = $ProjUstnWkspDir + 'cell\'
$X1 = "$EdeWkspCellNetDir "                    # EDE System cell libraries"
$X2 = "$EdeSiteWkspCellNetDir"                 # Site cell libraries"
$X3 = "$CmpyStdGEPath$stringBackslash$ProjWkspCellDir"      # Company standard cell libraries"
$X4 = "$CmpyStdDiscPath$stringBackslash$ProjWkspCellDir"    # Company standard discipline's cell libraries"
$X5 = "$ProjStdGEPath$stringBackslash$ProjWkspCellDir"    # Project standard cell libraries"
$X6 = "$ProjStdDiscPath$stringBackslash$ProjWkspCellDir"     # Project standard discipline's cell libraries"

$source = @($X1,$X2,$X3,$X4,$X5,$X6)
#CopyMFile($EdeWkspCellDir, *.*, $X1,$X2,$X3,$X4,$X5,$X6)
foreach($dir in $source)
{
Try
{
RoboCopy $dir $EdeWkspCellDir $files $cmdArgs
#Copy-Item -Path $dir -Destination $EdeWkspCellDir -Recurse
$source = $null
}
Catch
{
WriteToLog $LogLevelError "Error with RoboCopy in Section 1 (Copy Cell Libraries)"
error 2
}
}
##Section 2d
## ----Copy Data Files
$X7 = "$EdeWkspDataNetDir"                       # EDE System data files
$X8 = "$EdeSiteWkspDataNetDir"                   # Site data files
$X9 = "$CmpyStdGEPath$stringBackslash$ProjWkspDataDir"      # Company standard data files
$X10 = "$CmpyStdDiscPath$stringBackslash$ProjWkspDataDir"      # Company standard discipline's data files
$X11 = "$ProjStdGEPath$stringBackslash$ProjWkspDataDir"      # Project standard data files
$X12 = "$ProjStdDiscPath$stringBackslash$ProjWkspDataDir"      # Project standard discipline's data files

$source = @($X7,$X8,$X9,$X10,$X11,$X12)
foreach($dir in $source)
{
Try
{
#RoboCopy $dir $EdeWkspDataDir $files $cmdArgs
#Copy-Item -Path $dir -Destination $EdeWkspCellDir -Recurse
$source = $null
}
Catch
{
WriteToLog $LogLevelError "Error with RoboCopy in Section 2 (Copy Data Files)"
error 2
}
}
##Section 3
## ----Copy Seed Files
$X13 = "$EdeWkspSeedNetDir"                       # EDE System Seed files
$X14 = "$EdeSiteWkspSeedNetDir"                   # Site Seed files
$X15 = "$CmpyStdGEPath$stringBackslash$ProjWkspSeedDir"      # Company standard Seed files
$X16 = "$CmpyStdDiscPath$stringBackslash$ProjWkspSeedDir"      # Company standard discipline's Seed files
$X17 = "$ProjStdGEPath$stringBackslash$ProjWkspSeedDir"      # Project standard Seed files
$X18 = "$ProjStdDiscPath$stringBackslash$ProjWkspSeedDir"      # Project standard discipline's Seed files

$source = @($X13,$X14,$X15,$X16,$X17,$X18)
foreach($dir in $source)
{
Try
{
RoboCopy $dir $EdeWkspSeedDir $files $cmdArgs
#Copy-Item -Path $dir -Destination $EdeWkspCellDir -Recurse
}
Catch
{
WriteToLog $LogLevelError "Error with RoboCopy in Section 3 (Copy Seed Files)"
error 2
}
}
##Section 4
## ----Copy Symbolgy Files
$X19 = "$EdeWkspSymbNetDir"                       # EDE System Symbology files
$X20 = "$EdeSiteWkspSymbNetDir"                   # Site symbology files
$X21 = "$CmpyStdGEPath$stringBackslash$ProjWkspSymbDir"      # Company standard symbology files.
$X22 = "$CmpyStdDiscPath$stringBackslash$ProjWkspSymbDir"      # Company standard discipline's symbology files.
$X23 = "$ProjStdGEPath$stringBackslash$ProjWkspSymbDir"      # Project standard symbology files.
$X24 = "$ProjStdDiscPath$stringBackslash$ProjWkspSymbDir"      # Project standard discipline's symbology files.

$itemstocopy = $EdeWkspSymbDir +'\*'
$source = @($X19,$X20,$X21,$X22,$X23,$X24)
foreach($dir in $source)
{
Try
{
RoboCopy $dir $EdeWkspSymbDir $files $cmdArgs
#Copy-Item -Path $dir -Destination $EdeWkspCellDir -Recurse
}
Catch
{
WriteToLog $LogLevelError "Error with RoboCopy in Section 4 (Copy Symbolgy Files)"
error 2
}
}
##Section 5
## ----Copy UCMs
$X25 = "$EdeWkspUcmNetDir"                       # EDE System UCM files.
$X26 = "$EdeSiteWkspUcmNetDir"                   # Site UCM files.
$X27 = "$CmpyStdGEPath$stringBackslash$ProjWkspUcmDir"      # Company standard UCM files.
$X28 = "$CmpyStdDiscPath$stringBackslash$ProjWkspUcmDir"      # Company standard discipline's UCM files.
$X29 = "$ProjStdGEPath$stringBackslash$ProjWkspUcmDir"      # Project standard UCM files.
$X30 = "$ProjStdDiscPath$stringBackslash$ProjWkspUcmDir"      # Project standard discipline's UCM files.

$source = @($X25,$X26,$X27,$X28,$X29,$X30)
foreach($dir in $source)
{
Try
{
RoboCopy $dir $EdeWkspUcmDir $files $cmdArgs
#Copy-Item -Path $dir -Destination $EdeWkspCellDir -Recurse
}
Catch
{
WriteToLog $LogLevelError "Error with RoboCopy in Section 5 (Copy UCMs)"
error 2
}
}
##Section 6
## ----Copy Macros
$X31 = "$EdeWkspMacroNetDir"                       # EDE System Macros.
$X32 = "$EdeSiteWkspMacroNetDir"                   # Site Macros.
$X33 = "$CmpyStdGEPath$stringBackslash$ProjWkspMacroDir"      # Company standard Macros.
$X34 = "$CmpyStdDiscPath$stringBackslash$ProjWkspMacroDir"      # Company standard discipline's Macros.
$X35 = "$ProjStdGEPath$stringBackslash$ProjWkspMacroDir"      # Project standard Macros.
$X36 = "$ProjStdDiscPath$stringBackslash$ProjWkspMacroDir"      # Project standard discipline's Macros.

$source = @($X31,$X32,$X33,$X34,$X35,$X36)
foreach($dir in $source)
{
Try
{
RoboCopy $dir $EdeWkspMacroDir $files $cmdArgs
#Copy-Item -Path $dir -Destination $EdeWkspCellDir -Recurse
}
Catch
{
WriteToLog $LogLevelError "Error with RoboCopy in Section 6 (Copy Macros)"
error 2
}
}

##Section 7
## ----Copy Plot driver files NOTE: These go to the MicroStation system directory, per MS convention.
$X37 = "$EdeWkspPlotDrvNetDir"                       # EDE System drivers.
$X38 = "$EdeSiteWkspPlotDrvNetDir"                   # Site drivers.
$X39 = "$CmpyStdGEPath$stringBackslash$ProjWkspPlotDrvDir"      # Company standard drivers.
$X40 = "$CmpyStdDiscPath$stringBackslash$ProjWkspPlotDrvDir"      # Company standard discipline drivers.
$X41 = "$ProjStdGEPath$stringBackslash$ProjWkspPlotDrvDir"      # Project standard drivers.
$X42 = "$ProjStdDiscPath$stringBackslash$ProjWkspPlotDrvDir"      # Project standard discipline drivers.
#CopyMFile($UstnSysPlotDrvDir, *.*, $X1, $X2, $X3, $X4, $X5, $X6)

$source = @($X37,$X38,$X39,$X40,$X41,$X42)
foreach($dir in $source)
{
Try
{
RoboCopy $dir $UstnSysPlotDrvDir $files $cmdArgs
}
Catch
{
WriteToLog $LogLevelError "Error with RoboCopy in Section 7 (Copy Plot driver files)"
error 2
}
}

##Section 8
# ----Copy Pen Table files NOTE: These go to the MicroStation system directory, per MS convention.
#$EdeWkspNetDir        = $EdeAppsNetDir + "\" + $AppGroupAbbr + '\wksp\'
#EdeWkspPenTableNetDir= $EdeWkspNetDir + 'tables\pen\'
#$EdeSiteWkspNetDir         = $EdeAppsNetDir + "\" + $AppGroupAbbr + '\' + $AppGroupAbbr + '_' + $LocationAbbr + '\wksp\'
#$EdeSiteWkspPenTableNetDir = $EdeSiteWkspNetDir + 'tables\pen\'
$X43 = "$EdeWkspPenTableNetDir"                       # EDE System tables.
$X44 = "$EdeSiteWkspPenTableNetDir"                   # Site tables.
$X45 = "$CmpyStdGEPath$stringBackslash$ProjWkspPenTableDir"      # Company standard drivers.
$X46 = "$CmpyStdDiscPath$stringBackslash$ProjWkspPenTableDir"      # Company standard discipline tables.
$X47 = "$ProjStdGEPath$stringBackslash$ProjWkspPenTableDir"      # Project standard drivers.
$X48 = "$ProjStdDiscPath$stringBackslash$ProjWkspPenTableDir"      # Project standard discipline tables.
#CopyMFile($UstnSysPenTableDir, *.*, $X1, $X2, $X3, $X4, $X5, $X6)

$source = @($X43,$X44,$X45,$X46,$X47,$X48)
foreach($dir in $source)
{
Try
{
RoboCopy $dir $UstnSysPenTableDir $files $cmdArgs
}
Catch
{
WriteToLog $LogLevelError "Error with RoboCopy in Section 8 (Copy Pen Table files)"
error 2
}
}


##Section 9
## ----Copy the batch plotting spec file.
# Copy the default first. (See MS_BATCHPLOT_SPECS variable below.)
$X49 = "$UstnSysDataDir"                              # Default system file
$X50 = "$EdeWkspDataNetDir"                           # EDE System file.
$X51 = "$EdeSiteWkspDataNetDir"                       # Site file.
$X52 = "$CmpyStdGEPath$stringBackslash$ProjWkspDataDir"          # Company standard file.
$X53 = "$CmpyStdDiscPath$stringBackslash$ProjWkspDataDir"          # Company standard discipline file.
$X54 = "$ProjStdGEPath$stringBackslash$ProjWkspDataDir"          # Project standard file.
$X55 = "$ProjStdDiscPath$stringBackslash$ProjWkspDataDir"          # Project standard discipline file.

$source = @($X49,$X50,$X51,$X52,$X53,$X54,$X55)
foreach($dir in $source)
{
Try
{
RoboCopy $dir $EdeWkspDataDir "batchplt.spc" $cmdArgs
}
Catch
{
WriteToLog $LogLevelError "Error with RoboCopy in Section 9 (Copy the batch plotting spec file)"
error 2
}
}

##Section 10
## ----Copy User Interface Files
# Remove all interface files first, to prevent conflict.
Remove-Item $EdeWkspIntfDir -Include 'ustn.*'
$X56 = "$EdeWkspIntfNetDir"                     # EDE System user interface files.
$X57 = "$EdeSiteWkspIntfNetDir"                 # Site user interface files.
$X58 = "$CmpyStdDiscPath$stringBackslash$ProjWkspIntfDir"    # Company standard discipline's user interface files.
$X59 = "$ProjStdGEPath$stringBackslash$ProjWkspIntfDir"      # Project standard discipline's user interface files.
$X60 = "$ProjStdDiscPath$stringBackslash$ProjWkspIntfDir"  # Project standard user interface files.

$source = @($X56,$X57,$X58,$X59,$X60)
foreach($dir in $source)
{
Try
{
RoboCopy $dir $EdeWkspIntfDir $files $cmdArgs
}
Catch
{
WriteToLog $LogLevelError "Error with RoboCopy in Section 10 (Copy User Interface Files)"
error 2
}
}

##Section 11
## ----Copy function key menus
$X61 = "$EdeWkspFkeysNetDir"                    # EDE System function key menus.
$X62 = "$EdeSiteWkspFkeysNetDir"                # Site function key menus.
$X63 = "$CmpyStdDiscPath$stringBackslash$ProjWkspFkeysDir"   # Company standard discipline's function key menus.
$X64 = "$ProjStdDiscPath$stringBackslash$ProjWkspFkeysDir"   # Project standard function key menus.

$source = @($X61,$X62,$X63,$X64)
foreach($dir in $source)
{
Try
{
RoboCopy $dir $EdeWkspFkeysDir $files $cmdArgs
}
Catch
{
WriteToLog $LogLevelError "Error with RoboCopy in Section 11(Copy function key menus)"
error 2
}
}

#endregion CopyFiles

WriteToLog $LogLevelInfo "Finished region CopyFiles"

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
$dict.Add('Structural','st')
$dict.Add('Vessels','vs')


#endregion Disciplines

WriteToLog $LogLevelInfo "Entering region MicroStationVariables"

#Region MicroStationVariables

if (Test-Path $UstnEDECfgFile)
{
Remove-Item $UstnEDECfgFile
}

if(!(Test-Path $UstnEDECfgFile))
{
New-Item -ItemType "file" -Force -Path $UstnEDECfgFile
}

Add-Content -Path $UstnEDECfgFile -Value "_USTN_USERNAME    = ede"
Add-Content -Path $UstnEDECfgFile -Value "_USTN_USERDESCR   = EDE Workspace"
Add-Content -Path $UstnEDECfgFile -Value "_USTN_PROJECTNAME = ede"
Add-Content -Path $UstnEDECfgFile -Value "_USTN_PROJECTDESCR  = EDE Project"
Add-Content -Path $UstnEDECfgFile -Value "_USTN_USERINTNAME = ede"
                                         
Add-Content -Path $UstnEDECfgFile -Value "EDECLIENTDIR =$EDEClientWorkDir"
 #$string = "MS_RFDIR >" + $projPath + ":\" + $ProjStdPath +"\" + $key +"\\  # Discipline"                                        
Add-Content -Path $UstnEDECfgFile -Value "MS_DEF            =$projPathWColon\$SubpDirname\$DiscAbbr\\                        # Default dirs."
Add-Content -Path $UstnEDECfgFile -Value "MS_BACKUP         =$WorkDir\                        # Backup file location"
$edestring1 = @'
MS_APP            = $(_USTN_PROJECT)ede/ucm/               # UCM path for TSK.
MS_APPMEN         = $(_USTN_PROJECT)ede/data/              # Application menus.
MS_CELL           = $(_USTN_PROJECT)ede/cell/              # Cell libraries.
MS_CELLLIST       = $(_USTN_PROJECT)ede/cell/*.cel         # Cell libraries.
MS_CELLSELECTORDIR= $(_USTN_PROJECT)ede/cell/              # Cell selector file location.
MS_FKEYMNU        = $(_USTN_PROJECT)ede/data/funckey.mnu   # Funtion key menu.
MS_GLOSSARY       = $(_USTN_PROJECT)ede/data/*.gls         # Glossary files.
MS_LEVELNAMES     = $(_USTN_PROJECT)ede/data/              # Level name files.
MS_MACRO          < $(_USTN_PROJECT)ede/macros/            # Macro files.
'@
Add-Content -Path $UstnEDECfgFile -Value $edestring1
Add-Content -Path $UstnEDECfgFile -Value "MS_PLTFILES       =$WorkDir\                        # Plot file (output)  location."
$edestring2 = @'
MS_BATCHPLT_SPECS = $(_USTN_PROJECT)ede/data/batchplt.spc  # Batch plotting specifications file
MS_RFDIR          =                                        # Ref file path. (undefined)
MS_SETTINGS       = $(_USTN_PROJECT)ede/data/styles.stg    # Settings file.
MS_SETTINGSDIR    = $(_USTN_PROJECT)ede/data/              # Settings resources.
MS_SEEDFILES      = $(_USTN_PROJECT)ede/seed/              # Seed files.
MS_SHEETSEED      = $(_USTN_PROJECT)ede/seed/transseed.dgn # Sheet seed file.
'@
Add-Content -Path $UstnEDECfgFile -Value $edestring2
Add-Content -Path $UstnEDECfgFile -Value 'MS_SCR            = $(temp)                                # Temp file location.'
$edestring3 = @'
#MS_SYMBRSRC   Defined in ede.ucf
MS_TMP            = $(temp)                                # Temp file location.
MS_TRANSSEED      = $(_USTN_PROJECT)ede/seed/transseed.dgn # DWG seed file.
MS_UCM            < $(_USTN_PROJECT)ede/ucm/               # UCM path.
MS_WORKSPACEOPTS  = 2                                      # Disallow selection of workspace.
# (0=allow 1=disabled, displayed 2=disabled, not displayed)
MS_SYMBRSRC       > $(_USTN_PROJECT)ede/symb/*.rsc         # Font resource files.
                                         
P_UCM             = $(_USTN_PROJECT)ede/ucm/                                # Parsons UCM path.
'@
Add-Content -Path $UstnEDECfgFile -Value $edestring3
#need to verify if the next line is correct. 
Add-Content -Path $UstnEDECfgFile -Value "JOB_CEL           =$ProjStdDiscPath\$DiscAbbr$ProjAbbr.cel    # Disc. Tmp cell lib."
Add-Content -Path $UstnEDECfgFile -Value "PROJ_CEL          =$EdeWkspCellDir$ProjAbbr.cel                   # Project cell lib."

 #region AppendingFile
 #1                                        
#ForAllDisc(MS_RFDIR > + $ProjPath  + $SubpLinkPath  + \ + $SubpDirname  + \ + $DiscDirname  + \\  # Discipline)"
foreach ($key in $dict.values)
{
#S:\\SWPF2D\pd
$string = "MS_RFDIR >" + $projPath + ":\" + $SubpLinkPath + "\" + $SubpDirname + "\" + $key + "\\"  +  "  # Discipline"
Add-Content -Path $UstnEDECfgFile -Value $string | Sort-Object
}
#2
#ForAllDisc(MS_RFDIR > + $ProjStdPath +  $DiscDirname  + \\  # Discipline)"
foreach ($key in $dict.values)
{
$string = "MS_RFDIR >" + $projPath + ":\" + $ProjStdPath +"\" + $key +"\\  # Discipline"
Add-Content -Path $UstnEDECfgFile -Value $string
}                                         
Add-Content -Path $UstnEDECfgFile -Value "PROJ=$ProjAbbr # Project abbreviation."
Add-Content -Path $UstnEDECfgFile -Value "SUBP=$SubpDirname # Subproject abbreviation."
Add-Content -Path $UstnEDECfgFile -Value "DISC=$DiscAbbr # Discipline directory name."
#3                                         
#ForAllDisc($Disc + = + $ProjPath  + $SubpLinkPath  + \ + $SubpDirname  + \ + $DiscDirname  + \\  # Discipline)"
foreach ($key in $dict.values)
{
$string = $key.ToUpper() + "=" + $projPath + ":\\" + $SubpDirname + "\" + $key + "\\"  + "  # Discipline"
Add-Content -Path $UstnEDECfgFile -Value $string | Sort-Object -Descending
}
#4
#ForAllDisc(PS + $Disc + = + $ProjStdPath +  $DiscDirname  + \  # Discipline)"
foreach ($key in $dict.values)
{
$string = "PS" + $key.ToUpper() + "=" + $projPath +":\"+ $projstdpath +"\"+ $key + "\\" + "  # Discipline"
Add-Content -Path $UstnEDECfgFile -Value $string | Sort-Object
}
Add-Content -Path $UstnEDECfgFile -Value "PS=$ProjStdGEPath\\         # Project standard GE."
Add-Content -Path $UstnEDECfgFile -Value "PJ=$ProjStdDiscPath\\         # Project standard Disc."
Add-Content -Path $UstnEDECfgFile -Value "CSTD=$CmpyStdGEpath\\         # Company standards STD GE."
Add-Content -Path $UstnEDECfgFile -Value "DSTD=$CmpyStdDiscPath\\         # Company standards STD Disc."


#endregion AppendingFile

#endregion MicroStationVariables

WriteToLog $LogLevelInfo "Finished region MicroStationVariables"

WriteToLog $LogLevelInfo "Entering region AppendFile"

#region AppendFile
# Append the project variables to the config file.
$stringPcf = ".pcf"
$XProjPcf = "$ProjStdGEPath$stringBackslash$ProjUstnWkspDir$ProjAbbr$stringPcf"
$readXProjPcf = Get-Content -Path $XProjPcf

WriteToLog $LogLevelInfo $XProjPcf
WriteToLog $LogLevelInfo $readXProjPcf

if(Test-Path $XProjPcf)
{
WriteToLog $LogLevelInfo ""The pcf exists""
Add-Content -Path $UstnEDECfgFile -Value $readXProjPcf
}
$stringDcf = ".dcf"
# Append the disipline variables (project & company stds) to the config file.
$XCmpyDcf = "$CmpyStdDiscPath$stringBackslash$ProjUstnWkspDir$DiscAbbr$stringDcf"
$readXCmpyDcf = Get-Content -Path $XCmpyDcf

WriteToLog $LogLevelInfo $XCmpyDcf
WriteToLog $LogLevelInfo $readXCmpyDcf

if(Test-Path $XCmpyDcf)
{
WriteToLog $LogLevelInfo "The company dcf File Exist"
Add-Content -Path $UstnEDECfgFile -Value $readXCmpyDcf
}

$XProjDcf = "$ProjStdDiscPath$stringBackslash$ProjUstnWkspDir$DiscAbbr$stringDcf"
$readXProjDcf = Get-Content -Path $XProjDcf

WriteToLog $LogLevelInfo $XProjDcf
WriteToLog $LogLevelInfo $readXProjDcf

if(Test-Path $XProjDcf)
{
WriteToLog $LogLevelInfo "The proj dcf File Exist"
Add-Content -Path $UstnEDECfgFile -Value $readXProjDcf
}

#run(wait, cmd /c copy $UstnEDECfgFile $USTNConfigFile)

Copy-Item $UstnEDECfgFile $UstnPrefsDir

#Rename-Item $USTNConfigFile -NewName "dfltuser.ucf"
$stringEde = "ede.ucf"
$stringDftlUser = "dfltuser.cfg"
$newEdefile = "$UstnPrefsDir$stringEde"
$newDfltFile = "$UstnPrefsDir$stringDftlUser"

WriteToLog $LogLevelInfo $newEdefile
WriteToLog $LogLevelInfo $newDfltFile

WriteToLog $LogLevelInfo "Before the first test-path"
if (!(Test-Path -Path $UstnPrefsDir -Include  "ede.ucf"))
{
WriteToLog $LogLevelInfo "Inside the First Test-Path"

 Remove-Item -Path $newEdefile
}
WriteToLog $LogLevelInfo "Before the second test-path"
if (!(Test-Path -Path $UstnPrefsDir -Include "dfltuser.cfg"))
{
WriteToLog $LogLevelInfo "Inside the Second Test-Path"
 Remove-Item -Path $newDfltFile
}

WriteToLog $LogLevelInfo "After the WriteToLog"

Copy-Item $UstnEDECfgFile $UstnPrefsDir
Rename-Item $newEdefile -NewName "dfltuser.cfg"

#RoboCopy $UstnEDECfgFile $USTNConfigFile  $cmdArgs
#endregion AppendFile

WriteToLog $LogLevelInfo "Finished region AppendFile"
exit 0
