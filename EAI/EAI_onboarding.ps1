# Variables by AWS
$Username = ''
$Password = ''
$FSxPath = '' # 'C:\Users\Administrator\Desktop'
# Variables by PMT
$ADAccount = '' # 'testing' ; need to create New-LocalUser
$ProjectName = '' # 'TestProject'

Write-Output 'EAI Onboarding Script'
Write-Output '====='
# Mount FSx
# net use /user:username password
$CheckMount = Test-Path "$FSxPath"
if ($CheckMount -eq $True) {
    Write-Output 'Mounting FSx: Successful'

    # Check if AD user exists
    $CheckADUser = (Get-LocalUser -Name "$ADAccount").Name -eq $ADAccount # Not sure syntax should use Get-ADUser
    if ($CheckADUser -eq $True) {
        Write-Output "Checking AD User: $ADAccount Found"

        # Creates project main folder
        $MainFolder = New-Item -ItemType Directory -Path "$FSxPath\$ProjectName"
        $CheckMainFolder = Test-Path "$FSxPath\$ProjectName"
        if ($checkingMainFolder -eq $True) {
            Write-Output 'Creating Main Folder: Successful'
            
            # Creates project subfolders
            $FolderArray = 'Inbox', 'Inbox-logs', 'Inbox-Src', 'Outbox', 'Outbox-logs', 'Outbox-Src'
            ForEach ($Dir in $FolderArray) {
                $createSubfolder = New-Item -ItemType Directory -Path "$FSxPath\$ProjectName\$Dir"
            }
            $CheckSubfolders = (Get-ChildItem -Directory -Path "$FSxPath\$ProjectName" | Measure-Object).Count
            if ($CheckSubfolders -eq 6) {
                Write-Output "Number of Subfolders: $CheckSubfolders"
                Write-Output 'Creating Subfolders: Successful'

                # Granting permissions
                $MainFolderInfo = Get-Acl -Path "$FSxPath\$ProjectName"
                $AccessArray = 'CreateFiles, WriteExtendedAttributes, WriteAttributes, Delete, ReadAndExecute, Synchronize'
                $Inheritance = 'ContainerInherit, ObjectInherit'
                $Permissions = New-Object System.Security.AccessControl.FileSystemAccessRule("$ADAccount", "$AccessArray", "$Inheritance", "None", "Allow")
                $MainFolderInfo.AddAccessRule($Permissions)
                Set-Acl -Path "$FSxPath\$ProjectName" -AclObject $MainFolderInfo 
                $CheckPermissionsPart1 = (($MainFolderInfo.Access.IdentityReference) | Where-Object {$_.Value -match "$ADAccount"}).Value.Split('\')[-1] -eq "$ADAccount"
                $CheckPermissionsPart2 = ($MainFolderInfo.Access | Where-Object {$_.IdentityReference -match "$ADAccount"}).FileSystemRights -eq $AccessArray
                if ($CheckPermissionsPart1 -eq $True -And $CheckPermissionsPart2 -eq $True) {
                    Write-Output 'Granting Permissions: Successful'
                    Write-Output '====='
                    Write-Output 'Onboarding: Successful'
                } else {
                    Write-Output 'Granting Permissions: Unsuccessful'
                    Remove-Item -Path "$FSxPath\$ProjectName" -Recurse
                    Write-Output '====='
                    Write-Output 'Onboarding: Unsuccessful'
                }
            } else {
                Write-Output "Number of Subfolders: $CheckSubfolders"
                Write-Output 'Creating Subfolders: Unsuccessful'
                Remove-Item -Path "$FSxPath\$ProjectName" -Recurse
                Write-Output '====='
                Write-Output 'Onboarding: Unsuccessful'
            }
        } else {
            Write-Output 'Creating Main Folder: Unsuccessful'
            Write-Output '====='
            Write-Output 'Onboarding: Unsuccessful'
        }
    } else {
        Write-Output "Checking AD User: $ADAccount Not Found"
        Write-Output '====='
        Write-Output 'Onboarding: Unsuccessful'
    }
} else {
    Write-Output 'Mounting FSx: Unsuccessful'
    Write-Output '====='
    Write-Output 'Onboarding: Unsuccessful'
} 
