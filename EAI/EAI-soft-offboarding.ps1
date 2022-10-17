# Variables from AWS
$Username = ''
$Password = ''
$FSxPath = '' # 'C:\Users\Administrator\Desktop'
# Variables by PMT
$ADAccount = '' # 'testing' ; need to create New-LocalUser
$ProjectName = '' # 'TestProject'

Write-Output 'EAI Soft Offboarding Script'
Write-Output '====='
# Mount FSx
# net use
$CheckMount = Test-Path $FSxPath
if ($CheckMount -eq $True) {
    Write-Output 'Mounting FSx: Successful'

    # Checking if AD account exists
    $CheckADUser = (Get-LocalUser -Name "$ADAccount").Name -eq $ADAccount
    if ($CheckADUser -eq $True) {
        Write-Output "Checking AD User: $ADAccount Found"

        #Checking if folder with project name exists
        $CheckMainFolder = Test-Path "$FSxPath\$ProjectName"
        if ($CheckMainFolder -eq $True) {
            Write-Output "Checking Main Folder: $ProjectName Folder Found"

            # Removing Permissions
            $MainFolderInfo = Get-Acl -Path "$FSxPath\$ProjectName"
            $Access = 'FullControl'
            $Inheritance = 'ContainerInherit, ObjectInherit'
            $Permissions = New-Object System.Security.AccessControl.FileSystemAccessRule("$ADAccount", "$Access", "$Inheritance", "None", "Deny")
            $MainFolderInfo.AddAccessRule($Permissions)
            Set-Acl -Path "$FSxPath\$ProjectName" -AclObject $MainFolderInfo
            $CheckPermissionsPart1 = (($MainFolderInfo.Access.IdentityReference) | Where-Object {$_.Value -match "$ADAccount"}).Value.Split('\')[-1] -eq "$ADAccount"
            $CheckPermissionsPart2 = ($MainFolderInfo.Access | Where-Object {$_.IdentityReference -match "$ADAccount"}).FileSystemRights -eq $AccessArray
            if ($CheckPermissionsPart1 -eq $True -And $CheckPermissionsPart2 -eq $True) {
                Write-Output 'Removing Permissions: Successful'
                Write-Output '==='
                Write-Output 'Soft Offboarding: Successful'
            } else {
                Write-Output 'Removing Permissions: Unsuccessful'
                Remove-Item -Path "$FSxPath\$ProjectName" -Recurse
                Write-Output '==='
                Write-Output 'Soft Offboarding: Unsuccessful'
            }
        } else {
            Write-Output "Checking Main Folder: $ProjectName Folder Not Found"
            Write-Output '==='
            Write-Output 'Soft Offboarding: Unsuccessful'
        }
    } else {
        Write-Output "Checking AD User: $ADAccount Not Found"
        Write-Output '====='
        Write-Output 'Soft Offboarding: Unsuccessful'
    }
} else {
    Write-Output 'Mounting FSx: Unsuccessful'
    Write-Output '====='
    Write-Output 'Soft Offboarding: Unsuccessful'
}
