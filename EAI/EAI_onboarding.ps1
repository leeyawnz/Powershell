# Variables
param($USERNAME, $PASSWORD, $FSXMOUNTPATH, $ADACCOUNT, $PROJECTNAME)
$FSXPATH = 'Z:'

# Global Functions
function outputScript($result, $message) {
    $DATE = New-Date -UFormat "%B/%d/%Y %T"
    if ($result -eq 0) {
        Write-Output "$DATE [FAILED] $message"
        break
    }
    Write-Output "$DATE [SUCCESS] $message"
}

Write-Output 'EAI Onboarding Script'
Write-Output '====='
# Mounting FSx
net use $FSXMOUNTPATH /user:$USERNAME $PASSWORD
$checkMount = Test-Path "$FSXPATH\"
if ($checkMount -eq $False) {
    outputScript 0 'FSx path not found.'
}
outputScript 1 'Successfully Mounted FSx'

# Checking AD user
$ADPassword = ConvertTo-SecureString -String $PASSWORD -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $USERNAME, $ADPASSWORD
$ADSearchResult = (Get-ADUser -Filter 'SamAccountName -like "$ADACCOUNT"' -Credential $credential).Name
if ($ADSearchResult -ne $ADACCOUNT) {
    outputScript 0 "$ADACCOUNT not found. Please verify AD account."
}
outputScript 1 "$ADACCOUNT found. Proceed to create default main folder"

# Creating main folder
$createMainFolder = New-Item -ItemType Directory -Path "$FSXPATH\$PROJECTNAME"
$checkMainFolder = Test-Path "$FSXPATH\$PROJECTNAME"
if ($checkMainFolder -eq $False) {
    outputScript 0 'Project folder not created.'
}
outputScript 1 "$PROJECTNAME folder created"

# Creating subfolders
$FOLDERARRAY = 'Inbox', 'Inbox-logs', 'Inbox-Src', 'Outbox', 'Outbox-logs', 'Outbox-Src'
ForEach ($DIR in $FOLDERARRAY) {
    $createSubfolder = New-Item -ItemType Directory -Path "$FSXPATH\$PROJECTNAME\$DIR"
}
$subfolders = Get-ChildItem -Directory -Path "$FSXPATH\$PROJECTNAME"
$checkSubfolders = ($subfolders | Measure-Object).Count
$subfolderArray = $subfolders.Name
if ($checkSubfolders -ne $FOLDERARRAY.length) {
    Remove-Item -Path "$FSXPATH\$PROJECTNAME" -Recurse
    outputScript 0 'Project subfolders not created'
}
outputScript 1 "Subfolders created are: $SUBFOLDERSARRAY"

# Granting Permissions
$mainFolderInfo = Get-Acl -Path "$FSXPATH\$PROJECTNAME"
$ACCESSARRAY = 'CreateFiles', 'WriteExtendedAttributes', 'WriteAttributes', 'Delete', 'ReadAndExecute', 'Synchronize'
$INHERITANCE = 'ContainerInherit, ObjectInherit'
ForEach ($ACCESS in $ACCESSARRAY) {
    $permission = New-Object System.Security.AccessControl.FileSystemAccessRule("$ADACCOUNT", "$ACCESS", "$INHERITANCE", "None", "Allow")
    $mainFolderInfo.AddAccessRule($permission)
    Set-Acl -Path "$FSXPATH\$PROJECTNAME" -AclObject $mainFolderInfo
}
$checkPermission1 = (($mainFolderInfo.Access.IdentityReference) | Where-Object {$_.Value -match "$ADACCOUNT"}).Value.Split('\')[-1] -eq "$ADACCOUNT"
$checkPermission2 = ($mainFolderInfo.Access | Where-Object {$_.IdentityReference -match "$ADACCOUNT"}).FileSystemRights
ForEach ($ACCESS in $ACCESSARRAY) {
    if ($checkPermission2 -NotLike "*$ACCESS*") {
        Remove-Item -Path "$FSXPATH\$PROJECTNAME" -Recurse
        outputScript 1 "$ACCESS not granted"
    }
}
if ($checkPermission1 -ne $True) {
    Remove-Item -Path "$FSXPATH\$PROJECTNAME" -Recurse
    outputScript 1 'Permissions not granted successfully'
}
outputScript 0 'Permissions granted'

# Onboarding Info
$path = $mainFolderInfo | Select-Object Path
$ADUser = ($mainFolderInfo.Access | Where-Object {$_.IdentityReference -match "$ADACCOUNT"}).IdentityReference
$accessGiven = ($mainFolderInfo.Access | Where-Object {$_.IdentityReference -match "$ADACCOUNT"}).FileSystemRights
Write-Output '====='
Write-Output "Path: $path"
Write-Output "AD Account: $ADUser"
Write-Output "Access Given: $accessGiven"
Write-Output '====='
outputScript 1 'Onboarding Complete'
