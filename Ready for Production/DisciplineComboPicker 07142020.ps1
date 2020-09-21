# Script Name: DisciplineComboPicker
# Description: This sets  System Environment Variables. Discipline, SubpDirDname .
# Script Version: 1.0.0
# Created: 07/14/2020 SMG

# Script Arguments:None
# Clear the error variable.
$error.clear()


Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing


# Hide PowerShell Console
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0)

#add comment to display
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`"";
    exit;
}

#region Create Array of Disciplines
#Create params for appsetra. 

[array]$ComboBoxArray = "Architectural", "Civil", "Electrical","CAD General","Instrumentation","Material Handling","Mechanical Process","Mechanical Utilities","Piping","Structural","Vessels","Backgrounds"

#endregion Create Array of Disciplines

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

#region Functions 
function ReturnSelectedValue
{
$SelectedIndex_NBR = $ComboBox.SelectedIndex

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
#endregion Functions

#region Load assemblies
 #Load assemblies
#[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
#[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
#endregion Load assemblies

#region Define the Form
# Define the form
$Form = New-Object System.Windows.Forms.Form
$Form.width  = 350
$Form.height = 225
$Form.Text   = "Please Pick a discipline."
$ComboBox          = new-object System.Windows.Forms.ComboBox
$ComboBox.Location = new-object System.Drawing.Size(100,10)
$ComboBox.Size     = new-object System.Drawing.Size(125,50)
#endregion Define the Form

#region Load Elements
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
#endregion Load Elements

#region Controls
#Add controls to the form
$ComboBoxLabel          = new-object System.Windows.Forms.Label
$ComboBoxLabel.Location = new-object System.Drawing.Size(10,10)
$ComboBoxLabel.size     = new-object System.Drawing.Size(100,25)
$ComboBoxLabel.Text     = "Items"
$Button                 = new-object System.Windows.Forms.Button
$Button.Location        = new-object System.Drawing.Size(100,150)
$Button.Size            = new-object System.Drawing.Size(100,20)
$Button.Text            = "Select an Item"
$Button.Add_Click({ReturnSelectedValue})
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,45)
$label.Size = New-Object System.Drawing.Size(175,55)
$label.Text = 'Please make a selection from the list below:'
$listBox = New-Object System.Windows.Forms.Listbox
$listBox.Location = New-Object System.Drawing.Point(100,100)
$listBox.Size = New-Object System.Drawing.Size(125,50)
$listBox.SelectionMode = 'One'
$listBox.Height = 50
$Form.Controls.Add($ComboBox)
$Form.Controls.Add($ComboBoxLabel)
$form.Controls.Add($Button)
$form.Controls.Add($label)
$form.Controls.Add($listBox)
$form.Topmost = $true
[void] $listBox.Items.Add('2D')
[void] $listBox.Items.Add('3D')
[void] $Form.ShowDialog()

$Form.Add_Shown({$Form.Activate()})
#endregion Controls

#region Discipline

#Display selected information
$Discipline = $Choice
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
$dict.Add('Structural','st')
$dict.Add('Vessels','vs')
$dict.Add('Backgrounds','bk')
#endregion Discipline

#region Set Variables
$discfolder =  $dict[$Discipline]
#Set the Discipline Abbr
$discAbbr = [System.Environment]::SetEnvironmentVariable('DisciplineAbbr',$dict.Get_Item($Discipline),[System.EnvironmentVariableTarget]::Machine)
#Set the SubPDirName
Switch ($listBox.SelectedItem)
{
"2D" {[System.Environment]::SetEnvironmentVariable('SubpDirname',$listBox.SelectedItem,[System.EnvironmentVariableTarget]::Machine)}
"3D" {[System.Environment]::SetEnvironmentVariable('SubpDirname',$listBox.SelectedItem,[System.EnvironmentVariableTarget]::Machine)}
}
WriteToLog ($LogLevelInfo, 'Environment variable Discipline Abbr set to:' + $discAbbr)
WriteToLog ($LogLevelInfo, 'Environment variable SubPDirName set to:' + $listBox.SelectedItem)

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $x = $listBox.SelectedItems
    $x
}
#endregion Set Variables
ExitWithCode 0