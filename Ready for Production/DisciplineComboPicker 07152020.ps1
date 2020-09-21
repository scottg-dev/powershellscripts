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

#This will make the script run as an admin
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`"";
    exit;
}

#region Create Array of Disciplines
#Create params for appsetra. 

[array]$ComboBoxArray = "Architectural", "Civil", "Electrical","CAD General","Instrumentation","Material Handling","Mechanical Process","Mechanical Utilities","Piping","Structural","Vessels","Backgrounds"
#endregion Create Array of Disciplines

#region Create Array for SubPProject

[array]$ComboBoxArraySubPDirName = "2D","3D"

#endregion Create Array for SubPProject


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
}
#endregion Functions

#region Define the Form
# Define the form
$Form = New-Object System.Windows.Forms.Form
$Form.width  = 350
$Form.height = 225
$Form.Text   = "Please Select a Discipline"
$ComboBox          = new-object System.Windows.Forms.ComboBox
$ComboBox.Location = new-object System.Drawing.Size(100,10)
$ComboBox.Size     = new-object System.Drawing.Size(125,50)
$ComboBox1          = new-object System.Windows.Forms.ComboBox
$ComboBox1.Location = new-object System.Drawing.Size(100,50)
$ComboBox1.Size     = new-object System.Drawing.Size(125,50)
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
}#End of foreach loop

$LoopSubPDirName_CNT = 0
foreach ($ItemSubPDirName in $ComboBoxArraySubPDirName)
{
[void] $ComboBox1.Items.Add($ItemSubPDirName)
if ($ItemSubPDirName -eq "2D")
{
$ComboBox1.SelectedItem = $ItemSubPDirName
$ComboBox1.SelectedIndex = $LoopSubPDirName_CNT
}
$LoopSubPDirName_CNT = $LoopSubPDirName_CNT + 1
} # End of foreach loop
#endregion Load Elements

#Display a message in the combo box if an item is not selected
if ($ComboBox.SelectedIndex -lt 0)
{
$ComboBox.Text = "Please select a value from the list";
}
#Entered a new combobox for SubPDirName
if ($ComboBox1.SelectedIndex -lt 0)
{
$ComboBox1.Text = "Please select a value from the list";
}

#region Controls
#Add controls to the form
$ComboBoxLabel          = new-object System.Windows.Forms.Label
$ComboBoxLabel.Location = new-object System.Drawing.Size(10,10)
$ComboBoxLabel.size     = new-object System.Drawing.Size(100,25)
$ComboBoxLabel.Text     = "Discipline"
$Button                 = new-object System.Windows.Forms.Button
$Button.Location        = new-object System.Drawing.Size(100,150)
$Button.Size            = new-object System.Drawing.Size(100,20)
$Button.Text            = "OK"
$Button.Add_Click({ReturnSelectedValue})
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,45)
$label.Size = New-Object System.Drawing.Size(175,55)
$label.Text = 'Sub-project'
#get rid of list box
$ComboBoxLabel1          = new-object System.Windows.Forms.Label
$ComboBoxLabel1.Location = new-object System.Drawing.Size(10,50)
$ComboBoxLabel1.size     = new-object System.Drawing.Size(100,25)
$ComboBoxLabel1.Text     = "SubDirName"
$Form.Controls.Add($ComboBox)
$Form.Controls.Add($ComboBox1)
$Form.Controls.Add($ComboBoxLabel)
$form.Controls.Add($Button)
$form.Controls.Add($label)
#$form.Controls.Add($listBox)
$form.Topmost = $true
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
$dict.Add('Backgrounds','bk')
$dict.Add('CAD General','ge')
$dict.Add('Civil','ce')
$dict.Add('Electrical','ee')
$dict.Add('Instrumentation','in')
$dict.Add('Material Handling','mh')
$dict.Add('Mechanical Process','mp')
$dict.Add('Mechanical Utilities','mu')
$dict.Add('Piping','pd')
$dict.Add('Structural','st')
$dict.Add('Vessels','vs')

#endregion Discipline

#region SubPDirName
#Display the subpdirname within the combobox
$SubPDirName = $ComboBox1.SelectedItem
#endregion SubPDirName

#region Set Variables
$discfolder =  $dict[$Discipline]

#Set the Discipline Abbr
$discAbbr = [System.Environment]::SetEnvironmentVariable('DisciplineAbbr',$dict.Get_Item($Discipline),[System.EnvironmentVariableTarget]::Machine)

#Set the SubPDirName
Switch ($ComboBox1.SelectedItem)
{
"2D" {[System.Environment]::SetEnvironmentVariable('SubpDirname',"2D",[System.EnvironmentVariableTarget]::Machine)}
"3D" {[System.Environment]::SetEnvironmentVariable('SubpDirname',"3D",[System.EnvironmentVariableTarget]::Machine)}
}

WriteToLog ($LogLevelInfo, 'Environment variable Discipline Abbr set to:' + $discAbbr)
WriteToLog ($LogLevelInfo, 'Environment variable SubPDirName set to:' + $ComboBox1.SelectedItem)

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $x
}
#endregion Set Variables
ExitWithCode 0