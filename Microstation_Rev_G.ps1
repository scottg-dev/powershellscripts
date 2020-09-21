

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

$DiscAbbr = [System.Environment]::GetEnvironmentVariable('DisciplineAbbr',[System.EnvironmentVariableTarget]::Machine)

$AppVersion ="07.01"
$ProjStdGEPath = $projPath + ":\" + $projstdpath + "\" + $projGEDir
$ProjStdDiscPath = $projPath + ":\" + $projstdpath + "\" + $DiscAbbr
$CmpyStdGEPath= $CmpyDir + ":\" + $CmpyStdGEdir
$CmpyStdDiscPath = $CmpyDir + ":\" + $DiscAbbr
$projPathWColon = $projPath + ":"

#endregion Params

#region Logging 

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
$X3 = "$CmpyStdGEPath\$ProjWkspCellDir"      # Company standard cell libraries"
$X4 = "$CmpyStdDiscPath\$ProjWkspCellDir"    # Company standard discipline's cell libraries"
$X5 = "$ProjStdGEPath\$ProjWkspCellDir"    # Project standard cell libraries"
$X6 = "$ProjStdDiscPath\$ProjWkspCellDir"     # Project standard discipline's cell libraries"

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
$X1 = "$EdeWkspDataNetDir"                       # EDE System data files
$X2 = "$EdeSiteWkspDataNetDir"                   # Site data files
$X3 = "$CmpyStdGEPath\$ProjWkspDataDir"      # Company standard data files
$X4 = "$CmpyStdDiscPath\$ProjWkspDataDir"      # Company standard discipline's data files
$X5 = "$ProjStdGEPath\$ProjWkspDataDir"      # Project standard data files
$X6 = "$ProjStdDiscPath\$ProjWkspDataDir"      # Project standard discipline's data files

$source = @($X1,$X2,$X3,$X4,$X5,$X6)
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
$X1 = "$EdeWkspSeedNetDir"                       # EDE System Seed files
$X2 = "$EdeSiteWkspSeedNetDir"                   # Site Seed files
$X3 = "$CmpyStdGEPath\$ProjWkspSeedDir"      # Company standard Seed files
$X4 = "$CmpyStdDiscPath\$ProjWkspSeedDir"      # Company standard discipline's Seed files
$X5 = "$ProjStdGEPath\$ProjWkspSeedDir"      # Project standard Seed files
$X6 = "$ProjStdDiscPath\$ProjWkspSeedDir"      # Project standard discipline's Seed files

$source = @($X1,$X2,$X3,$X4,$X5,$X6)
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
$X1 = "$EdeWkspSymbNetDir"                       # EDE System Symbology files
$X2 = "$EdeSiteWkspSymbNetDir"                   # Site symbology files
$X3 = "$CmpyStdGEPath\$ProjWkspSymbDir"      # Company standard symbology files.
$X4 = "$CmpyStdDiscPath\$ProjWkspSymbDir"      # Company standard discipline's symbology files.
$X5 = "$ProjStdGEPath\$ProjWkspSymbDir"      # Project standard symbology files.
$X6 = "$ProjStdDiscPath\$ProjWkspSymbDir"      # Project standard discipline's symbology files.

$itemstocopy = $EdeWkspSymbDir +'\*'
$source = @($X1,$X2,$X3,$X4,$X5,$X6)
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
$X1 = "$EdeWkspUcmNetDir"                       # EDE System UCM files.
$X2 = "$EdeSiteWkspUcmNetDir"                   # Site UCM files.
$X3 = "$CmpyStdGEPath\$ProjWkspUcmDir"      # Company standard UCM files.
$X4 = "$CmpyStdDiscPath\$ProjWkspUcmDir"      # Company standard discipline's UCM files.
$X5 = "$ProjStdGEPath\$ProjWkspUcmDir"      # Project standard UCM files.
$X6 = "$ProjStdDiscPath\$ProjWkspUcmDir"      # Project standard discipline's UCM files.

$source = @($X1,$X2,$X3,$X4,$X5,$X6)
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
$X1 = "$EdeWkspMacroNetDir"                       # EDE System Macros.
$X2 = "$EdeSiteWkspMacroNetDir"                   # Site Macros.
$X3 = "$CmpyStdGEPath\$ProjWkspMacroDir"      # Company standard Macros.
$X4 = "$CmpyStdDiscPath\$ProjWkspMacroDir"      # Company standard discipline's Macros.
$X5 = "$ProjStdGEPath\$ProjWkspMacroDir"      # Project standard Macros.
$X6 = "$ProjStdDiscPath\$ProjWkspMacroDir"      # Project standard discipline's Macros.

$source = @($X1,$X2,$X3,$X4,$X5,$X6)
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
$X1 = "$EdeWkspPlotDrvNetDir"                       # EDE System drivers.
$X2 = "$EdeSiteWkspPlotDrvNetDir"                   # Site drivers.
$X3 = "$CmpyStdGEPath\$ProjWkspPlotDrvDir"      # Company standard drivers.
$X4 = "$CmpyStdDiscPath\$ProjWkspPlotDrvDir"      # Company standard discipline drivers.
$X5 = "$ProjStdGEPath\$ProjWkspPlotDrvDir"      # Project standard drivers.
$X6 = "$ProjStdDiscPath\$ProjWkspPlotDrvDir"      # Project standard discipline drivers.
#CopyMFile($UstnSysPlotDrvDir, *.*, $X1, $X2, $X3, $X4, $X5, $X6)

