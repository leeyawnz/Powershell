# Variables from AWS
$username = ''
$password = ''
$FSxPath = 'C:\Users\Administrator\Desktop'
$EAIAccount = ''
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
    $ADCheck = (Get-LocalUser -Name "$ADAccount").Name -eq $ADAccount
    if ($ADCheck -eq $True) {
        Write-Output "Checking AD Account: $ADAccount Found"

        #Checking if folder with project name exists
        $checkProjectFolder = Test-Path "$FSxPath\$projectName"
        if ($checkProjectFolder -eq $True) {
            Write-Output "Checking Project Folder: $projectName Folder Found"

            # Regaining ownership of project folder
            $EAIOwner = New-Object System.Security.Principal.Ntaccount($EAIAccount)
            $accessInfo.SetOwner($EAIOwner)
            $accessInfo | Set-Acl -Path "$FSxPath\$projectName"
            $ownershipInfo = ($accessInfo.Owner) -eq "$EAIAccount"
            if ($ownershipInfo -eq $True) {
                Write-Output 'Regaining Ownership: Successful'
            } else {
                Write-Output 'Regaining Ownership: Unsuccessful'
                # Revert ownership(?)
                Write-Output '==='
                Write-Output 'Soft Offboarding: Unsuccessful'
            }
        } else {
            Write-Output "Checking Project Folder: $projectName Folder Not Found"
            Write-Output '==='
            Write-Output 'Soft Offboarding: Unsuccessful'
        }
    } else {
        Write-Output "Checking AD Account: $ADAccount Not Found"
        Write-Output '====='
        Write-Output 'Soft Offboarding: Unsuccessful'
    }
} else {
    Write-Output 'Mounting FSx: Unsuccessful'
    Write-Output '====='
    Write-Output 'Soft Offboarding: Unsuccessful'
}
