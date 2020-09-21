# Script Name: FileModifyXML
# Description: Creates an XML file.
# Script Version: 1.0.

# Script Arguments:
# xmlFilePath: XML file path. (Example: "C:\Test\settings.xml")

param([string]$xmlFilePath)

if(!(Test-Path "C:\Temp\vrlClient.xml"))
{
New-Item -Path "C:\Temp" -Name "vrlClient.xml" -ItemType File
}
#Remove before testing in Appsetra!
$xmlFilePath = "C:\Temp\vrlClient.xml"

$saveDirectory = $xmlFilePath

[System.Xml.XmlDocument] $xmlDocument = New-Object System.Xml.XmlDocument


#Declaration of the xml file
$decl = $xmlDocument.CreateXmlDeclaration("1.0",$null,$null)

$VRLClientElement = $xmlDocument.CreateElement("VRLClient")

$xmlDocument.AppendChild($VRLClientElement)


$LicServerElement = $xmlDocument.CreateElement("LicServer")
$hostElement = $xmlDocument.CreateElement("Host")
$portElement = $xmlDocument.CreateElement("Port")
$host1Element = $xmlDocument.CreateElement("Host1")
$port1Element = $xmlDocument.CreateElement("Port1")
$host2Element = $xmlDocument.CreateElement("Host2")
$port2Element = $xmlDocument.CreateElement("Port2")
$userElement = $xmlDocument.CreateElement("User")
$passElement = $xmlDocument.CreateElement("Pass")

$VRLClientElement.AppendChild($LicServerElement)

$LicServerElement.AppendChild($hostElement)
$LicServerElement.AppendChild($portElement)
$LicServerElement.AppendChild($host1Element)
$LicServerElement.AppendChild($port1Element)
$LicServerElement.AppendChild($host2Element)
$LicServerElement.AppendChild($port2Element)
$LicServerElement.AppendChild($userElement)
$LicServerElement.AppendChild($passElement)

$xmlDocument.InsertBefore($decl,$xmlDocument.FirstChild)



$xmlDocument.Save("$($saveDirectory)")