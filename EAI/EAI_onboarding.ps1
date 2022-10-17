# Variables from AWS
$username = ''
$password = ''
$FSxPath = 'C:\Users\Administrator\Desktop'
# Variables from PMT
$projectName = 'TestProject'
$ADAccount = 'testing'


Write-Output 'EAI Onboarding Script'
Write-Output '====='
# Mount FSx
# net use
$checkMount = Test-Path $FSxPath
if ($checkMount -eq $True) {
    Write-Output 'Mounting FSx: Successful'

    # Checking if AD account exists
    $ADCheck = (Get-LocalUser -Name "$ADAccount").Name -eq $ADAccount # Check if Get-LocalUser or Get-ADUser
    if ($ADCheck -eq $True) {
        Write-Output "Checking AD Account: $ADAccount Found"

        # Creating Main Folder for Project
        $createMainFolder = New-Item -ItemType Directory -Path "$FSxPath\$projectName"
        $checkingMainFolder = Test-Path "$FSxPath\$projectName"
        if ($checkingMainFolder -eq $True) {
            Write-Output 'Creating Main Folder: Successful'

            # Creating Subfolders in Main folder
            $folderArray = 'Inbox', 'Inbox-Src', 'Inbox-logs', 'Outbox', 'Outbox-Src', 'Outbox-logs'
            ForEach ($dir in $folderArray) {
                $createSubfolders = New-Item -ItemType Directory -Path "$FSxPath\$projectName\$dir"
            }
            $noOfSubfolders = (Get-ChildItem -Directory -Path "$FSxPath\$projectName" | Measure-Object).Count
            if ($noOfSubfolders -eq 6) {
                Write-Output "Number of Subfolders: $noOfSubfolders"
                Write-Output 'Creating Subfolders: Successful'

                # Granting Permissions
                $accessArray = 'CreateFiles', 'WriteExtendedAttributes', 'WriteAttributes', 'Delete', 'ReadAndExecute', 'Synchronize'
                $accessInfo = Get-Acl -Path "$FSxPath\$projectName"
                ForEach ($access in $accessArray) {
                    $accessObject = New-Object System.Security.AccessControl.FileSystemAccessRule("$ADAccount", "$access", "Allow")
                    $accessInfo.AddAccessRule($accessObject)
                    Set-Acl -Path "$FSxPath\$projectName" -AclObject $accessInfo
                }
                $permissionPart1 = (($accessInfo.Access.IdentityReference | Where-Object {$_.Value -match "$ADAccount"}).Value.Split('\')[-1]) -eq "$ADAccount"
                $permissionPart2 = ($accessInfo.Access | Where-Object {$_.IdentityReference -match "$ADAccount"}).FileSystemRights -eq $accessArray
                if ($permissionPart1 -eq $True -And $permissionPart2 -eq $True) {
                    Write-Output 'Granting Permissions: Successful'
                } else {
                    Write-Output 'Granting Permissions: Unsuccessful'
                    Remove-Item -Path "$FSxPath\$projectName" -Recurse
                    Write-Output '====='
                    Write-Output 'Onboarding: Unsuccessful'
                }
            } else {
                Write-Output "Number of Subfolders: $noOfSubfolders"
                Write-Output 'Creating Subfolders: Unsuccessful'
                Remove-Item -Path "$FSxPath\$projectName" -Recurse
                Write-Output '====='
                Write-Output 'Onboarding: Unsuccessful'
            }
        } else {
            Write-Output "Creating Main Folder: Unsuccessful"
            Write-Output '====='
            Write-Output 'Onboarding: Unsuccessful'
        }
    } else {
        Write-Output "Checking AD Account: $ADAccount Not Found"
        Write-Output '====='
        Write-Output 'Onboarding: Unsuccessful'
    }
} else {
    Write-Output 'Mounting FSx: Unsuccessful'
    Write-Output '====='
    Write-Output 'Onboarding: Unsuccessful'
}
