# Script Name: FileModifyINI
# Description: Modified the ini file.
# Script Version: 1.0.4
# Modified: 5/6/2019 CO to create the ini file if it doesn't exist
# Modified: 6/13/2019 LB to write the hash talbe as ordered, so it doesn't change the order of the contents of the ini file
# Last Modified: 12/11/2019 CO removed call to ContrainsKey in section creation to fix issue using ordered Hash Tables

# Script Arguments:
# iniFilePath: Full path of the ini file to be modified
# sectionName: Section name.
# keyName: Name of the Key.
# keyValue: New value of the Key.

param([string]$iniFilePath, [string]$sectionName, [string]$keyName, [string]$keyValue)

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

WriteToLog $LogLevelInfo "Executing script $scriptName"
WriteToLog $LogLevelInfo "Printing input params"
WriteToLog $LogLevelInfo "Value of iniFilePath = $iniFilePath"
WriteToLog $LogLevelInfo "Value of section = $sectionName"
WriteToLog $LogLevelInfo "Value of keyName = $keyName"
WriteToLog $LogLevelInfo "Value of keyValue = $keyValue"

# Check if the path variable is null.
if (!$iniFilePath) 
{ 
    WriteToLog $LogLevelError "Cannot proceed without a valid ini file path."
    exit 2
}

if(!(Test-Path $iniFilePath)){
    WriteToLog $LogLevelError "Ini file does not exist. Creating."
    New-Item $iniFilePath
}

if (!$sectionName -or !$keyName -or !$keyValue) 
{ 
    WriteToLog $LogLevelError "Cannot proceed without valid inputs."
    exit 3
}

$bFoundValue = $false

# Read the file content to a hashtable.
try
{
    $ini = [ordered]@{}
    switch -regex -file $iniFilePath
    {
        "^\[(.+)\]$" # Section  
        {
            $section = $matches[1]
            $ini[$section] = @{}
            $CommentCount = 0
        }
        "^(;.*)$" # Comment  
        {
            if (!($section))  
            {  
                $section = "Comment-Section"  
                $ini[$section] = @{}  
            }  
            $value = $matches[1]
            $CommentCount = $CommentCount + 1
            $name = "Comment" + $CommentCount
            $ini[$section][$name] = $value
        } 
        "(.+?)\s*=\s*(.*)" # Key  
        {
            if (!($section))  
            {  
                $section = "No-Section"  
                $ini[$section] = @{}  
            }
            $name,$value = $matches[1..2]
            $ini[$section][$name] = $value

            if ($section -eq $sectionName -and $name -eq $keyName)
            {
                $ini[$section][$name] = $keyValue
                $bFoundValue = $true
            }
        }
    }
}
catch 
{
    $exceptionMessage = $_.Exception.Message
    WriteToLog $LogLevelInfo "Exception occured while reading the ini file: $exceptionMessage"
    exit 4
}

if ($bFoundValue -eq $false)
{
    WriteToLog $LogLevelInfo "Section or key name not found in the file. Creating."
    # Old exit case
    #exit 5

    # Add section/key if does not exist
    if(!$ini.($sectionName)){
        $ini[$sectionName] = @{}
    }    
    $ini[$sectionName][$keyName] = $keyValue
}

# Update the file
Remove-Item -Path $iniFilePath -Force
New-Item -Path $iniFilePath -Type "file" 

# Write the comment section first.
foreach ($i in $ini.keys)
{
    if ($i -eq "Comment-Section")
    {
        Foreach ($j in ($ini[$i].keys))
        {
            if ($j -match "^Comment[\d]+") 
            {
                Add-Content -Path $iniFilePath -Value "$($ini[$i][$j])"
            }
        }
        Add-Content -Path $iniFilePath -Value ""
    }
}

foreach ($i in $ini.keys)
{
    if (!($($ini[$i].GetType().Name) -eq "Hashtable"))
    {
        # No Sections
        Add-Content -Path $iniFilePath -Value "$i=$($ini[$i])"
    } 
    else # Sections 
    {
        if ($i -eq "Comment-Section")
        {
            continue
        }
        
        Add-Content -Path $iniFilePath -Value "[$i]"
        Foreach ($j in ($ini[$i].keys))
        {
            if ($j -match "^Comment[\d]+") 
            {
                Add-Content -Path $iniFilePath -Value "$($ini[$i][$j])"
            } 
            else 
            {
                Add-Content -Path $iniFilePath -Value "$j=$($ini[$i][$j])" 
            }
        }
        Add-Content -Path $iniFilePath -Value ""
    }
}

WriteToLog $LogLevelInfo "Done executing script $scriptName"

exit 0