$source = @($X1,$X2,$X3,$X4,$X5,$X6)
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
$X1 = "$EdeWkspPenTableNetDir"                       # EDE System tables.
$X2 = "$EdeSiteWkspPenTableNetDir"                   # Site tables.
$X3 = "$CmpyStdGEPath\$ProjWkspPenTableDir"      # Company standard drivers.
$X4 = "$CmpyStdDiscPath\$ProjWkspPenTableDir"      # Company standard discipline tables.
$X5 = "$ProjStdGEPath\$ProjWkspPenTableDir"      # Project standard drivers.
$X6 = "$ProjStdDiscPath\$ProjWkspPenTableDir"      # Project standard discipline tables.
#CopyMFile($UstnSysPenTableDir, *.*, $X1, $X2, $X3, $X4, $X5, $X6)

$source = @($X1,$X2,$X3,$X4,$X5,$X6)
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
$X1 = "$UstnSysDataDir"                              # Default system file
$X2 = "$EdeWkspDataNetDir"                           # EDE System file.
$X3 = "$EdeSiteWkspDataNetDir"                       # Site file.
$X4 = "$CmpyStdGEPath\$ProjWkspDataDir"          # Company standard file.
$X5 = "$CmpyStdDiscPath\$ProjWkspDataDir"          # Company standard discipline file.
$X6 = "$ProjStdGEPath\$ProjWkspDataDir"          # Project standard file.
$X7 = "$ProjStdDiscPath\$ProjWkspDataDir"          # Project standard discipline file.

$source = @($X1,$X2,$X3,$X4,$X5,$X6,$X7)
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
$X1 = "$EdeWkspIntfNetDir"                     # EDE System user interface files.
$X2 = "$EdeSiteWkspIntfNetDir"                 # Site user interface files.
$X3 = "$CmpyStdDiscPath\$ProjWkspIntfDir"    # Company standard discipline's user interface files.
$X4 = "$ProjStdGEPath\$ProjWkspIntfDir"      # Project standard discipline's user interface files.
$X5 = "$ProjStdDiscPath\$ProjWkspIntfDir"  # Project standard user interface files.

$source = @($X1,$X2,$X3,$X4,$X5)
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
$X1 = "$EdeWkspFkeysNetDir"                    # EDE System function key menus.
$X2 = "$EdeSiteWkspFkeysNetDir"                # Site function key menus.
$X3 = "$CmpyStdDiscPath\$ProjWkspFkeysDir"   # Company standard discipline's function key menus.
$X4 = "$ProjStdDiscPath\$ProjWkspFkeysDir"   # Project standard function key menus.

$source = @($X1,$X2,$X3,$X4)
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
Add-Content -Path $UstnEDECfgFile -Value "JOB_CEL           =$ProjStdDiscPath\$DiscDirname$DiscAbbr$ProjAbbr.cel    # Disc. Tmp cell lib."
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
Add-Content -Path $UstnEDECfgFile -Value "SUBP=$SubpAbbr # Subproject abbreviation."
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
WriteToLog $LogLevelInfo "Does it Make it here?"

#endregion AppendingFile

#endregion MicroStationVariables

WriteToLog $LogLevelInfo "Why yes it does!"
WriteToLog $LogLevelInfo "Finished region MicroStationVariables"

WriteToLog $LogLevelInfo "Entering region AppendFile"

#region AppendFile
# Append the project variables to the config file.
$XProjPcf = $ProjStdGEPath + "\" + $ProjUstnWkspDir + $ProjAbbr + ".pcf"
$read = Get-Content -Path $XProjPcf

WriteToLog $LogLevelInfo $XProjPcf
WriteToLog $LogLevelInfo $read

if(Test-Path $XProjPcf)
{
WriteToLog $LogLevelInfo ""The pcf exists""
Add-Content -Path $UstnEDECfgFile -Value $read
}
# Append the disipline variables (project & company stds) to the config file.
$XCmpyDcf = $CmpyStdDiscPath + "\" + $ProjUstnWkspDir + $DiscAbbr + ".dcf"
$read = Get-Content -Path $XCmpyDcf

WriteToLog $LogLevelInfo $XCmpyDcf
WriteToLog $LogLevelInfo $read

if(Test-Path $XCmpyDcf)
{
WriteToLog $LogLevelInfo "The company dcf File Exist"
Add-Content -Path $UstnEDECfgFile -Value $read
}

$XProjDcf = $ProjStdDiscPath +"\" + $ProjUstnWkspDir + $DiscAbbr + ".dcf"
$read = Get-Content -Path $XProjDcf

WriteToLog $LogLevelInfo $XProjDcf
WriteToLog $LogLevelInfo $read

if(Test-Path $XProjDcf)
{
WriteToLog $LogLevelInfo "The proj dcf File Exist"
Add-Content -Path $UstnEDECfgFile -Value $read
}

#run(wait, cmd /c copy $UstnEDECfgFile $USTNConfigFile)

Copy-Item $UstnEDECfgFile $UstnPrefsDir

#Rename-Item $USTNConfigFile -NewName "dfltuser.ucf"
$newEdefile = $UstnPrefsDir + "ede.ucf"
$newDfltFile = $UstnPrefsDir + "dfltuser.cfg"

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
