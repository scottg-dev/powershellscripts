# Script Name: HPRGSConfigure
# Description: Writes registry values to configure HPRGS.
# Script Version: 1.0.0
# Modified: 1/9/2020 CO initial version

# Script Arguments:
# machineName: Name of RGS machine to connect to 

param([string]$machineName)

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

# Clear the error variable
$error.clear()

WriteToLog $LogLevelInfo "Executing script $scriptName"
WriteToLog $LogLevelInfo "Printing input params"
WriteToLog $LogLevelInfo "Value of machineName = $machineName"

if (!$machineName) { 
    WriteToLog $LogLevelError "Cannot proceed without a valid machine name."
    ExitWithCode 2
}

$regKeyPath = 'HKCU:\Software\Hewlett-Packard\Remote Graphics Receiver'
$regValues = @(
    ("Rgreceiver.Audio.IsEnabled", "1", "String"),
    ("Rgreceiver.Audio.IsEnabled.IsMutable", "1", "String"),
    ("Rgreceiver.Audio.IsFollowsFocusEnabled", "0", "String"),
    ("Rgreceiver.Audio.IsFollowsFocusEnabled.IsMutable", "1", "String"),
    ("Rgreceiver.Audio.IsInStereo", "1", "String"),
    ("Rgreceiver.Audio.IsInStereo.IsMutable", "1", "String"),
    ("Rgreceiver.Audio.IsMutable", "1", "String"),
    ("Rgreceiver.Audio.Quality", "1", "String"),
    ("Rgreceiver.Audio.Quality.IsMutable", "1", "String"),
    ("Rgreceiver.Browser.IsMutable", "1", "String"),
    ("Rgreceiver.Browser.Name", "", "String"),
    ("Rgreceiver.Browser.Name.IsMutable", "1", "String"),
    ("Rgreceiver.Clipboard.FilterString", "|1|2|7|8|13|16|17|Ole Private Data|Object Descriptor|Link Source Descriptor|HTML Format|Rich Text Format|XML Spreadsheet|", "String"),
    ("Rgreceiver.Clipboard.FilterString.IsMutable", "1", "String"),
    ("Rgreceiver.Clipboard.IsEnabled", "1", "String"),
    ("Rgreceiver.Clipboard.IsEnabled.IsMutable", "1", "String"),
    ("Rgreceiver.Clipboard.IsMutable", "1", "String"),
    ("Rgreceiver.ConnectionWarningColor", "0x0", "String"),
    ("Rgreceiver.ConnectionWarningColor.IsMutable", "1", "String"),
    ("Rgreceiver.Directory", "directory.txt", "String"),
    ("Rgreceiver.Directory.IsMutable", "1", "String"),
    ("Rgreceiver.Hotkeys.IsCtrlAltDeletePassThroughEnabled", "0", "String"),
    ("Rgreceiver.Hotkeys.IsCtrlAltDeletePassThroughEnabled.IsMutable", "1", "String"),
    ("Rgreceiver.Hotkeys.IsKeyRepeatEnabled", "0", "String"),
    ("Rgreceiver.Hotkeys.IsKeyRepeatEnabled.IsMutable", "1", "String"),
    ("Rgreceiver.Hotkeys.IsMutable", "1", "String"),
    ("Rgreceiver.Hotkeys.IsSendCtrlAltEndAsCtrlAltDeleteEnabled", "1", "String"),
    ("Rgreceiver.Hotkeys.IsSendCtrlAltEndAsCtrlAltDeleteEnabled.IsMutable", "1", "String"),
    ("Rgreceiver.Hotkeys.IsSendFirstKeyInSequenceEnabled", "0", "String"),
    ("Rgreceiver.Hotkeys.IsSendFirstKeyInSequenceEnabled.IsMutable", "1", "String"),
    ("Rgreceiver.Hotkeys.SetupModeSequence", "Shift Down, Space Down, Space Up", "String"),
    ("Rgreceiver.Hotkeys.SetupModeSequence.IsMutable", "1", "String"),
    ("Rgreceiver.ImageCodec.IsMutable", "1", "String"),
    ("Rgreceiver.ImageCodec.Quality", "65", "String"),
    ("Rgreceiver.ImageCodec.Quality.IsMutable", "1", "String"),
    ("Rgreceiver.IsAlwaysPromptCredentialsEnabled", "0", "String"),
    ("Rgreceiver.IsAlwaysPromptCredentialsEnabled.IsMutable", "1", "String"),

    ("Rgreceiver.IsBordersEnabled", "0", "String"),

    ("Rgreceiver.IsBordersEnabled.IsMutable", "1", "String"),
    ("Rgreceiver.IsGlobalImageUpdateEnabled", "0", "String"),
    ("Rgreceiver.IsGlobalImageUpdateEnabled.IsMutable", "1", "String"),
    ("Rgreceiver.IsGlobalImageUpdateMutable", "1", "String"),
    ("Rgreceiver.IsInputMethodForPasswordFieldEnabled", "0", "String"),
    ("Rgreceiver.IsInputMethodForPasswordFieldEnabled.IsMutable", "1", "String"),

    ("Rgreceiver.IsMatchReceiverPhysicalDisplaysEnabled", "1", "String"),
    ("Rgreceiver.IsMatchReceiverPhysicalDisplaysEnabled.IsMutable", "1", "String"),
    ("Rgreceiver.IsMatchReceiverResolutionEnabled", "1", "String"),
    ("Rgreceiver.IsMatchReceiverResolutionEnabled.IsMutable", "1", "String"),

    ("Rgreceiver.IsSnapEnabled", "1", "String"),
    ("Rgreceiver.IsSnapEnabled.IsMutable", "1", "String"),

    ("Rgreceiver.Log.Filename", "$env:UserProfile\hpremote\rgreceiver\rg.log", "String"),

    ("Rgreceiver.Log.Filename.IsMutable", "1", "String"),
    ("Rgreceiver.Log.IsConsoleLoggerEnabled", "0", "String"),
    ("Rgreceiver.Log.IsConsoleLoggerEnabled.IsMutable", "1", "String"),
    ("Rgreceiver.Log.IsFileLoggerEnabled", "1", "String"),
    ("Rgreceiver.Log.IsFileLoggerEnabled.IsMutable", "1", "String"),
    ("Rgreceiver.Log.IsMutable", "1", "String"),
    ("Rgreceiver.Log.Level", "INFO", "String"),
    ("Rgreceiver.Log.Level.IsMutable", "1", "String"),
    ("Rgreceiver.Log.MaxFileSize", "1024", "String"),
    ("Rgreceiver.Log.MaxFileSize.IsMutable", "1", "String"),
    ("Rgreceiver.Log.NumBackupFiles", "5", "String"),
    ("Rgreceiver.Log.NumBackupFiles.IsMutable", "1", "String"),
    ("Rgreceiver.MaxImageUpdateRequests", "4", "String"),
    ("Rgreceiver.MaxImageUpdateRequests.IsMutable", "1", "String"),
    ("Rgreceiver.MaxSenderListSize", "5", "String"),
    ("Rgreceiver.MaxSenderListSize.IsMutable", "1", "String"),
    ("Rgreceiver.Mic.IsEnabled", "0", "String"),
    ("Rgreceiver.Mic.IsEnabled.IsMutable", "1", "String"),
    ("Rgreceiver.Mic.IsMutable", "1", "String"),
    ("Rgreceiver.Network.Router.IsEnabled", "0", "String"),
    ("Rgreceiver.Network.Router.IsEnabled.IsMutable", "1", "String"),
    ("Rgreceiver.Network.Router.Name", "", "String"),
    ("Rgreceiver.Network.Router.Name.IsMutable", "1", "String"),
    ("Rgreceiver.Network.Timeout.Dialog", "15000", "String"),
    ("Rgreceiver.Network.Timeout.Dialog.IsMutable", "1", "String"),

    ("Rgreceiver.Network.Timeout.Error", "60000", "String"),
    ("Rgreceiver.Network.Timeout.Error.IsMutable", "1", "String"),
    ("Rgreceiver.Network.Timeout.IsMutable", "1", "String"),
    ("Rgreceiver.Network.Timeout.Warning", "30000", "String"),
    ("Rgreceiver.Network.Timeout.Warning.IsMutable", "1", "String"),

    ("Rgreceiver.RecentSenders", "$machineName", "String"),
    ("Rgreceiver.RecentSenders.IsMutable", "0", "String"),

    ("Rgreceiver.RecentWindowPositions", "10 10", "String"),
    ("Rgreceiver.RecentWindowPositions.IsMutable", "1", "String"),

    ("Rgreceiver.Session.0.RemoteDisplayWindow.Caption", "Remote Workstation-$machineName", "String"),

    ("Rgreceiver.Session.0.RemoteDisplayWindow.Caption.IsMutable", "1", "String"),
    ("Rgreceiver.Session.0.RemoteDisplayWindow.HighlightColor", "0.5 128 128 128", "String"),
    ("Rgreceiver.Session.0.RemoteDisplayWindow.HighlightColor.IsMutable", "1", "String"),
    ("Rgreceiver.Session.0.RemoteDisplayWindow.IsHighlightColorEnabled", "0", "String"),
    ("Rgreceiver.Session.0.RemoteDisplayWindow.IsHighlightColorEnabled.IsMutable", "1", "String"),
    ("Rgreceiver.Session.0.RemoteDisplayWindow.X", "10", "String"),
    ("Rgreceiver.Session.0.RemoteDisplayWindow.X.IsMutable", "1", "String"),
    ("Rgreceiver.Session.0.RemoteDisplayWindow.Y", "10", "String"),
    ("Rgreceiver.Session.0.RemoteDisplayWindow.Y.IsMutable", "1", "String"),
    ("Rgreceiver.Session.0.VirtualDisplay.IsPreferredResolutionEnabled", "0", "String"),
    ("Rgreceiver.Session.0.VirtualDisplay.IsPreferredResolutionEnabled.IsMutable", "1", "String"),
    ("Rgreceiver.Session.0.VirtualDisplay.PreferredResolutionHeight", "0", "String"),
    ("Rgreceiver.Session.0.VirtualDisplay.PreferredResolutionHeight.IsMutable", "1", "String"),
    ("Rgreceiver.Session.0.VirtualDisplay.PreferredResolutionWidth", "0", "String"),
    ("Rgreceiver.Session.0.VirtualDisplay.PreferredResolutionWidth.IsMutable", "1", "String"),
    ("Rgreceiver.Usb.ActiveSession", "0", "String"),
    ("Rgreceiver.Usb.ActiveSession.IsMutable", "1", "String"),
    ("Rgreceiver.Usb.IsEnabled", "1", "String"),
    ("Rgreceiver.Usb.IsEnabled.IsMutable", "1", "String"),
    ("Rgreceiver.Usb.IsMutable", "1", "String")
)

foreach ($value in $regValues) {
    if (!(Test-Path $regKeyPath)) {
        New-Item -Path $regKeyPath -Force | Out-Null
        New-ItemProperty -Path $regKeyPath -Name $value[0] -Value $value[1] -PropertyType $value[2] -Force | Out-Null
    } else {
        New-ItemProperty -Path $regKeyPath -Name $value[0] -Value $value[1] -PropertyType $value[2] -Force | Out-Null
    }
}

WriteToLog $LogLevelInfo "Done executing script $scriptName"

ExitWithCode 0
