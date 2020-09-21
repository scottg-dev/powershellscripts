# Script Name: FileModifyXML
# Description: Updates property value or values in an XML file.
# Script Version: 1.0.3

# Script Arguments:
# xmlFilePath: XML file path. (Example: "C:\Test\settings.xml")
# nodePath: Full node path of the property to be updated. The format should be /node1/node2/node3 (Example: /Data/SQL/Instance).
# propertyName: Name of the property.
# propertyValue: New value if the xml property is an attribute.
# parentPropertyName: Property name of parent node one level up.
# parentPropertyValue: Property value of parent node one level up.

# If the xml property to be changed is in the element format (<VMName>NewDNSServer</VMName>), just pass the full node path and the new value. No propertyName is required in that case.
# Use the parentPropertyName and parentPropertyValue fields if the value needs to be changed only based on another property's value. Please note the script only looks at the value of 
# the immediate parent.

param([string]$xmlFilePath, [string]$nodePath, [string]$propertyName, [string]$propertyValue, [string]$parentPropertyName, [string]$parentPropertyValue)

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

# PowerShell log set up.
$scriptName = $MyInvocation.MyCommand.Name
function WriteToLog ($logLevel, $text)
{
    $timeStamp = "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
    $delimiter = ":"
    Add-Content $logFilePath "$timeStamp $scriptName$delimiter $logLevel$delimiter $text" -ErrorAction Ignore
}

# Helper function to exit with error.
function ExitWithCode ($code)
{
    # Get Error Details.
    $errorCmdLet = $error[0].InvocationInfo.MyCommand.Name
    $errorLine = $error[0].InvocationInfo.ScriptLineNumber
    $lastError = $error[0].Exception.Message

    if ($lastError)
    {
        WriteToLog $LogLevelError "Cmdlet Details: $errorCmdLet"
        WriteToLog $LogLevelError "Line Number: $errorLine"
        WriteToLog $LogLevelError "Message: $lastError"
        $code = 7
    }

    exit $code
}

# Clear the error variable.
$error.Clear();

WriteToLog $LogLevelInfo "Executing script $scriptName"
WriteToLog $LogLevelInfo "Printing input params"
WriteToLog $LogLevelInfo "Value of xmlFilePath = $xmlFilePath"
WriteToLog $LogLevelInfo "Value of nodePath = $nodePath"
WriteToLog $LogLevelInfo "Value of propertyName = $propertyName"
WriteToLog $LogLevelInfo "Value of propertyValue = $propertyValue"
WriteToLog $LogLevelInfo "Value of parentPropertyName = $dependentPropertyName"
WriteToLog $LogLevelInfo "Value of parentPropertyValue = $parentPropertyValue"

if (!$xmlFilePath) 
{ 
    WriteToLog $LogLevelError "Cannot proceed without a valid xml file path."
    ExitWithCode 2
}

# Check if the file exists in the path.
if (!(Test-Path $xmlFilePath))
{
    WriteToLog $LogLevelError "The XML file does not exist in the specified path."
    ExitWithCode 3
}

if (!$nodePath -or !$propertyValue) 
{ 
    WriteToLog $LogLevelError "Cannot proceed without a valid input. Either the nodePath or propertyValue is null."
    ExitWithCode 4
}

try
{
    # Update the property value for every matching node path.
    $xmlFile = [XML](Get-Content $xmlFilePath)
    $namespace = $xmlFile.DocumentElement.NamespaceURI

    # Update single node value based on neighbor/immediate parent value.
    if ($parentPropertyName -and $parentPropertyValue)
    {
       # Update attribute value of node at same level based on another attribute's value. 
       $parentNodePath = $nodePath
       $childAttributeName = $propertyName

       # Update attribute value of child node based on another attribute's value at the level above. 
       if (!$propertyName)
       {
           $parentNodePath = $nodePath.Substring(0, $nodePath.LastIndexOf('/'))
           $childAttributeName = $nodePath.Substring($nodePath.LastIndexOf('/') + 1)
       }
       
       $nodesToUpdate = $xmlFile.SelectNodes($parentNodePath) | where {$_.$parentPropertyName -eq $parentPropertyValue}
       if ($namespace)
       {
           $namespaceMgr = New-Object System.Xml.XmlNamespaceManager($xmlFile.NameTable)
           $namespaceMgr.AddNamespace("ns", $namespace)
           $nodePathWithNamespace = $parentNodePath -replace "/", "/ns:"
           $nodesToUpdate = $xmlFile.SelectNodes($nodePathWithNamespace, $namespaceMgr) | where {$_.$parentPropertyName -eq $parentPropertyValue}
       }
       
       foreach($nodeToUpdate in $nodesToUpdate)
       {
            $nodeToUpdate.$childAttributeName = $propertyValue    
       }
       
       $xmlFile.Save($xmlFilePath)

       WriteToLog $LogLevelInfo "The XML property has been updated successfully."

       ExitWithCode 0
    }

    # Update all matching values based on full node path.
    $matchingNodes = $xmlFile.SelectNodes($nodePath)
    if ($namespace)
    {
        $namespaceMgr = New-Object System.Xml.XmlNamespaceManager($xmlFile.NameTable)
        $namespaceMgr.AddNamespace("ns", $namespace)
        $nodePathWithNamespace = $nodePath -replace "/", "/ns:"
        $matchingNodes = $xmlFile.SelectNodes($nodePathWithNamespace, $namespaceMgr)
    }
    
    if ($matchingNodes.Count -eq 0)
    {
         WriteToLog $LogLevelError "XML file was not updated as the node path($nodepath) could not be found."
         ExitWithCode 5
    }

    # Update the matching nodes.
    foreach($node in $matchingNodes)
    {
        $attributeExists = $node.HasAttribute($propertyName)
        if ($attributeExists)
        {
            $node.SetAttribute($propertyName, $propertyValue)
        }
        elseif (!$propertyName)
        {
            $node.InnerText = $propertyValue
        }
        else
        {
            WriteToLog $LogLevelError "XML file was not updated as the attribute($propertyName) was not found in the node path($nodePath)."
            ExitWithCode 7
        }
    }

    $xmlFile.Save($xmlFilePath)
    WriteToLog $LogLevelInfo "The XML property has been updated successfully."
}
catch
{
    $exceptionMessage = $_.Exception.Message
    WriteToLog $LogLevelError "Error modifying XML file: $exceptionMessage"
    ExitWithCode 8
}

WriteToLog $LogLevelInfo "Done executing script $scriptName"

ExitWithCode 0