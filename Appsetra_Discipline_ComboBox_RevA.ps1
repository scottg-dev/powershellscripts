﻿Clear-Host
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`"";
    exit;
}

#Create params for appsetra. 
[array]$ComboBoxArray = "Architectural", "Civil", "Electrical","CAD General","Instrumentation","Material Handling","Mechanical Process","Mechanical Utilities","Piping","Structural","Vessels","Backgrounds"

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

function ReturnSelectedValue
{
$SelectedIndex_NBR = $ComboBox.SelectedIndex
#write-host ""
if ($SelectedIndex_NBR -lt 0)
{
$script:Choice = "Item not selected"
} 
else 
{
$script:Choice = $ComboBox.SelectedItem.ToString()
}
$Form.Close()
} # End of function ReturnSelectedValue

 #Load assemblies
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

# Define the form
$Form = New-Object System.Windows.Forms.Form
$Form.width  = 350
$Form.height = 150
$Form.Text   = "Pick a discipline!"
$ComboBox          = new-object System.Windows.Forms.ComboBox
$ComboBox.Location = new-object System.Drawing.Size(100,10)
$ComboBox.Size     = new-object System.Drawing.Size(125,50)

#Load elements into combo box
$Loop_CNT = 0
foreach ($Item in $ComboBoxArray)
{
[void] $ComboBox.Items.Add($Item)
if ($Item -eq "Architectural")
{
$ComboBox.SelectedItem = $Item
$ComboBox.SelectedIndex = $Loop_CNT
}
$Loop_CNT = $Loop_CNT + 1
} # End of foreach loop

#Display a message in the combo box if an item is not selected
if ($ComboBox.SelectedIndex -lt 0)
{
$ComboBox.Text = "Please select a value from the list";
}

#Add controls to the form
$Form.Controls.Add($ComboBox)
$ComboBoxLabel          = new-object System.Windows.Forms.Label
$ComboBoxLabel.Location = new-object System.Drawing.Size(10,10)
$ComboBoxLabel.size     = new-object System.Drawing.Size(100,25)
$ComboBoxLabel.Text     = "Items"
$Form.Controls.Add($ComboBoxLabel)
$Button                 = new-object System.Windows.Forms.Button
$Button.Location        = new-object System.Drawing.Size(100,50)
$Button.Size            = new-object System.Drawing.Size(100,20)
$Button.Text            = "Select an Item"
$Button.Add_Click({ReturnSelectedValue})
$form.Controls.Add($Button)

$Form.Add_Shown({$Form.Activate()})
[void] $Form.ShowDialog()


#Display selected information
$Discipline = $Choice
#write-host ""
#write-host 'The discipline is ' $Discipline
#write-host ""
switch ($Discipline)
{
"Architectural" {[System.Environment]::SetEnvironmentVariable('Discipline','Architectural',[System.EnvironmentVariableTarget]::Machine)}
"Civil" {[System.Environment]::SetEnvironmentVariable('Discipline','Civil',[System.EnvironmentVariableTarget]::Machine)}
"Electrical" {[System.Environment]::SetEnvironmentVariable('Discipline','Electrical',[System.EnvironmentVariableTarget]::Machine)}
"CAD General" {[System.Environment]::SetEnvironmentVariable('Discipline','CAD General',[System.EnvironmentVariableTarget]::Machine)}
"Instrumentation" {[System.Environment]::SetEnvironmentVariable('Discipline','Instrumentation',[System.EnvironmentVariableTarget]::Machine)}
"Material Handling" {[System.Environment]::SetEnvironmentVariable('Discipline','Material Handling',[System.EnvironmentVariableTarget]::Machine)}
"Mechanical Process" {[System.Environment]::SetEnvironmentVariable('Discipline','Mechanical Process',[System.EnvironmentVariableTarget]::Machine)}
"Mechanical Utilities" {[System.Environment]::SetEnvironmentVariable('Discipline','Mechanical Utilities',[System.EnvironmentVariableTarget]::Machine)}
"Piping" {[System.Environment]::SetEnvironmentVariable('Discipline','Piping',[System.EnvironmentVariableTarget]::Machine)}
"Structural" {[System.Environment]::SetEnvironmentVariable('Discipline','Structural',[System.EnvironmentVariableTarget]::Machine)}
"Vessels" {[System.Environment]::SetEnvironmentVariable('Discipline','Vessels',[System.EnvironmentVariableTarget]::Machine)}
"Backgrounds" {[System.Environment]::SetEnvironmentVariable('Discipline','Backgrounds',[System.EnvironmentVariableTarget]::Machine)}
}

WriteToLog ($LogLevelInfo, 'Environment variable Discipline set to: ' + $Discipline)

#Create an array to hold Discipline Info
$dict = @{}
$dict.Add('Architectural','ar')
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
$dict.Add('Backgrounds','bk')


$discfolder =  $dict[$Discipline]
WriteToLog ($LogLevelInfo, 'Directory that was picked was:' + $discfolder)

$discAbbr = [System.Environment]::SetEnvironmentVariable('DisciplineAbbr',$dict.Get_Item($Discipline),[System.EnvironmentVariableTarget]::Machine)

WriteToLog ($LogLevelInfo, 'Environment variable Discipline Abbr set to:' + $discAbbr)

exit 0